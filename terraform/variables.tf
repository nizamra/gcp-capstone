# Common variables
variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
}
variable "environment" {
  description = "The deployment environment (e.g., dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "stg", "prod"], var.environment)
    error_message = "Valid values: dev, stg, prod."
  }
}

variable "region" {
  description = "The GCP region for resource deployment"
  type        = string
}

variable "zone" {
  description = "The GCP zone for resource deployment"
  type        = string
}
# ------------------------------------------------------------
# MODULE SELECTOR
# ------------------------------------------------------------
variable "target_module" {
  description = <<EOF
  Specific module to deploy. Leave empty to deploy all modules.
  Options: networking, security, registry, gke, observability
  EOF
  type        = string
  validation {
    condition     = var.target_module == "" || contains(["networking", "security", "registry", "gke", "observability"], var.target_module)
    error_message = "Valid modules: networking, security, registry, gke, observability, or empty for all."
  }
}

# ------------------------------------------------------------
# NETWORKING MODULE VARIABLES
# ------------------------------------------------------------

variable "private_subnet_cidr" {
  description = "The CIDR block for the private subnet (GKE nodes). Use /21+ for production."
  type        = string
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet (bastion/LBs). Use /24 for small."
  type        = string
}

variable "pods_secondary_cidr" {
  description = "The secondary CIDR block for GKE pods. /14 supports 10k+ nodes."
  type        = string
}

variable "services_secondary_cidr" {
  description = "The secondary CIDR block for GKE services. /20 is usually sufficient."
  type        = string
}

variable "create_nat_static_ip" {
  description = "Whether to reserve a static IP for NAT (required for egress allowlisting)"
  type        = bool
  default     = false
}
