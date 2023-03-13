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
  region       = "sgp1"
  cp_image     = "ubuntu-22-10-x64"
  cp_size      = "s-2vcpu-2gb"
  worker_image = "ubuntu-22-10-x64"
  worker_size  = "s-2vcpu-2gb"

  tags         = [digitalocean_tag.cluster-tag.name]
  project_name = "sm-cluster"
}


resource "digitalocean_droplet" "cp" {
  image     = local.cp_image
  name      = "control-plane"
  region    = local.region
  size      = local.cp_size
  tags      = local.tags
  user_data = templatefile("../../droplet-u22/control-plane.sh", {})
}


resource "digitalocean_droplet" "worker" {
  image     = local.worker_image
  name      = "worker"
  region    = local.region
  size      = local.worker_size
  tags      = local.tags
  user_data = templatefile("../../droplet-u22/worker.sh", {})
}



resource "digitalocean_firewall" "cluster_firewall" {
  name = "${local.project_name}-cluster-firewall"

  tags = local.tags

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Allow inbound for all droplets which has tags k8s
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
