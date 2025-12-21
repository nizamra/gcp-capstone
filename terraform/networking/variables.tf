# Core variables
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "zone" {
  description = "GCP Zone (unused in networking but passed for consistency)"
  type        = string
}

# ------------------------------------------------------------
# CIDR BLOCKS
# ------------------------------------------------------------
variable "private_subnet_cidr" {
  description = "CIDR for private subnet (GKE nodes). /21 recommended."
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR for public subnet (bastion/LBs). /24 is fine."
  type        = string
}

variable "pods_secondary_cidr" {
  description = "Secondary CIDR for GKE pods. /14 for large clusters, /18 for small."
  type        = string
}

variable "services_secondary_cidr" {
  description = "Secondary CIDR for GKE services. /20 is usually sufficient."
  type        = string
}

variable "create_nat_static_ip" {
  description = "Reserve static NAT IP for egress allowlisting"
  type        = bool
  default     = false
}
