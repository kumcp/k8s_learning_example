output "cp_ip" {
  value = digitalocean_droplet.cp.ipv4_address
}

output "worker_ip" {
  value = digitalocean_droplet.worker.ipv4_address
}
