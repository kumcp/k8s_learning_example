variable "do_token" {
  type        = string
  description = "Token from Digital Ocean CLI"
}


variable "cp_instance_version" {
  type        = string
  default     = "ubuntu-22-10-x64"
  description = "instance version. Can be `ubuntu-22-10-x64` / `ubuntu-20-04-x64`"
}

variable "cp_instance_size" {
  type        = string
  default     = "s-2vcpu-2gb"
  description = "Instance size for control plane. Can be `s-2vcpu-2gb`"
}

variable "worker_instance_version" {
  type        = string
  default     = "ubuntu-22-10-x64"
  description = "instance version. Can be `ubuntu-22-10-x64` / `ubuntu-20-04-x64`"
}

variable "worker_instance_size" {
  type        = string
  default     = "s-2vcpu-2gb"
  description = "Instance size for worker. Can be `s-2vcpu-2gb`"
}
