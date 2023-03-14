output "private_key" {
  value = tls_private_key.pk.private_key_pem
}

output "public_key" {
  value = tls_private_key.pk.public_key_openssh
}
