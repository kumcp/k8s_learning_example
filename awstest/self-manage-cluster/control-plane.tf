terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.15.1"
    }
  }
}

provider "aws" {
  region = local.region
}

## To use template_file, you will need to use template provider


locals {
  region                        = var.region
  keypair_name                  = var.keypair_name
  instance_type_master          = var.instance_type_master
  control_plane_instance_name   = var.control_plane_instance_name
  include_components            = var.include
  include_ebs_csi_driver_policy = var.include_policy_ebs_csi_driver
}
// Usage of template has been deprecated.
# data "template_file" "control_plane_user_data" {
#   template = file("../external/${local.cp_engine}/ubuntu20-k8s-control-plane.sh")

# You can put some variable here to render
# }

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


module "control_plane" {
  source = "../module/ec2_bootstrap"
  ami    = data.aws_ami.ubuntu.id
  // Usage of template has been deprecated.
  # bootstrap_script = data.template_file.control_plane_user_data.rendered

  bootstrap_script = templatefile("../external/templatescript.tftpl", {
    script_list : [
      templatefile("../external/script/awscli.sh", {}),
      templatefile("../external/script/k8s-containerd.sh", {}),
      templatefile("../external/script/config-crictl.sh", {}),
      contains(local.include_components, "docker") ? templatefile("../external/script/docker.sh", {}) : "",
      contains(local.include_components, "cri-docker") ? templatefile("../external/script/cri-docker.sh", {}) : "",
      // Create cluster command
      contains(local.include_components, "cri-docker") ? templatefile("../external/script/create-cluster-docker.sh", {}) : templatefile("../external/script/create-cluster.sh", {}),
      contains(local.include_components, "helm") ? templatefile("../external/script/helm.sh", {}) : "",
      contains(local.include_components, "etcd") ? templatefile("../external/script/etcd-client.sh", {}) : "",
      contains(local.include_components, "ebs-csi-driver") ? templatefile("../external/script/driver/ebs-csi-driver.sh", {}) : "",
      contains(local.include_components, "argocd") ? templatefile("../external/script/argocd.sh", {}) : "",
      contains(local.include_components, "argocd-cli") ? templatefile("../external/script/argocd-cli.sh", {}) : "",
    ]
  })


  role = aws_iam_role.control_plane_role.name
  # security_group_ids = setunion(module.public_ssh_http.public_sg_ids, module.public_ssh_http.specific_sg_ids)
  security_group_ids = [module.public_ssh_http.public_sg_id, module.k8s_cluster_sg.specific_sg_id, module.k8s_cluster_worker_sg.specific_sg_id, module.k8s_public_sg.public_sg_id]
  keypair_name       = local.keypair_name
  instance_type      = local.instance_type_master
  name               = local.control_plane_instance_name
}

module "public_ssh_http" {
  source       = "../module/common_sg"
  name_suffix  = "control_plane_sg"
  public_ports = ["80", "22"]
}

module "k8s_public_sg" {
  source      = "../module/common_sg"
  name_suffix = "k8s_public"
  rules = [{
    from_port   = "30000"
    to_port     = "33000"
    cidr_blocks = ["0.0.0.0/0"]
  }]
}

module "k8s_cluster_sg" {
  source      = "../module/common_sg"
  name_suffix = "k8s_cluster"
  rules = [{
    port        = "6443"
    cidr_blocks = ["172.31.0.0/16"]
    }, {
    from_port   = "2379"
    to_port     = "2380"
    cidr_blocks = ["172.31.0.0/16"]
    }, {
    from_port   = "10250"
    to_port     = "10259"
    cidr_blocks = ["172.31.0.0/16"]
    }, {
    from_port   = "30000"
    to_port     = "32767"
    cidr_blocks = ["172.31.0.0/16"]
    }, {
    from_port   = "6783"
    to_port     = "6783"
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
    }, {
    from_port   = "6783"
    to_port     = "6784"
    protocol    = "udp"
    cidr_blocks = ["172.31.0.0/16"]
  }, ]
}

module "k8s_cluster_worker_sg" {
  source      = "../module/common_sg"
  name_suffix = "k8s_cluster_inside"
  rules = [{
    from_port   = "0"
    to_port     = "63000"
    protocol    = "-1"
    cidr_blocks = ["172.31.0.0/16"]
  }]
}


resource "aws_iam_role" "control_plane_role" {

  name = "role_${local.control_plane_instance_name}"
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  /* This policy need attaching to  */
  inline_policy {
    name = "access_parameter_store"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "VisualEditor0",
          "Effect" : "Allow",
          "Action" : [
            "ssm:PutParameter",
            "ssm:LabelParameterVersion",
            "ssm:DeleteParameter",
            "ssm:UnlabelParameterVersion",
            "ssm:DescribeParameters",
            "ssm:RemoveTagsFromResource",
            "ssm:GetParameterHistory",
            "ssm:AddTagsToResource",
            "ssm:GetParametersByPath",
            "ssm:GetParameters",
            "ssm:GetParameter",
            "ssm:DeleteParameters"
          ],
          "Resource" : "*" // TODO: This will need to be more specific to secure, but just keep it simple for now
        },
      ]
    })
  }

  tags = {
    Name = "control-plane-role"
  }
}


data "aws_iam_policy" "EBSCSIDriver" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_role_policy_attachment" "EBSCSIDriver-role-policy-attach" {
  count = local.include_ebs_csi_driver_policy ? 1 : 0
  role  = aws_iam_role.control_plane_role.name

  # NOTE: This policy should be attached to Nodes which need to create EBS
  # Because this script is using control_plane_role for both control_plane and worker
  # -> Attach to this role
  policy_arn = data.aws_iam_policy.EBSCSIDriver.arn
}

resource "aws_ssm_parameter" "join_k8s_cluster_cmd" {
  name  = "join_command"
  type  = "String"
  value = "NULL"
}
