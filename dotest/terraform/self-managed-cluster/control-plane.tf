terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.26.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_tag" "cluster-tag" {
  name = "${local.project_name}-tag"
}

locals {
  region   = "sgp1"
  cp_image = var.cp_instance_version
  cp_size  = var.cp_instance_size
  cp_name  = "control-plane"

  worker_image = var.worker_instance_version
  worker_size  = var.worker_instance_size
  worker_name  = "worker"

  tags         = [digitalocean_tag.cluster-tag.name]
  project_name = "sm"
}

module "key" {
  source = "../../../terraform/module/ssh-key"

  private_key_path = "./key.pem"
  public_key_path  = "./id_rsa.pub"
}

resource "digitalocean_ssh_key" "ssh_key" {
  name       = "ssh-key"
  public_key = module.key.public_key
}

resource "digitalocean_droplet" "cp" {
  image     = local.cp_image
  name      = local.cp_name
  region    = local.region
  size      = local.cp_size
  tags      = local.tags
  ssh_keys  = [digitalocean_ssh_key.ssh_key.id]
  user_data = templatefile("../../droplet-u22/control-plane.sh", {})

  # connection {
  #   type        = "ssh"
  #   user        = "root"
  #   private_key = module.key.private_key
  #   host        = self.ipv4_address
  # }
  # provisioner "remote-exec" {

  #   inline = [
  #     "#!/bin/bash",
  #     "while [[ ! \"$a\" == */kubeadm* ]]; do a=$(which kubeadm); sleep 5; done ",
  #     "while [[ -f /etc/kubernetes/admin.conf ]]; do sleep 5; done ",
  #     "sudo kubeadm token create 123456.1234567890123456",
  #   ]
  # }
}


resource "digitalocean_droplet" "worker" {
  image     = local.worker_image
  name      = local.worker_name
  region    = local.region
  size      = local.worker_size
  tags      = local.tags
  ssh_keys  = [digitalocean_ssh_key.ssh_key.id]
  user_data = templatefile("../../droplet-u22/worker.sh", {})

  # connection {
  #   type        = "ssh"
  #   user        = "root"
  #   private_key = module.key.private_key
  #   host        = self.ipv4_address
  # }
  # provisioner "remote-exec" {

  #   inline = [
  #     "#!/bin/bash",
  #     "while [[ ! \"$a\" == */kubeadm* ]]; do a=$(which kubeadm); sleep 5; done ",
  #     "kubeadm join ${digitalocean_droplet.cp.ipv4_address}:6443 123456.1234567890123456 --discovery-token-unsafe-skip-ca-verification",
  #   ]

  # }
}



resource "digitalocean_firewall" "cluster_firewall" {
  name = "${local.project_name}-cluster-firewall"

  tags = local.tags

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Allow inbound for all droplets which has all tags in local.tags
  inbound_rule {
    protocol    = "tcp"
    port_range  = "1-65535"
    source_tags = [digitalocean_tag.cluster-tag.name]
  }

  inbound_rule {
    protocol    = "udp"
    port_range  = "1-65535"
    source_tags = [digitalocean_tag.cluster-tag.name]
  }

  inbound_rule {
    protocol    = "icmp"
    port_range  = "1-65535"
    source_tags = [digitalocean_tag.cluster-tag.name]
  }


  # Allow outbound all
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
