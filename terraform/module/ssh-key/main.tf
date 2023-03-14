resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096


  # This part will execute some command in your local machine
  provisioner "local-exec" {
    command = "echo '${tls_private_key.pk.private_key_pem}' > ${var.private_key_path} && chmod 600 ${var.private_key_path}"
  }

  provisioner "local-exec" {
    command = "ssh-keygen -y -f ${var.private_key_path} > ${var.public_key_path}"
  }
}


# resource "local_sensitive_file" "pem_file" {
#   filename = pathexpand("~/.ssh/${local.ssh_key_name}.pem")
#   file_permission = "600"
#   directory_permission = "700"
#   content = tls_private_key.ssh.private_key_pem
# }
