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
  keypair_name  = var.keypair_name
  instance_type = var.instance_type
  instance_name = var.instance_name

  account_id = var.account_id
}


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


module "eksctl_instance" {
  source           = "../module/ec2_bootstrap"
  ami              = data.aws_ami.ubuntu.id
  bootstrap_script = templatefile("../external/${var.auto_script}/eksctl-k8s-controller.sh", {})

  security_group_ids = [module.public_ssh_http.public_sg_id, module.k8s_cluster_sg.specific_sg_id]
  keypair_name       = local.keypair_name
  instance_type      = local.instance_type
  name               = local.instance_name

  role = aws_iam_role.eksctl_instance_role.name
}


resource "aws_iam_role" "eksctl_instance_role" {

  name = "role_eksctl_instance"
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
    name = "eksctl_policies"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        // EC2FullAccess
        {
          "Action" : "ec2:*",
          "Effect" : "Allow",
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : "elasticloadbalancing:*",
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : "cloudwatch:*",
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : "autoscaling:*",
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : "iam:CreateServiceLinkedRole",
          "Resource" : "*",
          "Condition" : {
            "StringEquals" : {
              "iam:AWSServiceName" : [
                "autoscaling.amazonaws.com",
                "ec2scheduled.amazonaws.com",
                "elasticloadbalancing.amazonaws.com",
                "spot.amazonaws.com",
                "spotfleet.amazonaws.com",
                "transitgateway.amazonaws.com"
              ]
            }
          }
        },
        // AWSCloudFormationFullAccess
        {
          "Effect" : "Allow",
          "Action" : [
            "cloudformation:*"
          ],
          "Resource" : "*"
        },
        // EksAllAccess
        {
          "Effect" : "Allow",
          "Action" : "eks:*",
          "Resource" : "*"
        },
        {
          "Action" : [
            "ssm:GetParameter",
            "ssm:GetParameters"
          ],
          "Resource" : [
            "arn:aws:ssm:*:${local.account_id}:parameter/aws/*",
            "arn:aws:ssm:*::parameter/aws/*"
          ],
          "Effect" : "Allow"
        },
        {
          "Action" : [
            "kms:CreateGrant",
            "kms:DescribeKey"
          ],
          "Resource" : "*",
          "Effect" : "Allow"
        },
        {
          "Action" : [
            "logs:PutRetentionPolicy"
          ],
          "Resource" : "*",
          "Effect" : "Allow"
        },
        // IamLimitedAccess
        {
          "Effect" : "Allow",
          "Action" : [
            "iam:CreateInstanceProfile",
            "iam:DeleteInstanceProfile",
            "iam:GetInstanceProfile",
            "iam:RemoveRoleFromInstanceProfile",
            "iam:GetRole",
            "iam:CreateRole",
            "iam:DeleteRole",
            "iam:AttachRolePolicy",
            "iam:PutRolePolicy",
            "iam:ListInstanceProfiles",
            "iam:AddRoleToInstanceProfile",
            "iam:ListInstanceProfilesForRole",
            "iam:PassRole",
            "iam:DetachRolePolicy",
            "iam:DeleteRolePolicy",
            "iam:GetRolePolicy",
            "iam:GetOpenIDConnectProvider",
            "iam:CreateOpenIDConnectProvider",
            "iam:DeleteOpenIDConnectProvider",
            "iam:TagOpenIDConnectProvider",
            "iam:ListAttachedRolePolicies",
            "iam:TagRole",
            "iam:GetPolicy",
            "iam:CreatePolicy",
            "iam:DeletePolicy",
            "iam:ListPolicyVersions"
          ],
          "Resource" : [
            "arn:aws:iam::${local.account_id}:instance-profile/eksctl-*",
            "arn:aws:iam::${local.account_id}:role/eksctl-*",
            "arn:aws:iam::${local.account_id}:policy/eksctl-*",
            "arn:aws:iam::${local.account_id}:oidc-provider/*",
            "arn:aws:iam::${local.account_id}:role/aws-service-role/eks-nodegroup.amazonaws.com/AWSServiceRoleForAmazonEKSNodegroup",
            "arn:aws:iam::${local.account_id}:role/eksctl-managed-*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "iam:GetRole"
          ],
          "Resource" : [
            "arn:aws:iam::${local.account_id}:role/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "iam:CreateServiceLinkedRole"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringEquals" : {
              "iam:AWSServiceName" : [
                "eks.amazonaws.com",
                "eks-nodegroup.amazonaws.com",
                "eks-fargate.amazonaws.com"
              ]
            }
          }
        }
      ]
    })
  }

  tags = {
    Name = "eksctl-role"
  }
}

module "public_ssh_http" {
  source       = "../module/common_sg"
  name_suffix  = "eksctl_public"
  public_ports = ["80", "22"]
}


module "k8s_cluster_sg" {
  source      = "../module/common_sg"
  name_suffix = "eksctl_specific"
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


