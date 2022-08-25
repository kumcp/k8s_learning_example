variable "cluster-name" {
  description = "Cluster name"
  type        = string
  default     = "codestar-cluster-demo"
}

variable "vpc_id" {
  type        = string
  description = "VPC id for cluster"
  default     = null
}

variable "account_id" {
  type        = string
  description = "Account Id of the current account"
}

variable "eks_role_name" {
  type        = string
  description = "EKS role will be attached"
}
