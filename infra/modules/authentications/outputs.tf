output "user_pool_id" {
  value = aws_cognito_user_pool.user_pool.id
}

output "user_pool_client_id" {
  value = aws_cognito_user_pool_client.client.id
}

output "user_pool_domain" {
  value = aws_cognito_user_pool_domain.user_pool_domain.domain
}

output "user_pool_domain_url" {
  value = "https://${aws_cognito_user_pool_domain.user_pool_domain.domain}.auth.${data.aws_region.current.name}.amazoncognito.com"
}

output "user_pool_endpoint" {
  value = aws_cognito_user_pool.user_pool.endpoint
}

output "user_pool_authority" {
  value = "https://${aws_cognito_user_pool.user_pool.endpoint}"
}
