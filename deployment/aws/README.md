## Configuration
Since we have not yet published the appgate terraform provider to registry.terraform.io we need to manually install it and use local version of appgate provider.


```
# Update the path of the filesystem_mirror.
export TF_CLI_CONFIG_FILE=$PWD/dev.tfrc
```


```
# directory file structure should look something like this:
~/.terraform.d/plugins
├── example.com
│  └── edu
│     └── appgate
│        └── 0.3.1
│           └── linux_amd64
│              └── terraform-provider-appgate

```


### 1. Create the controller


```
terraform plan \
    -target=aws_route_table.appgate_route_table \
    -target=aws_route_table_association.appgate_route_table_assoication \
    -target=module.controller \
    -var 'private_key=/home/dln/.ssh/paswordless' \
    -var 'public_key=/home/dln/.ssh/paswordless.pub' \
    -var 'aws_region=us-east-1'

```


## 2. Apply the gateway autoscale module
Apply the rest of the resources once the controller is up and runnning.
```
terraform apply -auto-approve
```
