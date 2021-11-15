# Auto-Scaling Appgate SDP Gateways on aws

This directory contains example how to setup and provision appgate sdp controller and gateways.

## Requirements
- [Terraform](https://www.terraform.io/downloads.html) >= v0.14.5
- [terraform-provider-appgatesdp](https://github.com/appgate/terraform-provider-appgatesdp/releases) >= v0.6.6



### 1. Create the controller


```bash
# we just create an empty config file at first, this file will
# be automatically populated by the controller module.
echo "{}" >> appgateprovider.config.json
terraform init
terraform apply -var-file auto.tfvars -auto-approve
```

example auto.tfvars

```hcl
private_key          = "/path/to/ssh/key/passwordless_rsa"
public_key           = "/path/to/ssh/key/passwordless_rsa.pub"
appliance_cidr_block = "______/24"

ingress_cidr_blocks = [
  "__your_IP__/32",
]

internet_gateway_id = "igw-_____"
vpc_id = "vpc-____"

```


## Initial Setup

Default Admin UI login is `admin`/`adminadmin`. You should change this immediately.
