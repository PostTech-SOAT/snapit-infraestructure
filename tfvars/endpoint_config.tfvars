api_gateway_endpoint_configuration = [/*{
  create_apigateway_resource = true
  is_there_path_parent       = false
  its_only_parent_path       = false
  path_parent                = ""
  path_part                  = "upload"
  child_path                 = ""
  method_endpoint_configuration = [{
    lambda_name             = ""
    is_method_path_proxy    = false
    proxy_path              = ""
    is_ecs_endpoint         = true
    is_lambda_trigger       = false
    is_async_call           = false
    app_endpoint_path       = "v1/videos/upload"
    http_method             = "POST"
    authorization           = "CUSTOM"
    is_there_authorization  = true
    authorization_name      = "ValidarTokenAuthorizer"
    integration_http_method = "POST"
    integration_type        = "HTTP_PROXY"
    passthrough_behavior    = "WHEN_NO_TEMPLATES"
    uri                     = ""
    port                    = ""
  }]
  }, */ {
  create_apigateway_resource = true
  is_there_path_parent       = false
  its_only_parent_path       = true
  path_parent                = ""
  path_part                  = "videos"
  child_path                 = ""
  method_endpoint_configuration = [{
    lambda_name             = ""
    is_method_path_proxy    = true
    proxy_path              = ""
    is_ecs_endpoint         = false
    is_lambda_trigger       = false
    is_async_call           = false
    app_endpoint_path       = ""
    http_method             = ""
    authorization           = "CUSTOM"
    is_there_authorization  = false
    authorization_name      = "ValidarTokenAuthorizer"
    integration_http_method = ""
    integration_type        = "HTTP_PROXY"
    passthrough_behavior    = "WHEN_NO_TEMPLATES"
    uri                     = ""
    port                    = ""
  }]
  }, {
  create_apigateway_resource = true
  is_there_path_parent       = true
  its_only_parent_path       = true
  path_parent                = "videos[0]"
  path_part                  = "{id}"
  child_path                 = "{id}"
  method_endpoint_configuration = [{
    lambda_name             = ""
    is_method_path_proxy    = true
    proxy_path              = ""
    is_ecs_endpoint         = false
    is_lambda_trigger       = false
    is_async_call           = false
    app_endpoint_path       = ""
    http_method             = ""
    authorization           = "CUSTOM"
    is_there_authorization  = false
    authorization_name      = "ValidarTokenAuthorizer"
    integration_http_method = ""
    integration_type        = "HTTP_PROXY"
    passthrough_behavior    = "WHEN_NO_TEMPLATES"
    uri                     = ""
    port                    = ""
  }]
  # }, {
  # create_apigateway_resource = true
  # is_there_path_parent       = true
  # its_only_parent_path       = false
  # path_parent                = "{id}[1]"
  # path_part                  = "download"
  # child_path                 = "download"
  # method_endpoint_configuration = [{
  #   lambda_name             = ""
  #   is_method_path_proxy    = false
  #   proxy_path              = ""
  #   is_ecs_endpoint         = true
  #   is_lambda_trigger       = false
  #   is_async_call           = false
  #   app_endpoint_path       = "v1/videos/{id}/download"
  #   http_method             = "GET"
  #   authorization           = "CUSTOM"
  #   is_there_authorization  = true
  #   authorization_name      = "ValidarTokenAuthorizer"
  #   integration_http_method = "GET"
  #   integration_type        = "HTTP_PROXY"
  #   passthrough_behavior    = "WHEN_NO_TEMPLATES"
  #   uri                     = ""
  #   port                    = ""
  # }]
  # }
  }
]
