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
data "template_file" "control_plane_user_data" {
  template = file("../external/ubuntu20-k8scluster-cri-dockerd.sh")

  # You can put some variable here to render
}

module "control_plane" {
  source           = "../module/ec2_bootstrap"
  bootstrap_script = data.template_file.control_plane_user_data.rendered

  # security_group_ids = setunion(module.public_ssh_http.public_sg_ids, module.public_ssh_http.specific_sg_ids)
  security_group_ids = concat(module.public_ssh_http.public_sg_ids, module.k8s_cluster_sg.specific_sg_ids)
  keypair_name       = "codestar-group"
  instance_type      = "t2.small"
  name               = "control-plane"

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
  }]
}

