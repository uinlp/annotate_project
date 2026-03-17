#====================================
# Cognito User Pool
#====================================
data "aws_region" "current" {}

resource "aws_cognito_user_pool" "user_pool" {
  name                     = "uinlp-user-pool"
  auto_verified_attributes = ["email"]
  alias_attributes         = ["email", "preferred_username"]

  username_configuration {
    case_sensitive = false
  }
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = true
  }
  schema {
    name                = "email"
    required            = true
    attribute_data_type = "String"
    string_attribute_constraints {
      min_length = 0
      max_length = 256
    }
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name                                 = "uinlp-user-pool-client"
  user_pool_id                         = aws_cognito_user_pool.user_pool.id
  allowed_oauth_flows_user_pool_client = true
  callback_urls                        = ["https://api.uinlp.org.ng/oauth2/callback", "http://localhost:3000/oauth2/callback"]
  logout_urls                          = ["https://api.uinlp.org.ng/oauth2/logout", "http://localhost:3000/oauth2/logout"]
  default_redirect_uri                 = "https://api.uinlp.org.ng/oauth2/callback"
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  supported_identity_providers         = ["COGNITO"]
}

resource "aws_cognito_managed_login_branding" "client" {
  client_id    = aws_cognito_user_pool_client.client.id
  user_pool_id = aws_cognito_user_pool.user_pool.id

  use_cognito_provided_values = true
}
resource "aws_cognito_user_pool_domain" "user_pool_domain" {
  user_pool_id          = aws_cognito_user_pool.user_pool.id
  domain                = "uinlp"
  managed_login_version = 2
}
