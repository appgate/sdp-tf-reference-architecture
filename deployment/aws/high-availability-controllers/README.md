# high availability on controllers

This directory contains example how to setup and provision appgate sdp with multiple controllers in high availability.

## Requirements
- [Terraform](https://www.terraform.io/downloads.html) >= v0.14.5
- [terraform-provider-appgatesdp](https://github.com/appgate/terraform-provider-appgatesdp/releases) >= v0.8.1



## stucture

This directory includes 2 modules, the first module, `aws` create the first controller and basic aws routing.
The second directory, `appgate` creates the second aws_instance and the assoicated appgatesdp resources.


```bash

echo "{}" > appgateprovider.config.json
terraform init
terraform apply -var-file auto.tfvars -auto-approve
```
