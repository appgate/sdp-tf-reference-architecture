# Auto-Scaling Appgate Gateways on aws

This directory contains example how to setup and provision appgate controller and gateways.

## Requirements
- [Terraform](https://www.terraform.io/downloads.html) >= v0.14.5
- [terraform-provider-appgate](https://github.com/appgate/sdp-terraform-provider/releases) >= v0.5.0



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

Default Admin UI login is `admin`/`admin`. You should change this immediately.
