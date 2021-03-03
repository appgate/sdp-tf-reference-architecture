# Auto-Scaling Appgate Gateways on aws

This directory contains example how to setup and provision appgate controller and gateways.

## Requirements
- [Terraform](https://www.terraform.io/downloads.html) >= v0.14.5
- [terraform-provider-appgate](https://github.com/appgate/sdp-terraform-provider/releases) >= v0.3.5

## Configuration
Since we have not yet published the appgate terraform provider to registry.terraform.io we need to manually install it and use local version of appgate provider.


```
# Update the path of the filesystem_mirror.
export TF_CLI_CONFIG_FILE=$PWD/dev.tfrc
```


```
# directory file structure should look something like this:
~/.terraform.d/plugins
├── appgate.com
│  └── appgate
│     └── appgate-sdp
│        └── 0.3.5
│           └── linux_amd64
│              └── terraform-provider-appgate

```


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