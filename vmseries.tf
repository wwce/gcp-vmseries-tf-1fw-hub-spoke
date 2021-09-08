# --------------------------------------------------------------------------------------------------------------------------
# Create bootstrap bucket for VM-Series and create VM-Series firewalls. 

module "bootstrap_common" {
  source        = "./modules/gcp_bootstrap/"
  bucket_name   = "${local.prefix}-bootstrap"
  file_location = var.fw_bootstrap_path
  config        = ["init-cfg.txt", "bootstrap.xml"]
  authcodes     = var.authcodes
}

module "vmseries_common" {
  source = "./modules/vmseries/"

  ssh_key               = fileexists(var.public_key_path) ? "admin:${file(var.public_key_path)}" : ""
  image_name            = var.fw_image_name
  machine_type          = var.fw_machine_type
  create_instance_group = true

  instances = {

    vmseries01 = {
      name             = "${local.prefix}-vmseries01"
      zone             = data.google_compute_zones.main.names[0]
      bootstrap_bucket = module.bootstrap_common.bucket_name
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

  depends_on = [
    module.bootstrap_common
  ]
}

resource "google_compute_route" "route_common" {
  name              = "${local.prefix}-route"
  dest_range        = "0.0.0.0/0"
  network           = module.vpc_trust.vpc_id
  next_hop_instance = module.vmseries_common.self_links["vmseries01"]
  priority          = 1000
}



# --------------------------------------------------------------------------------------------------------------------------
# Outputs to terminal


output "WEB_VM_NETWORK_A" {
  value = "http://${module.vmseries_common.nic1_ips["vmseries01"]}"
}
output "SSH_VM_NETWORK_C" {
  value = "ssh ${var.vm_user}@${module.vmseries_common.nic0_ips["vmseries01"]} -i ${trim(var.public_key_path, ".pub")}"
}

output "MGMT_FW" {
  value = "https://${module.vmseries_common.nic1_ips["vmseries01"]}"
}
