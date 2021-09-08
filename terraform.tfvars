project_id                = "host-4502127"
public_key_path           = "~/.ssh/gcp-demo.pub"

fw_image_name             = "vmseries-flex-bundle1-1010"
prefix                    = "panw"
authcodes = null 
auth_file = "../../../gcp/auth/account_host.json"

mgmt_sources              = ["0.0.0.0/0"]
region                   = "us-east4"
cidrs_mgmt                = ["10.0.0.0/28"]
cidrs_untrust             = ["10.0.1.0/28"]
cidrs_trust               = ["10.0.2.0/28"]
cidrs_spoke1              = ["10.1.0.0/24"]
cidrs_spoke2              = ["10.2.0.0/24"]
fw_machine_type           = "n1-standard-4"
fw_bootstrap_path = "bootstrap_files/vmseries_common/"

vm_image                  = "ubuntu-os-cloud/ubuntu-1604-lts"
vm_type                   = "f1-micro"
vm_user                   = "gcpuser"

