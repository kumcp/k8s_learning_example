locals {
  project_name = var.project
  vpc_id       = var.vpc_id == null ? data.aws_vpc.default_vpc.id : var.vpc_id
}


data "aws_vpc" "default_vpc" {
  default = true
}


data "aws_subnets" "current_subnets" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
}

resource "aws_eks_cluster" "cluster" {
  name     = "${local.project_name}-cluster"
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids = data.aws_subnets.current_subnets.ids
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster-AmazonEKSVPCResourceController,
  ]
}


