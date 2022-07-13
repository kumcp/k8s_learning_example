
output "public_sg" {
  value       = aws_security_group.allow_public
  description = "Map of public security groups : port => sg"
}

output "public_sg_id" {
  value       = aws_security_group.allow_public.id
  description = "List of public security group ids"
}

output "specific_sg" {
  value       = aws_security_group.allow_specific
  description = "Map of specific security groups : port_from_to => sg"
}

output "specific_sg_id" {
  value       = aws_security_group.allow_specific.id
  description = "List of specific security group ids"
}
