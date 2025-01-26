resource "aws_eks_cluster" "snapit_eks_cluster" {
  name     = var.cluster_name
  role_arn = "arn:aws:iam::${var.aws_account_id}:role/LabRole"
  version  = var.cluster_version

  vpc_config {
    subnet_ids = concat(var.public_subnet_ids, var.private_subnet_ids)
  }

  tags = {
    Name                                        = var.cluster_name
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    labels = {
      name = "${var.application}"
    }
    name = var.application
  }
}

# resource "aws_eks_addon" "addons" {
#   for_each      = { for addon in var.eks_addons : addon.name => addon }
#   cluster_name  = aws_eks_cluster.snapit_eks_cluster.name
#   addon_name    = each.value.name
#   addon_version = each.value.version

# }
