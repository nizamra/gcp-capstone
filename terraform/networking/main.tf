# ------------------------------------------------------------
# VPC Network
# ------------------------------------------------------------
resource "google_compute_network" "main" {
  name                    = "${var.environment}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  mtu                     = 1460
}

# ------------------------------------------------------------
# Private Subnet (for GKE nodes and internal resources)
# ------------------------------------------------------------
resource "google_compute_subnetwork" "private" {
  name          = "${var.environment}-private-subnet"
  region        = var.region
  network       = google_compute_network.main.id
  ip_cidr_range = var.private_subnet_cidr

  # Allow GKE nodes to reach Google APIs without public IPs
  private_ip_google_access = true

  # Secondary ranges for GKE IP aliasing (required for VPC-native clusters)
  secondary_ip_range {
    range_name    = "pods-range"
    ip_cidr_range = var.pods_secondary_cidr
  }
  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = var.services_secondary_cidr
  }

  # Optional: Enable flow logs for traffic visibility
  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.3  # 30% sampling for private subnet to reduced cost
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# ------------------------------------------------------------
# Public Subnet (for bastion hosts, external LBs if needed)
# ------------------------------------------------------------
resource "google_compute_subnetwork" "public" {
  name          = "${var.environment}-public-subnet"
  region        = var.region
  network       = google_compute_network.main.id
  ip_cidr_range = var.public_subnet_cidr

  private_ip_google_access = false

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.3  # Lower sampling for public subnet to reduce cost
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# ------------------------------------------------------------
# Cloud Router (Required for NAT)
# ------------------------------------------------------------
resource "google_compute_router" "nat_router" {
  name    = "${var.environment}-nat-router"
  region  = var.region
  network = google_compute_network.main.id

  bgp {
    asn = 64514
  }

  depends_on = [google_compute_network.main]
}

# ------------------------------------------------------------
# Cloud NAT - Controlled Egress for Private Subnet
# ------------------------------------------------------------
resource "google_compute_router_nat" "main" {
  name                               = "${var.environment}-nat-gateway"
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY" # GCP manages IPs
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  # Explicitly allow only the private subnet
  subnetwork {
    name                    = google_compute_subnetwork.private.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"] # Pods, services, and nodes
  }

  # Enable logging for security/compliance
  log_config {
    enable = true
    filter = "ERRORS_ONLY" # TRANSLATIONS_ALL is expensive!
  }

  depends_on = [google_compute_router.nat_router]
}

# ------------------------------------------------------------
# Firewall: Allow Internal VPC Traffic (Required for GKE)
# ------------------------------------------------------------
# This is the most important firewall rule. Without it, pods can't communicate.
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.environment}-allow-internal"
  network = google_compute_network.main.name

  direction   = "INGRESS"
  priority    = 1000
  source_ranges = [
    var.private_subnet_cidr,
    var.pods_secondary_cidr,
    var.services_secondary_cidr
  ]

  allow {
    protocol = "tcp"
    ports    = ["1-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["1-65535"]
  }
  allow {
    protocol = "icmp"
  }

  description = "Allow all internal traffic between pods, services, and nodes"
}

# ------------------------------------------------------------
# Firewall: Allow SSH via IAP (Identity-Aware Proxy)
# ------------------------------------------------------------
# This eliminates the need for a bastion host. Users auth with Google Identity.
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "${var.environment}-allow-iap-ssh"
  network = google_compute_network.main.name

  direction   = "INGRESS"
  priority    = 1000
  source_ranges = ["35.235.240.0/20"] # IAP's IP range

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["iap-ssh-access"]

  description = "Allow SSH from IAP only. Tag VMs with 'iap-ssh-access'."
}

# ------------------------------------------------------------
# Firewall: Deny Metadata Server Access (Security Hardening)
# ------------------------------------------------------------
# Prevents pods from accessing sensitive instance metadata
# This mitigates SSRF attacks and privilege escalation
resource "google_compute_firewall" "deny_metadata_egress" {
  name    = "${var.environment}-deny-metadata-egress"
  network = google_compute_network.main.name

  direction     = "EGRESS"
  priority      = 2000 # Higher number = lower priority
  target_tags   = ["deny-metadata"] # Apply to GKE nodes

  deny {
    protocol = "all"
  }

  destination_ranges = ["169.254.169.254/32"] # Metadata server IP

  description = "Block access to instance metadata server (CVE mitigation)"
}
