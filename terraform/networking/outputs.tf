output "vpc_id" {
  value       = google_compute_network.main.id
  description = "VPC ID for referencing in other modules"
}

output "vpc_name" {
  value       = google_compute_network.main.name
  description = "VPC name"
}

output "private_subnet_name" {
  value       = google_compute_subnetwork.private.name
  description = "Private subnet name (for GKE cluster creation)"
}

output "public_subnet_name" {
  value       = google_compute_subnetwork.public.name
  description = "Public subnet name"
}

output "pods_secondary_range_name" {
  value       = "pods-range"
  description = "Name of pods secondary range (must match main.tf)"
}

output "services_secondary_range_name" {
  value       = "services-range"
  description = "Name of services secondary range (must match main.tf)"
}

output "nat_gateway_name" {
  value       = google_compute_router_nat.main.name
  description = "Cloud NAT gateway name"
}
