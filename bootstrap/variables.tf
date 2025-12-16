variable "project_id" {
  description = "GCP Project ID where bootstrap resources will live."
  type        = string
}

variable "region" {
  description = "Primary region for resources (e.g., us-central1)."
  type        = string
  default     = "us-central1"
}

variable "state_bucket_name" {
  description = "Name of the GCS bucket to create for Terraform state. Must be globally unique."
  type        = string
}
