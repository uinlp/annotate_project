terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

data "aws_ecr_authorization_token" "token" {}

provider "docker" {
  registry_auth {
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
    address  = data.aws_ecr_authorization_token.token.proxy_endpoint
  }
}

# ===================================
# Docker Build: UINLP Backend
# ===================================
module "docker_build" {
  source  = "terraform-aws-modules/lambda/aws//modules/docker-build"
  version = "7.2.0"

  create_ecr_repo = true
  ecr_repo        = "uinlp-backend-repository"
  ecr_repo_lifecycle_policy = jsonencode({
    "rules" : [
      {
        "rulePriority" : 1,
        "description" : "Keep only the last 2 images",
        "selection" : {
          "tagStatus" : "any",
          "countType" : "imageCountMoreThan",
          "countNumber" : 2
        },
        "action" : {
          "type" : "expire"
        }
      }
    ]
  })
  docker_file_path = local.docker_file_path
  source_path      = local.source_path
  platform         = "linux/amd64"
  use_image_tag    = false

  triggers = {
    dir_sha = local.dir_sha
  }
}


# ===================================
# Lambda Function: UINLP Backend
# ===================================
module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.2.0"

  function_name  = "uinlp-backend-function"
  description    = ""
  create_package = false
  create_role    = true
  package_type   = "Image"
  architectures  = ["x86_64"]

  image_uri = module.docker_build.image_uri

  environment_variables = {
    DATASETS_TABLE_NAME          = var.datasets_table_name
    ASSETS_TABLE_NAME            = var.assets_table_name
    DATASETS_OBJECTS_BUCKET_NAME = var.datasets_objects_bucket_name
    DATASETS_TEMP_BUCKET_NAME    = var.datasets_temp_bucket_name
    ASSETS_PUBLISHES_BUCKET_NAME = var.assets_publishes_bucket_name
  }

  # Standard Lambda configurations
  timeout     = 30
  memory_size = 512

  # The module automatically creates the IAM execution role
  attach_cloudwatch_logs_policy = true
}

# Grant lambda function access to the resources
resource "aws_iam_role_policy" "role_policy" {
  role = module.lambda_function.lambda_role_name
  name = "uinlp-backend-role-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "dynamodb:*"
        Effect   = "Allow"
        Resource = var.datasets_table_arn
      },
      {
        Action   = "dynamodb:*"
        Effect   = "Allow"
        Resource = var.assets_table_arn
      },
      {
        Action = "s3:*"
        Effect = "Allow"
        Resource = [
          var.datasets_objects_bucket_arn,
          "${var.datasets_objects_bucket_arn}/*"
        ]
      },
      {
        Action = "s3:*"
        Effect = "Allow"
        Resource = [
          var.datasets_temp_bucket_arn,
          "${var.datasets_temp_bucket_arn}/*"
        ]
      },
      {
        Action = "s3:*"
        Effect = "Allow"
        Resource = [
          var.assets_publishes_bucket_arn,
          "${var.assets_publishes_bucket_arn}/*"
        ]
      }
    ]
  })
}

#====================================
# Cognito User Pool
#====================================
resource "aws_cognito_user_pool" "user_pool" {
  name = "uinlp-user-pool"

  schema {
    name                = "name"
    required            = true
    attribute_data_type = "String"
    string_attribute_constraints {
      min_length = 0
      max_length = 256
    }
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
  username_attributes = ["email"]

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
  user_pool_id    = aws_cognito_user_pool.user_pool.id
  domain          = "api.uinlp.org.ng"
  certificate_arn = data.aws_acm_certificate.uinlp_certificate.arn
}
# ===================================
# API Gateway: UINLP REST API
# ===================================
module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "uinlp-api"
  description   = "UINLP REST API"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  create_domain_name = true
  create_stage       = true
  stage_name         = "$default"
  deploy_stage       = true

  hosted_zone_name            = "uinlp.org.ng"
  domain_name                 = "api.uinlp.org.ng"
  domain_name_certificate_arn = data.aws_acm_certificate.uinlp_certificate.arn

  authorizers = {
    "cognito" = {
      authorizer_type  = "JWT"
      identity_sources = ["$request.header.Authorization"]
      jwt_configuration = {
        audience = [aws_cognito_user_pool_client.client.id]
        issuer   = "https://${aws_cognito_user_pool.user_pool.endpoint}"
      }
    }
  }

  routes = {
    "$default" = {
      integration = {
        uri                    = module.lambda_function.lambda_function_arn
        payload_format_version = "2.0"
      }
    }
  }
}

data "aws_acm_certificate" "uinlp_certificate" {
  domain      = "api.uinlp.org.ng"
  most_recent = true
  statuses    = ["ISSUED"]
}

# Grant API Gateway permission to invoke Lambda
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.api_execution_arn}/*"
}
