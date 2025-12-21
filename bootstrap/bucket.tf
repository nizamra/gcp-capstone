resource "google_storage_bucket" "terraform_state" {
  name                        = var.state_bucket_name
  location                    = var.region
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  # Lifecycle rule to delete old versions after 30 days
  lifecycle_rule {
    condition {
      num_newer_versions = 6
    }
    action {
      type = "Delete"
    }
  }

  # Labels for cost attribution and filtering
  labels = {
    environment = "bootstrap"
    managed_by  = "terraform"
    project     = "gcp-capstone"
  }

  depends_on = [google_project_service.required_apis]
}
