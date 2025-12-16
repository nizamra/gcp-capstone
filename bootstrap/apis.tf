resource "google_project_service" "required_apis" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com", # Project metadata
    "storage-component.googleapis.com",    # GCS
    "compute.googleapis.com",              # VPC/Networking
    "container.googleapis.com"             # GKE
  ])

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}
