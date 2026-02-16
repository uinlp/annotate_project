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
    rules = [{
      rulePriority = 1,
      description  = "Keep last 5 images",
      selection    = { tagStatus = "tagged", tagPrefixList = ["v"], countType = "imageCountMoreThan", countNumber = 5 },
      action       = { type = "expire" }
    }]
  })
  docker_file_path = "Dockerfile"                               # Path to your Dockerfile
  source_path      = abspath("${path.module}/../../../backend") # Path to your application code
  platform         = "linux/amd64"
  image_tag        = "v1.0.1"
}

module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.2.0"

  function_name = "uinlp_lambda_funcion"
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
