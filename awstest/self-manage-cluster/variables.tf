variable "keypair_name" {
  type        = string
  description = "Key pair name you wanted to assign to both control plane and worker node"
}

variable "instance_type_master" {
  type        = string
  description = "Instance type master"
}

variable "instance_type" {
  type        = string
  description = "Instance type for worker"
}


variable "control_plane_instance_name" {
  type        = string
  description = "Control Plane instance name"
}


variable "cri_engine" {
  type        = string
  description = "CRI Engine for k8s cluster. Can be: containerd (default), docker, podman"
  default     = "containerd"
}

variable "number_of_workers" {
  type        = number
  description = "Number of worker nodes that you want to create"
  default     = 1
}


variable "include_ebs_csi_driver_policy" {
  type        = bool
  description = "This setting will add EBS CSI Policy. This is not recommend for learning Storage"
  default     = false
}
