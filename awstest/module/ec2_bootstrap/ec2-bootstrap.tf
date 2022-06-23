data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnets" "default_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
}

locals {
  ami              = var.ami
  instance_type    = var.instance_type
  bootstrap_script = try(var.bootstrap_script, file(var.bootstrap_script_file))

  security_group_ids = var.security_group_ids

  keypair_name = var.keypair_name

  # If subnet_id is not specific, then use first default subnet
  subnet_id = var.subnet_id == "" ? tolist(data.aws_subnets.default_subnets.ids)[0] : var.subnet_id

  common_tags = merge(var.tags, {
    Name = var.name != "" ? var.name : "ec2-bootstrap-demo"
  })
}

resource "aws_network_interface" "instance_eni" {
  subnet_id = local.subnet_id

  security_groups = local.security_group_ids

  tags = merge(local.common_tags,
    tomap({
      Name = "primary_network_interface"
  }))
}

resource "aws_instance" "this" {

  ami           = local.ami
  instance_type = local.instance_type
  key_name      = local.keypair_name

  iam_instance_profile = aws_iam_instance_profile.profile.name
  network_interface {
    network_interface_id = aws_network_interface.instance_eni.id
    device_index         = 0
  }

  user_data = local.bootstrap_script
  tags      = local.common_tags
}


resource "aws_iam_role" "control_plane_role" {

  name = "role_${local.common_tags.Name}"
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
          "Resource" : "*"
        }
      ]
    })
  }

  tags = {
    Name = "control-plane-role"
  }
}


resource "aws_iam_instance_profile" "profile" {
  name = "profile_${local.common_tags.Name}"
  role = aws_iam_role.control_plane_role.name
}
