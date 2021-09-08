# --------------------------------------------------------------------------------------------------------------------------
# Setup Terraform providers, pull the regions availability zones, and create naming prefix as local variable

terraform {}

provider "google" {
  #credentials = var.auth_file
  #project     = var.project_id
  region      = var.region
}

data "google_compute_zones" "main" {
  region = var.region
}

locals {
    prefix = "${var.prefix}-${var.region}"
}