
locals {
  cluster_name = var.cluster-name
}


resource "aws_kms_key" "cluster_key_new" {
  description = "KMS managed key for ${local.cluster_name}"
}

resource "aws_kms_alias" "cluster_key_alias_new" {
  name          = "alias/${var.key_name}"
  target_key_id = data.aws_kms_alias.cluster_key_alias
}


