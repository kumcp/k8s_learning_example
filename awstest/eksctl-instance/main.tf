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


locals {
  keypair_name  = "codestar-group"
  instance_type = "t2.micro"
  instance_name = "eksctl"
}

module "eksctl_instance" {
  source = "../module/ec2_bootstrap"

  bootstrap_script = templatefile("../external/eks/eksctl-k8s-controller.sh", {})

  security_group_ids = [module.public_ssh_http.public_sg_id, module.k8s_cluster_sg.specific_sg_id]
  keypair_name       = local.keypair_name
  instance_type      = local.instance_type
  name               = local.instance_name
}

module "public_ssh_http" {
  source       = "../module/common_sg"
  public_ports = ["80", "22"]
}


module "k8s_cluster_sg" {
  source      = "../module/common_sg"
  name_suffix = "eksctl"
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
