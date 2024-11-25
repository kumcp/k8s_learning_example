

locals {
  is_linux = length(regexall("/home/", lower(abspath(path.root)))) > 0
}


resource "tls_private_key" "pk" {
  count           = local.is_linux ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096


  # This part will execute some command in your local machine
  provisioner "local-exec" {
    command = "echo '${tls_private_key.pk[0].private_key_pem}' > ${var.private_key_path} && chmod 600 ${var.private_key_path}"
  }

  provisioner "local-exec" {
    command = "ssh-keygen -y -f ${var.private_key_path} > ${var.public_key_path}"
  }


}


resource "tls_private_key" "pk_win" {
  count           = local.is_linux ? 0 : 1
  algorithm = "RSA"
  rsa_bits  = 4096


  # This part will execute some command in your local machine
  provisioner "local-exec" {
    command = "echo '${tls_private_key.pk_win[0].private_key_pem}' > key.pem"
    interpreter = ["PowerShell", "-Command"]
  }

  # provisioner "local-exec" {
  #   command = "ssh-keygen -y -f key.pem > id_rsa.pub"
  #   interpreter = ["PowerShell", "-Command"]
  # }


}

resource "local_file" "key_file" {
  content     = tls_private_key.pk_win[0].private_key_pem
  filename    = "key2.pem"

  provisioner "local-exec" {
    command = "icacls key2.pem /inheritance:r /grant \"$${env:USERNAME}:(R,W)\""
    interpreter = ["PowerShell", "-Command"]
  }
}


# resource "local_sensitive_file" "pem_file" {
#   filename = pathexpand("~/.ssh/${local.ssh_key_name}.pem")
#   file_permission = "600"
#   directory_permission = "700"
#   content = tls_private_key.ssh.private_key_pem
# }s