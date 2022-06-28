variable "keypair_name" {
  type        = string
  description = "Key pair name you wanted to assign to both control plane and worker node"
}

variable "instance_type" {
  type        = string
  description = "Instance type "
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
