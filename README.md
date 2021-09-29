## Single VM-Series Hub and Spoke Lab

This lab creates a VM-Series firewall to secure inbound, outbound, and east-west traffic for two spoke networks.  The spoke networks (network-a and network-c) are connected to the hub network (network-hub) via VPC Network peering.  Traffic egressing from the spoke networks is routed to the VM-Series trust dataplane interface.  If the destination of a request is an internet resource, the VM-Series will inspect and route the request through its untrust dataplane interface where it will be routed to the untrust network’s internet gateway.  If the destination of the request is an adjacent spoke network (east-west), the VM-Series will inspect and route the request through its trust dataplane interface (hair pin) towards the adjacent network’s peering connection. 

</br>
<p align="center">
<img src="https://raw.githubusercontent.com/wwce/gcp-vmseries-tf-1fw-hub-spoke/master/images/diagram.png">
</p>


### Prerequistes 
* Valid GCP Account with existing project
* Access to GCP Cloud Terminal or to a machine with a Terraform 1.0 installation

</br>

### How to Deploy
#### 1. Setup & Download Build
In your project, open GCP Cloud Terminal and run the following.
```
$ gcloud services enable compute.googleapis.com
$ ssh-keygen -f ~/.ssh/gcp-demo -t rsa -C gcp-demo
$ git clone https://github.com/wwce/gcp-vmseries-tf-1fw-hub-spoke-lab; cd gcp-vmseries-tf-1fw-hub-spoke-lab
```

#### 2. Edit terraform.tfvars
Open terraform.tfvars and edit variables (lines 1-4) to match your Project ID, deployment prefix, SSH Key (from step 1), and VM-Series type.

```
$ vi terraform.tfvars
```

<p align="center">
<b>Your terraform.tfvars should look like this before proceeding</b>
<img src="https://raw.githubusercontent.com/wwce/gcp-vmseries-tf-ilbnh-tags/master/images/tfvars.png" width="75%" height="75%" >
</p>

#### 3. Deploy Build
```
$ terraform init
$ terraform apply
```

</br>

### How to Destroy
Run the following to destroy the build and remove the SSH key created in step 1.
```
$ terraform destroy
$ rm ~/.ssh/gcp-demo*
```

</br>

### Support Policy
The guide in this directory and accompanied files are released under an as-is, best effort, support policy. These scripts should be seen as community supported and Palo Alto Networks will contribute our expertise as and when possible. We do not provide technical support or help in using or troubleshooting the components of the project through our normal support options such as Palo Alto Networks support teams, or ASC (Authorized Support Centers) partners and backline support options. The underlying product used (the VM-Series firewall) by the scripts or templates are still supported, but the support is only for the product functionality and not for help in deploying or using the template or script itself.
Unless explicitly tagged, all projects or work posted in our GitHub repository (at https://github.com/PaloAltoNetworks) or sites other than our official Downloads page on https://support.paloaltonetworks.com are provided under the best effort policy.