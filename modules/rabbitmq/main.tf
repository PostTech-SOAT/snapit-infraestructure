resource "helm_release" "rabbitmq" {
  name       = var.rabbitmq_name
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart      = "rabbitmq"
  namespace  = "kube-system"
  values = [
    file("${path.module}/values.yaml")
  ]

}
