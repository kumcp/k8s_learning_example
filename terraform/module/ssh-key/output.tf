output "private_key" {
  value = local.is_linux ? tls_private_key.pk[0].private_key_pem : tls_private_key.pk_win[0].private_key_pem
}

output "public_key" {
  value = local.is_linux ? tls_private_key.pk[0].public_key_openssh : tls_private_key.pk_win[0].public_key_openssh
}