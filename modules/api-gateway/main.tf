locals {
  api_name = "api-${var.application}-${var.api_gateway_configuration.api_type}"

  method_configuration = flatten([
    for api_conf in var.api_gateway_endpoint_configuration : [
      for method_conf in api_conf.method_endpoint_configuration : {
        path_part            = api_conf.path_part
        is_there_path_parent = api_conf.is_there_path_parent
        its_only_parent_path = api_conf.its_only_parent_path
        http_method          = method_conf.http_method
        config               = method_conf
      }
    ]
  ])
}

resource "aws_api_gateway_rest_api" "api" {
  name                         = local.api_name
  api_key_source               = var.api_gateway_configuration.api_key_source
  disable_execute_api_endpoint = var.api_gateway_configuration.disable_execute_api_endpoint
  policy                       = var.api_gateway_configuration.api_gateway_policy

  endpoint_configuration {
    types            = [for values in var.api_gateway_configuration.api_endpoint_type : upper(values)]
    vpc_endpoint_ids = var.api_gateway_configuration.api_type == "private" ? var.api_gateway_vpc_endpoint_ids : null
  }

  tags = {
    Name = local.api_name
    Tier = "${var.api_gateway_configuration.api_type}"
  }
}

resource "aws_api_gateway_stage" "deploy_stage" {
  deployment_id = aws_api_gateway_deployment.deploy_api.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = var.api_gateway_configuration.deploy_api_stage_name
}

resource "aws_api_gateway_resource" "create_resource" {
  for_each = { for idx, config in var.api_gateway_endpoint_configuration : "${config.path_part}[${idx}]" => config if !config.is_there_path_parent }

  path_part   = each.value.path_part
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_resource" "parent_resource" {
  for_each = { for idx, config in var.api_gateway_endpoint_configuration : "${config.path_part}[${idx}]" => config if config.is_there_path_parent }

  path_part   = each.value.child_path
  parent_id   = aws_api_gateway_resource.create_resource[each.value.path_parent].id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "method_request" {
  for_each = {
    for idx, config in local.method_configuration :
    "${config.path_part}_${config.http_method}[${idx}]" => config if !lookup(config, "its_only_parent_path", false)
  }

  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = each.value.is_there_path_parent ? aws_api_gateway_resource.parent_resource[each.value.path_part].id : aws_api_gateway_resource.create_resource[each.value.path_part].id
  http_method   = each.value.http_method
  authorization = each.value.config.authorization
  authorizer_id = each.value.config.is_there_authorization ? aws_api_gateway_authorizer.this[each.value.config.authorization_name].id : null

  request_parameters = {
    "method.request.path.${each.value.config.proxy_path}" = each.value.config.is_method_path_proxy ? true : null

  }

  depends_on = [
    aws_api_gateway_resource.create_resource,
    aws_api_gateway_authorizer.this
  ]
}

resource "aws_api_gateway_integration" "integration_request" {
  for_each = {
    for idx, config in local.method_configuration :
    "${config.path_part}_${config.http_method}[${idx}]" => config if !lookup(config, "its_only_parent_path", false)
  }

  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_method.method_request[each.key].resource_id
  http_method             = aws_api_gateway_method.method_request[each.key].http_method
  integration_http_method = each.value.config.integration_http_method
  type                    = each.value.config.integration_type
  uri                     = each.value.config.is_lambda_trigger ? var.lambda_uri : each.value.config.is_ecs_endpoint ? "http://${var.loadbalancer_uri}/${each.value.config.app_endpoint_path}" : ""
  passthrough_behavior    = each.value.config.passthrough_behavior

  request_parameters = {
    "integration.request.path.${each.value.config.proxy_path}"                                  = each.value.config.is_method_path_proxy ? "method.request.path.${each.value.config.proxy_path}" : null,
    (each.value.config.is_async_call ? "integration.request.header.X-Amz-Invocation-Type" : "") = (each.value.config.is_async_call ? "'Event'" : null)
  }

  depends_on = [aws_api_gateway_method.method_request, aws_api_gateway_resource.create_resource]
}

resource "aws_api_gateway_integration_response" "integration_response_200" {
  for_each = {
    for idx, config in local.method_configuration :
    "${config.path_part}_${config.http_method}[${idx}]" => config if !(lookup(config, "is_method_path_proxy", false) || lookup(config, "its_only_parent_path", false))
  }

  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = each.value.is_there_path_parent ? aws_api_gateway_resource.parent_resource[each.value.path_part].id : aws_api_gateway_resource.create_resource[each.value.path_part].id
  http_method = aws_api_gateway_method.method_request[each.key].http_method
  status_code = aws_api_gateway_method_response.response_200[each.key].status_code

  response_templates = {
    "application/json" = ""
  }

  depends_on = [aws_api_gateway_method.method_request, aws_api_gateway_resource.create_resource]
}

resource "aws_api_gateway_method_response" "response_200" {
  for_each = {
    for idx, config in local.method_configuration :
    "${config.path_part}_${config.http_method}[${idx}]" => config if !lookup(config, "its_only_parent_path", false)
  }

  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = each.value.is_there_path_parent ? aws_api_gateway_resource.parent_resource[each.value.path_part].id : aws_api_gateway_resource.create_resource[each.value.path_part].id
  http_method = aws_api_gateway_method.method_request[each.key].http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [aws_api_gateway_method.method_request, aws_api_gateway_resource.create_resource]
}

resource "aws_api_gateway_deployment" "deploy_api" {

  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode([aws_api_gateway_rest_api.api.body, aws_api_gateway_integration.integration_request]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_method.method_request,
    aws_api_gateway_integration.integration_request,
    aws_api_gateway_resource.create_resource
  ]
}

resource "aws_lambda_permission" "apigw_lambda" {
  for_each = {
    for idx, config in local.method_configuration :
    "${config.path_part}_${config.http_method}" => config if local.method_configuration[idx].config.is_lambda_trigger
  }

  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = each.value.config.lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/${each.value.config.http_method}/${each.value.path_part}"

  depends_on = [aws_api_gateway_integration.integration_request]
}

resource "aws_api_gateway_authorizer" "this" {
  for_each = {
    for conf in var.authorization_config : conf.authorization_name => conf if conf.is_there_authorizer
  }

  name                   = each.value.authorization_name
  rest_api_id            = aws_api_gateway_rest_api.api.id
  authorizer_uri         = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:${var.aws_account_id}:function:${each.value.authorization_name}/invocations"
  type                   = each.value.authorization_type
  identity_source        = each.value.identity_source
  authorizer_credentials = "arn:aws:iam::${var.aws_account_id}:role/LabRole"
}
