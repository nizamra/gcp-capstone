# Common variables
variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
}
variable "environment" {
  description = "The deployment environment (e.g., dev, staging, prod)"
  type        = string
}
variable "region" {
  description = "The GCP region for resource deployment"
  type        = string
}
variable "zone" {
  description = "The GCP zone for resource deployment"
  type        = string
}

# Networking module variables
variable "private_subnet_cidr" {
  description = "The CIDR block for the private subnet"
  type        = string
}
variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet"
  type        = string
}
variable "pods_secondary_cidr" {
  description = "The secondary CIDR block for pods"
  type        = string
}
variable "services_secondary_cidr" {
  description = "The secondary CIDR block for services"
  type        = string
}
variable "create_nat_static_ip" {
  description = "Whether to create a static IP for NAT"
  type        = bool
}
