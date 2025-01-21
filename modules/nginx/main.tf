resource "helm_release" "ingress_nginx" {
  name       = var.ingress_nginx_name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = var.ingress_nginx_name
  namespace  = "kube-system"
  values = [
    file("${path.module}/values.yaml")
  ]

}
