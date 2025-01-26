##############################################################################
#                      GENERAL                                               #
##############################################################################

application = "snapit"
environment = "dev"
aws_region  = "us-east-1"

##############################################################################
#                      NETWORK                                               #
##############################################################################

vpc_cidr_block = "10.200.0.0/24"
public_zone = {
  public_1a = {
    cidr_block        = "10.200.0.0/26"
    availability_zone = "a"
  },
  public_1c = {
    cidr_block        = "10.200.0.64/26"
    availability_zone = "c"
  }
}
private_zone = {
  private_1a = {
    cidr_block        = "10.200.0.128/26"
    availability_zone = "a"
  },
  private_1c = {
    cidr_block        = "10.200.0.192/26"
    availability_zone = "c"
  }
}

##############################################################################
#                      KUBERNETES                                            #
##############################################################################

auto_scale_options = {
  min     = 2
  max     = 3
  desired = 2
}
cluster_name          = "snapit-eks-cluster"
aws_account_id        = "706020885302"
cluster_version       = "1.30"
nodes_instances_sizes = ["t3.medium"]

eks_addons = [
  {
    name    = "aws-ebs-csi-driver"
    version = "v1.37.0-eksbuild.1"
  }
]

##############################################################################
#                      NGINX                                                 #
##############################################################################
ingress_nginx_name = "ingress-nginx"


##############################################################################
#                      API GATEWAY                                           #
##############################################################################
ingress_nginx_service = "ingress-nginx-controller"

api_gateway_configuration = {
  api_type                     = "public"
  api_endpoint_type            = ["edge"]
  api_key_source               = null
  disable_execute_api_endpoint = false
  api_gateway_policy           = null
  deploy_api_stage_name        = "deploy"
  is_there_authorizer          = true
}

authorization_config = [{
  is_there_authorizer = true
  authorization_name  = "BuscarClienteCognito"
  authorization_type  = "REQUEST"
  identity_source     = "method.request.querystring.cpf"
  }, {
  is_there_authorizer = true
  authorization_name  = "BuscarAdminCognito"
  authorization_type  = "REQUEST"
  identity_source     = "method.request.querystring.cpf"
}]

##############################################################################
#                      BUCKET                                                #
##############################################################################

buckets_sufix_name = ["history", "uploads", "frames"]
