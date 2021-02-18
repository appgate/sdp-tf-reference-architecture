## Requirements
- [Terraform](https://www.terraform.io/downloads.html) >= v0.14.5

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
│     └── appgate
│        └── 0.3.2
│           └── linux_amd64
│              └── terraform-provider-appgate

```


### 1. Create the controller


```
terraform plan \
    -target=module.controller \
    -var 'private_key=/home/dln/.ssh/paswordless' \
    -var 'public_key=/home/dln/.ssh/paswordless.pub'

```


## 2. Apply the gateway autoscale module
Apply the rest of the resources once the controller is up and runnning.
```
terraform apply -auto-approve
```