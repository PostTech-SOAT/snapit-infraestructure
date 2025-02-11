locals {
  data_lambda_authorizer = data.aws_lambda_function.admin
}

module "network" {
  source = "./modules/network"

  application = var.application
  aws_region  = var.aws_region
  environment = var.environment

  vpc_cidr_block = var.vpc_cidr_block
  public_zone    = var.public_zone
  private_zone   = var.private_zone
}

module "eks" {
  source = "./modules/kubernetes"

  application           = var.application
  public_subnet_ids     = module.network.public_subnet_ids
  private_subnet_ids    = module.network.private_subnet_ids
  auto_scale_options    = var.auto_scale_options
  cluster_name          = var.cluster_name
  aws_account_id        = var.aws_account_id
  cluster_version       = var.cluster_version
  nodes_instances_sizes = var.nodes_instances_sizes
  eks_addons            = var.eks_addons

}

module "nginx" {
  source = "./modules/nginx"

  ingress_nginx_name = var.ingress_nginx_name

  depends_on = [module.eks, module.network]
}

module "rabbitmq" {
  source = "./modules/rabbitmq"

  rabbitmq_name = var.rabbitmq_name

  depends_on = [module.network]

}

module "api_gateway" {
  source = "./modules/api-gateway"

  application                        = var.application
  aws_account_id                     = var.aws_account_id
  api_gateway_configuration          = var.api_gateway_configuration
  api_gateway_vpc_endpoint_ids       = null
  api_gateway_endpoint_configuration = var.api_gateway_endpoint_configuration
  loadbalancer_uri                   = data.kubernetes_service.ingress_nginx.status.0.load_balancer.0.ingress.0.hostname
  lambda_uri                         = null
  lambda_authorizer_config = {
    name           = "${local.data_lambda_authorizer.function_name}"
    authorizer_uri = "${local.data_lambda_authorizer.invoke_arn}"
  }
  authorization_config = var.authorization_config

  depends_on = [module.nginx]

}

module "bucket" {
  source = "./modules/bucket"

  application        = var.application
  buckets_sufix_name = var.buckets_sufix_name

}
