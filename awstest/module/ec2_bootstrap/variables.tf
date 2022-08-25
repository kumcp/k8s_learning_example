variable "bootstrap_script" {
  type    = string
  default = ""
}

variable "ami" {
  type    = string
  default = "ami-055d15d9cfddf7bd3"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "bootstrap_script_file" {
  type    = string
  default = ""
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "subnet_id" {
  type    = string
  default = ""
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "name" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(any)
  default = {}
}

variable "keypair_name" {
  type = string
}

variable "number_of_instances" {
  type    = number
  default = 1
}


variable "role" {
  type = string
  description = "Role name to be added into multiple ec2 instances"
  default = null
}