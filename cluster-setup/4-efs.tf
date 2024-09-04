resource "aws_efs_file_system" "eks" {
  creation_token = "eks"

  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true

  # lifecycle_policy {
  #   transition_to_ia = "AFTER_30_DAYS"
  # }

  tags = {
    Name = "eks-microservices-demo"
  }
}

locals {
  subnet_map = { for subnet in module.vpc.private_subnets : subnet => subnet }
}

resource "aws_efs_mount_target" "zone" {
  for_each = local.subnet_map

  file_system_id  = aws_efs_file_system.eks.id
  subnet_id       = each.key
  security_groups = [module.eks_blueprints.cluster_primary_security_group_id]
}

resource "kubernetes_storage_class_v1" "efs" {
  metadata {
    name = "efs"
  }

  storage_provisioner = "efs.csi.aws.com"

  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.eks.id
    directoryPerms   = "700"
  }

  mount_options = ["iam"]

  depends_on = [module.eks_blueprints_addons]
}
