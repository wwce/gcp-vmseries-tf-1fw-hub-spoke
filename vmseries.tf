# --------------------------------------------------------------------------------------------------------------------------
# Create bootstrap bucket for VM-Series and create VM-Series firewalls. \

module "vmseries_common" {
  source = "./modules/vmseries/"
  image_prefix_uri      = "https://www.googleapis.com/compute/v1/projects/panw-gcp-team-testing/global/images/"
  image_name            = var.fw_image_name
  machine_type          = var.fw_machine_type
  create_instance_group = true
  project               = var.project_id
  ssh_key               = fileexists(var.public_key_path) ? "admin:${file(var.public_key_path)}" : ""
  
  instances = {

    vmseries01 = {
      name             = "${local.prefix}-vmseries01"
      zone             = data.google_compute_zones.main.names[0]
      bootstrap_bucket = "" #var.fw_bootstrap_bucket
      network_interfaces = [
        {
          subnetwork = module.vpc_untrust.subnet_self_link["untrust-${var.region}"]
          public_nat = true
        },
        {
          subnetwork = module.vpc_mgmt.subnet_self_link["mgmt-${var.region}"]
          public_nat = true
        },
        {
          subnetwork = module.vpc_trust.subnet_self_link["trust-${var.region}"]
          public_nat = false
        }
      ]
    }
  }

  depends_on = []
}


# --------------------------------------------------------------------------------------------------------------------------
# Set default route to VM-Series within the trust VPC network

resource "google_compute_route" "route_common" {
  name              = "${local.prefix}-route"
  dest_range        = "0.0.0.0/0"
  network           = module.vpc_trust.vpc_id
  next_hop_instance = module.vmseries_common.self_links["vmseries01"]
  priority          = 1000
}


# --------------------------------------------------------------------------------------------------------------------------
# Outputs to terminal

# output "WEB_VM_NETWORK_A" {
#   value = "http://${module.vmseries_common.nic0_ips["vmseries01"]}"
# }

output "SSH_TO_NETWORK_C" {
  value = "ssh paloalto@${module.vmseries_common.nic0_ips["vmseries01"]}"
}

output "VMSERIES_ACCESS" {
  value = "https://${module.vmseries_common.nic1_ips["vmseries01"]}"
}

output "VM_USERNAME" {
  value = "paloalto"
}

output "VM_PASSWORD" {
  value = "Pal0Alt0@123"
}

# wget www.eicar.org/download/eicar.com.txt
# curl http://10.1.0.10/cgi-bin/../../../..//bin/cat%20/etc/passwd