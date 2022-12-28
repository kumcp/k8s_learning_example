variable "account_id" {
  type        = string
  description = "Input your account id here to be more specific (This will needed in IAM)"
  default     = ""

}

variable "keypair_name" {
  type        = string
  description = "Input keypair name. You need to create key by yourself first"
}

variable "instance_type" {
  type        = string
  description = "EC2 Instance type (Default: t2.micro)"
  default     = "t2.micro"
}

variable "instance_name" {
  type        = string
  description = "Name instance by tag"
  default     = "eksctl"
}


variable "auto_script" {
  type        = string
  description = "name of auto script will be used in creating eksctl. You can take a look in ../external/ folder"
  default     = "eks"
}
