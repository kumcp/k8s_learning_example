## This is the script to create cluster in AWS.

### 1. Project

This part of the project contains several folder will be explained below:

- `./eks-cluster`: (WIP) This is a sub repo where you can create an eks cluster using terraform.
- `./eksctl-install`: This is a sub terraform repo where you can create an install as a eks-client to connect to eks cluster.
- `./external`: This folder contains scripts which will be run at the beginning of the creating.
- `./module`: This folder is custom module which can be shared across all the repos.
- `./self-manage-cluster`: This is the main folder of this sub repo which include terraform scripts for creating a cluster 1 control-plane and multiple workers.

### 2. Config AWS

Before using this repo, make sure you have install these:

- **AWSCLI** (v2.2.31): This can be found [here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html). Please read and follow the instruction to install.
- **Terraform** (v1.3.9^): This can be found [here](https://www.terraform.io/downloads)

After you have install AWSCLI and Terraform, let's config terraform to run in your account. Because this part assume you have already had some knowledge in AWS, so it will be shorten. If don't understant these instructions, please review your AWS knowledge before going further.

**Step 1**: In your account, go to IAM Section, choose IAM User and Create an User. In **Create User** page, choose Policy which allow AdministratorAccess or PowerUserAccess. Please read the `./self-manage-cluster` folder to know exactly what will happen. This may change in the future.

**Step 2**: After creating User, Choose IAM user details -> Security Credentials, Create an Access Key. And download the key to local and save to someplace.

**Step 3**: On your local machine, run the command:

```
aws configure
```

After you enter the command, a prompt will show up to ask you like below:

```
Access Key: <input access key here>
Secret Access Key: <input secret key here>
Region: <choose which Region you wish>
Output format: <json>
```

**Step 4**: After completing all the step above, go to folder `./self-manage-cluster` and start creating cluster with command:

```
terraform apply
```

### 3. Config terraform project.

In `./self-managed-cluster` project, you will need to config several environment variables:

```
keypair_name = <name of the keypai you have created in EC2 section. If you have none, please create one>
instance_type_master = <master instance type. 't3.small' is the least to be run stable>
instance_type = <worker instance type>
control_plane_instance_name = <control plane instance name>
region = <you ocan specific AWS Region here>
number_of_workers = <how many workers you want to create here. Don't forget to include wrapper "">
include_policy_ebs_csi_driver = <Boolean: show if you want to include policy for EBSCSI driver or not>
include = []

```

After all configuration above, you can start the project with:

```
cd ./self-managed-cluster
terraform init
terraform apply
```
