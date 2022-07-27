variable "vpc_id" {
  description = "Specific VPC id for these SGs. If it's not present, then use VPC default"
  default     = ""
  type        = string
}

variable "public_ports" {
  type    = list(string)
  default = ["80"]
}

variable "rules" {
  type = list(object({
    port             = optional(string)
    from_port        = optional(string)
    to_port          = optional(string)
    protocol         = optional(string)
    cidr_blocks      = optional(list(string))
    ipv6_cidr_blocks = optional(list(string))
    description      = optional(string)
  }))
  default     = []
  description = "You will need to provide a tupple of rule set include : port|from_port,to_port,protocol, cidr_blocks"
}
variable "name_suffix" {
  type    = string
  default = "demo"
}

variable "tags" {
  type    = map(any)
  default = {}
}
