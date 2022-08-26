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
  number_of_instances = var.number_of_instances
  ami                 = var.ami
  instance_type       = var.instance_type
  bootstrap_script    = try(var.bootstrap_script, file(var.bootstrap_script_file))

  security_group_ids = var.security_group_ids

  keypair_name = var.keypair_name

  # If subnet_id is not specific, then use first default subnet
  subnet_id = var.subnet_id == "" ? tolist(data.aws_subnets.default_subnets.ids)[0] : var.subnet_id

  include_role = var.role != null 

  common_tags = merge(var.tags, {
    Name = var.name != "" ? var.name : "ec2-bootstrap-demo"
  })
}

resource "aws_network_interface" "instance_eni" {
  count     = local.number_of_instances
  subnet_id = local.subnet_id

  security_groups = local.security_group_ids

  tags = merge(local.common_tags,
    tomap({
      Name = "primary_network_interface${count.index}"
  }))
}

resource "aws_instance" "this" {
  count = local.number_of_instances

  ami           = local.ami
  instance_type = local.instance_type
  key_name      = local.keypair_name

  iam_instance_profile = local.include_role ? aws_iam_instance_profile.profile[count.index].name : null
  network_interface {
    network_interface_id = aws_network_interface.instance_eni[count.index].id
    device_index         = 0
  }

  user_data = local.bootstrap_script
  tags      = merge(local.common_tags,
    tomap({
      Name = local.number_of_instances == 1 ? "${local.common_tags.Name}" : "${local.common_tags.Name}_${count.index}"
  }))
}





resource "aws_iam_instance_profile" "profile" {
  count = local.include_role ? local.number_of_instances : 0

  name = "profile_${local.common_tags.Name}_${count.index}"
  role = var.role
}
