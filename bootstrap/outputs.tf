# Output the bucket name for reference
output "terraform_state_bucket_name" {
  value       = google_storage_bucket.terraform_state.name
  description = "Name of the GCS bucket for Terraform state. Save this!"
}
