resource "aws_eks_node_group" "cluster" {
  cluster_name    = aws_eks_cluster.snapit_eks_cluster.name
  node_group_name = format("%s-nodes", var.cluster_name)
  node_role_arn   = "arn:aws:iam::${var.aws_account_id}:role/LabRole"
  subnet_ids      = var.private_subnet_ids
  instance_types  = var.nodes_instances_sizes

  scaling_config {
    desired_size = lookup(var.auto_scale_options, "desired")
    max_size     = lookup(var.auto_scale_options, "max")
    min_size     = lookup(var.auto_scale_options, "min")
  }

  launch_template {
    id      = aws_launch_template.eks_node_launch_template.id
    version = "$Latest"
  }

  capacity_type = "SPOT"

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  depends_on = [aws_eks_cluster.snapit_eks_cluster, aws_launch_template.eks_node_launch_template]

  lifecycle {
    ignore_changes = [launch_template]
  }
}

resource "aws_launch_template" "eks_node_launch_template" {
  name_prefix = "eks-node-launch-template"

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = format("%s-instance", var.cluster_name)
    }
  }
}
