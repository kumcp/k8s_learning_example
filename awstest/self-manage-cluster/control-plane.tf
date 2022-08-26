terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.15.1"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

## To use template_file, you will need to use template provider


locals {
  keypair_name                = var.keypair_name
  instance_type_master        = var.instance_type_master
  control_plane_instance_name = var.control_plane_instance_name
  cp_engine                   = var.cri_engine
}
// Usage of template has been deprecated.
# data "template_file" "control_plane_user_data" {
#   template = file("../external/${local.cp_engine}/ubuntu20-k8s-control-plane.sh")

# You can put some variable here to render
# }

module "control_plane" {
  source = "../module/ec2_bootstrap"

  // Usage of template has been deprecated.
  # bootstrap_script = data.template_file.control_plane_user_data.rendered


  bootstrap_script = templatefile("../external/${local.cp_engine}/ubuntu20-k8s-control-plane.sh", {})

  role = aws_iam_role.control_plane_role.name
  # security_group_ids = setunion(module.public_ssh_http.public_sg_ids, module.public_ssh_http.specific_sg_ids)
  security_group_ids = [module.public_ssh_http.public_sg_id, module.k8s_cluster_sg.specific_sg_id, module.k8s_cluster_worker_sg.specific_sg_id]
  keypair_name       = local.keypair_name
  instance_type      = local.instance_type_master
  name               = local.control_plane_instance_name
}

module "public_ssh_http" {
  source       = "../module/common_sg"
  name_suffix = "control_plane_sg"
  public_ports = ["80", "22"]
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
          "Resource" : "*"  // TODO: This will need to be more specific to secure, but just keep it simple for now
        }
      ]
    })
  }

  tags = {
    Name = "control-plane-role"
  }
}


resource "aws_ssm_parameter" "join_k8s_cluster_cmd" {
  name  = "join_command"
  type  = "String"
  value = "NULL"
}
