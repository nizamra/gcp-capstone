terraform {
  required_version = "1.14.2"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.13.0"
    }
  }

  backend "gcs" {}
}

provider "google" {
  project = var.project_id
  region  = var.region

  default_labels = {
    environment    = var.environment
    managed_by     = "terraform"
    project        = "gcp-capstone"
    team           = "platform-engineering"
    cost_center    = "devops"
    repository     = "gcp-capstone"
    terraform_root = "true"
  }
}

module "networking" {
  # Deploy if target_module is empty (all) OR explicitly "networking"
  count  = var.target_module == "" || var.target_module == "networking" ? 1 : 0
  source = "./networking"

  # Common variables
  project_id  = var.project_id
  environment = var.environment
  region      = var.region
  zone        = var.zone

  # Networking-specific variables
  private_subnet_cidr     = var.private_subnet_cidr
  public_subnet_cidr      = var.public_subnet_cidr
  pods_secondary_cidr     = var.pods_secondary_cidr
  services_secondary_cidr = var.services_secondary_cidr
  create_nat_static_ip    = var.create_nat_static_ip
}
