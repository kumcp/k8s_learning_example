## To use template_file, you will need to use template provider

locals {
  worker_engine = var.cri_engine
}

data "template_file" "woker_user_data" {
  template = file("../external/${local.worker_engine}/ubuntu20-k8s-worker.sh")

  # You can put some variable here to render
}

module "worker" {
  source           = "../module/ec2_bootstrap"
  bootstrap_script = data.template_file.woker_user_data.rendered

  # security_group_ids = setunion(module.common_sg.public_sg_ids, module.common_sg.specific_sg_ids)
  security_group_ids = concat(module.public_ssh_http.public_sg_ids, module.k8s_cluster_sg.specific_sg_ids)
  keypair_name       = "codestar-group"
  instance_type      = "t2.small"
  name               = "worker"
}

