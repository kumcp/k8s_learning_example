output "control_plane_ip" {
  value = module.control_plane.instance.public_ip
}


output "worker_node_ip" {
  value = module.worker.instance.public_ip
}
