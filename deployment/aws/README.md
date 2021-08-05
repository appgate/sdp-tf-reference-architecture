# Auto-Scaling Appgate SDP Gateways on aws

This directory contains example how to setup and provision appgate sdp controller and gateways.

## Requirements
- [Terraform](https://www.terraform.io/downloads.html) >= v0.14.5
- [terraform-provider-appgatesdp](https://github.com/appgate/terraform-provider-appgatesdp/releases) >= v0.5.0



### 1. Create the controller


```
terraform plan \
    -target=module.controller \
    -tfvars=YourConfigVariables.tfvars

```


## 2. Apply the gateway autoscale module
Apply the rest of the resources once the controller is up and runnning.
```
terraform apply -auto-approve
```


## Initial Setup

Default Admin UI login is `admin`/`adminadmin`. You should change this immediately.
