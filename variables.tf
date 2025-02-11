variable "application" {
  description = "Nome da aplicação usada para interpolar nomes de recursos e variavel environment"
  type        = string
}

variable "aws_region" {
  description = "Região AWS que será deployado os recursos"
  type        = string
}

variable "environment" {
  description = "Ambiente de deploy da aplicação. Usado para interpolar nomes junto com variavel application"
  type        = string
}

variable "vpc_cidr_block" {
  description = "Define o bloco de rede alocado ao projeto"
  type        = string
}

variable "public_zone" {
  description = "Define os blocos de rede publicos alocados ao projeto"
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
}

variable "private_zone" {
  description = "Define os blocos de rede privados alocados ao projeto"
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
}

variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
}
variable "aws_account_id" {
  description = "ID da conta AWS"
  type        = string
}
variable "cluster_version" {
  description = "Versão do cluster EKS"
  type        = string
}
variable "nodes_instances_sizes" {
  description = "Tipo das instancias dos nodes do EKS"
  type        = list(string)
}
variable "auto_scale_options" {
  description = "Configurações de auto scaling do cluster EKS"
  type        = map(number)
}
variable "ingress_nginx_name" {
  description = "Nome do ingress controller NGINX"
  type        = string
}
variable "eks_addons" {
  description = "Addons do EKS"
  type = list(object({
    name    = string
    version = string
  }))

}
variable "api_gateway_configuration" {
  description = "Configurações do API Gateway"
  type = object({
    api_type                     = string
    api_endpoint_type            = list(string)
    api_key_source               = string
    disable_execute_api_endpoint = bool
    api_gateway_policy           = string
    deploy_api_stage_name        = string

  })
}
variable "api_gateway_endpoint_configuration" {}
variable "ingress_nginx_service" {
  description = "Nome do serviço do ingress controller NGINX"
  type        = string
}
variable "authorization_config" {
  description = "Configurações de autorização do API Gateway"
  type = list(object({
    is_there_authorizer = bool
    authorization_name  = string
    authorization_type  = string
    identity_source     = string
  }))
}

variable "buckets_sufix_name" {
  type = set(string)
}

variable "rabbitmq_name" {
  type = string
}
