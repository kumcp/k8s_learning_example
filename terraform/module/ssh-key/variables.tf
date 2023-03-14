
variable "private_key_path" {
  type        = string
  default     = "./key.pem"
  description = "The place where you want to put the generated key. Default is ./key.pem"
}

variable "public_key_path" {
  type        = string
  default     = "./id_rsa.pub"
  description = "The place where you want to put the public key. Default is ./id_rsa.pub"
}
