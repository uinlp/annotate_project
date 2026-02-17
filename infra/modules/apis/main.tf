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

module "docker_build" {
  source  = "terraform-aws-modules/lambda/aws//modules/docker-build"
  version = "7.2.0"

  create_ecr_repo = true
  ecr_repo        = "uinlp_repository"
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
  docker_file_path = "Dockerfile"      # Path to your Dockerfile
  source_path      = local.source_path # Path to your application code
  platform         = "linux/amd64"
  use_image_tag    = false

  triggers = {
    dir_sha = local.dir_sha
  }
}

module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.2.0"

  function_name = "uinlp_lambda_function"
  description   = ""

  create_package = false
  package_type   = "Image"
  architectures  = ["x86_64"]

  image_uri = module.docker_build.image_uri

  # Standard Lambda configurations
  timeout     = 30
  memory_size = 512

  # The module automatically creates the IAM execution role
  attach_cloudwatch_logs_policy = true
}


module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "uinlp_api"
  description   = "UINLP REST API"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  create_domain_name = false
  create_stage       = true
  stage_name         = "$default"
  deploy_stage       = true

  routes = {
    "$default" = {
      integration = {
        uri = module.lambda_function.lambda_function_arn
      }
    }
  }
}
# 3. Grant API Gateway permission to invoke Lambda
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.api_execution_arn}/*/*"
}
