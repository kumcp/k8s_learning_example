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
  instance_type               = var.instance_type
  control_plane_instance_name = var.control_plane_instance_name
  cp_engine                   = var.cri_engine
}

data "template_file" "control_plane_user_data" {
  template = file("../external/${local.cp_engine}/ubuntu20-k8s-control-plane.sh")

  # You can put some variable here to render
}

module "control_plane" {
  source           = "../module/ec2_bootstrap"
  bootstrap_script = data.template_file.control_plane_user_data.rendered

  # security_group_ids = setunion(module.public_ssh_http.public_sg_ids, module.public_ssh_http.specific_sg_ids)
  security_group_ids = [module.public_ssh_http.public_sg_id, module.k8s_cluster_sg.specific_sg_id]
  keypair_name       = local.keypair_name
  instance_type      = local.instance_type
  name               = local.control_plane_instance_name
}

module "public_ssh_http" {
  source       = "../module/common_sg"
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
  }]
}


resource "aws_ssm_parameter" "join_k8s_cluster_cmd" {
  name  = "join_command"
  type  = "String"
  value = "NULL"
}
