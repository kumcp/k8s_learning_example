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

data "aws_vpc" "default_vpc" {
  default = true
}



locals {
  cluster_name = var.cluster-name
  vpc_id       = var.vpc_id == null ? data.aws_vpc.default_vpc.id : var.vpc_id
}

data "aws_subnets" "current_subnets" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  create = true

  cluster_name    = "eks-cluster"
  cluster_version = "1.22"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }


  vpc_id     = local.vpc_id
  subnet_ids = data.aws_subnets.current_subnets.ids

  #   # Self Managed Node Group(s)
  #   self_managed_node_group_defaults = {
  #     instance_type                          = "m6i.large"
  #     update_launch_template_default_version = true
  #     iam_role_additional_policies = [
  #       "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  #     ]
  #   }

  #   self_managed_node_groups = {
  #     one = {
  #       name         = "mixed-1"
  #       max_size     = 5
  #       desired_size = 2

  #       use_mixed_instances_policy = true
  #       mixed_instances_policy = {
  #         instances_distribution = {
  #           on_demand_base_capacity                  = 0
  #           on_demand_percentage_above_base_capacity = 10
  #           spot_allocation_strategy                 = "capacity-optimized"
  #         }

  #         override = [
  #           {
  #             instance_type     = "m5.large"
  #             weighted_capacity = "1"
  #           },
  #           {
  #             instance_type     = "m6i.large"
  #             weighted_capacity = "2"
  #           },
  #         ]
  #       }
  #     }
  #   }

  #   # EKS Managed Node Group(s)
  #   eks_managed_node_group_defaults = {
  #     disk_size      = 50
  #     instance_types = ["t2.micro", "t3.micro"]
  #   }

  eks_managed_node_groups = {
    blue = {}
    green = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t3.micro"]
      # capacity_type  = "SPOT"
    }
  }

  #   # Fargate Profile(s)
  #   fargate_profiles = {
  #     default = {
  #       name = "default"
  #       selectors = [
  #         {
  #           namespace = "default"
  #         }
  #       ]
  #     }
  #   }

  # aws-auth configmap
  create_aws_auth_configmap = true
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::103251686303:role/EKS-cluster"
      username = "EKS-cluster"
    },
  ]

  #   aws_auth_users = [
  #     {
  #       userarn  = "arn:aws:iam::66666666666:user/user1"
  #       username = "user1"
  #       groups   = ["system:masters"]
  #     },
  #     {
  #       userarn  = "arn:aws:iam::66666666666:user/user2"
  #       username = "user2"
  #       groups   = ["system:masters"]
  #     },
  #   ]

  # aws_auth_accounts = [
  #   "103251686303"
  # ]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
