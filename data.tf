data "kubernetes_service" "ingress_nginx" {
  metadata {
    name      = var.ingress_nginx_service
    namespace = "kube-system"
  }

  depends_on = [module.nginx]
}
data "aws_lambda_function" "admin" {
  function_name = "ValidarTokenAuthorizer"
}
