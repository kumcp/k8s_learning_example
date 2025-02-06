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


variable "root_block_delete_on_termination" {
  description = "Determines whether the root block device should be deleted on termination"
  type        = bool
  default     = true
}

variable "root_block_volume_type" {
  description = "The type of the root block volume (e.g., gp2, gp3, io1, io2)"
  type        = string
  default     = "gp3"
}

variable "root_block_iops" {
  description = "The number of IOPS for the root block volume (required for io1, io2, and optionally for gp3)"
  type        = number
  default     = null
}

variable "root_block_kms_key_id" {
  description = "The KMS key ID used to encrypt the root block volume"
  type        = string
  default     = null
}

variable "root_block_throughput" {
  description = "The throughput in MiB/s for gp3 volumes"
  type        = number
  default     = null
}

variable "root_block_volume_size" {
  description = "The size of the root block volume in GiB"
  type        = number
  default     = 8
}

variable "root_block_override" {
  description = "If set to true, the root block device will be overriden with the specified values"
  type        = bool
  default     = false
}