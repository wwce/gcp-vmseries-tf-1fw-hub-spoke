variable cidrs_spoke1 {
  type = list(string)
}
variable cidrs_spoke2 {
  type = list(string)
}
variable vm_image {
  default = "ubuntu-os-cloud/ubuntu-1604-lts"
}

variable vm_type {
  default = "f1-micro"
}

variable vm_user {}

variable vm_scopes {
  type = list(string)

  default = [
    "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
  ]
}


# --------------------------------------------------------------------------------------------------------------------------
# Creates 2 x Spoke VPC Networks and peer them to the trust/hub network.

module "vpc_spoke1" {
  source               = "./modules/vpc/"
  vpc                  = "${local.prefix}-spoke1-vpc"
  delete_default_route = true
  allowed_sources      = ["0.0.0.0/0"]

  subnets = {
    "spoke1-${var.region}" = {
      region = var.region,
      cidr   = var.cidrs_spoke1[0]
    }
  }
}

resource "google_compute_network_peering" "spoke1_to_trust" {
  name         = "${module.vpc_spoke1.vpc_name}-${module.vpc_trust.vpc_name}"
  network      = module.vpc_spoke1.vpc_id
  peer_network = module.vpc_trust.vpc_id
  export_custom_routes = false
  import_custom_routes = true 
}

resource "google_compute_network_peering" "trust_to_spoke1" {
  name         = "${module.vpc_trust.vpc_name}-${module.vpc_spoke1.vpc_name}"
  network      = module.vpc_trust.vpc_id
  peer_network = module.vpc_spoke1.vpc_id
  export_custom_routes = true
  import_custom_routes = false 
}


module "vpc_spoke2" {
  source               = "./modules/vpc/"
  vpc                  = "${local.prefix}-spoke2-vpc"
  delete_default_route = true
  allowed_sources      = ["0.0.0.0/0"]

  subnets = {
    "spoke2-${var.region}" = {
      region = var.region,
      cidr   = var.cidrs_spoke2[0]
    }
  }
}


resource "google_compute_network_peering" "spoke2_to_trust" {
  name         = "${module.vpc_spoke2.vpc_name}-${module.vpc_trust.vpc_name}"
  network      = module.vpc_spoke2.vpc_id
  peer_network = module.vpc_trust.vpc_id
  export_custom_routes = false
  import_custom_routes = true 
}

resource "google_compute_network_peering" "trust_to_spoke2" {
  name         = "${module.vpc_trust.vpc_name}-${module.vpc_spoke2.vpc_name}"
  network      = module.vpc_trust.vpc_id
  peer_network = module.vpc_spoke2.vpc_id
export_custom_routes = true
  import_custom_routes = false 
}

# --------------------------------------------------------------------------------------------------------------------------
# Create a ubuntu GCE instance in each spoke network.

resource "google_compute_instance" "spoke1" {
  name                      = "${local.prefix}-spoke1-vm1"
  machine_type              = var.vm_type
  zone                      = data.google_compute_zones.main.names[0]
  can_ip_forward            = false
  allow_stopping_for_update = true
  metadata_startup_script   = file("${path.module}/bootstrap_files/webserver-startup.sh")

  metadata = {
    serial-port-enable = true
    ssh-keys           = fileexists(var.public_key_path) ? "${var.vm_user}:${file(var.public_key_path)}" : ""
  }

  network_interface {
    subnetwork = module.vpc_spoke1.subnet_self_link["spoke1-${var.region}"]
    network_ip = cidrhost(var.cidrs_spoke1[0], 10)
  }

  boot_disk {
    initialize_params {
      image = var.vm_image
    }
  }

  service_account {
    scopes = var.vm_scopes
  }
  
}


resource "google_compute_instance" "spoke2" {
  name                      = "${local.prefix}-spoke2-vm1"
  machine_type              = var.vm_type
  zone                      = data.google_compute_zones.main.names[0]
  can_ip_forward            = false
  allow_stopping_for_update = true

  metadata = {
    serial-port-enable = true
    ssh-keys           = fileexists(var.public_key_path) ? "${var.vm_user}:${file(var.public_key_path)}" : ""
  }

  network_interface {
    subnetwork = module.vpc_spoke2.subnet_self_link["spoke2-${var.region}"]
    network_ip = cidrhost(var.cidrs_spoke2[0], 10)
  }

  boot_disk {
    initialize_params {
      image = var.vm_image
    }
  }

  service_account {
    scopes = var.vm_scopes
  }

}