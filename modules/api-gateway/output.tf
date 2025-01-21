output "module" {
  value = [ for a in aws_api_gateway_resource.create_resource : a.id]
}

output "name" {
  value = aws_api_gateway_rest_api.api.root_resource_id
  
}