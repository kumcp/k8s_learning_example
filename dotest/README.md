## This is the script to create cluster in Digital Ocean (DO).

### 1. Droplet bootstrap script

There are 2 files in droplet-u22, which used for droplet ubuntu 22.10. After creating Droplets, SSH to Droplets and run these script as the role below:

```
control-plane.sh
worker.sh
```

You can run the fast script using this command:

```
git clone https://github.com/kumcp/k8s_learning_example.git
cd ./k8s_learning_example/
git checkout develop
cd ~
sh ./k8s_learning_example/dotest/droplet-u20/control-plane.sh
```

### 2. Terraform script

To start cluster with terraform script, you will need to follow these steps:

**Step 1**: Create an API keys in your DO account:

Go to your project -> Click on API -> Tokens -> Generate new Tokens -> Copy the new token generated

**Step 2**: Config API Key for project

_Option 1_: Assign key directly into project. (This is fast, but it is not recommended in the production project)

File `terraform.tfvars` can be created from terraform.tfvars.example. Using this command inside `./self-manage-cluster`:

```sh
cp terraform.tfvars.example terraform.tfvars
```

Make changes to newly created `terraform.tfvars` file.

```
do_token = "<input your api key here>"
```

_Option 2_: Using environment variables:

You can use this command in your environment

```
export DIGITALOCEAN_ACCESS_TOKEN=<your-token-here>
```

**Step 3**: Generate terraform project inside this folder and you can create cluster:

```sh
terraform init
terraform apply
```
