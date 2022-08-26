output "eksctl_instance_ip" {
  value = module.eksctl_instance.instance[*].public_ip
}
