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
# DynamoDB Tables
# ===================================
module "uinlp_datasets" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name     = "uinlp-datasets"
  hash_key = "id"

  attributes = [
    {
      name = "id"
      type = "S"
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}


module "uinlp_assets" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name     = "uinlp-assets"
  hash_key = "id"

  attributes = [
    {
      name = "id"
      type = "S"
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}

# ===================================
# S3 Buckets
# ===================================
module "datasets_objects_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket_prefix = "uinlp-datasets-objects"
  acl           = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"
}

module "datasets_temp_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket_prefix = "uinlp-datasets-temp"
  acl           = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"
}

# ===================================
# ECR Repository
# ===================================
module "docker_build" {
  source  = "terraform-aws-modules/lambda/aws//modules/docker-build"
  version = "7.2.0"

  create_ecr_repo = true
  ecr_repo        = "uinlp-datasets-objects-maker-repository"
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
# Lambda Function: Datasets Objects Maker
# ===================================
module "datasets_objects_maker" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.2.0"

  function_name  = "datasets-objects-maker"
  description    = ""
  create_package = false
  create_role    = true
  package_type   = "Image"
  architectures  = ["x86_64"]

  image_uri = module.docker_build.image_uri

  environment_variables = {
    DATASETS_TABLE_NAME          = module.uinlp_datasets.dynamodb_table_id
    ASSETS_TABLE_NAME            = module.uinlp_assets.dynamodb_table_id
    DATASETS_OBJECTS_BUCKET_NAME = module.datasets_objects_bucket.s3_bucket_id
    DATASETS_TEMP_BUCKET_NAME    = module.datasets_temp_bucket.s3_bucket_id
  }

  # Standard Lambda configurations
  timeout     = 30
  memory_size = 512

  # The module automatically creates the IAM execution role
  attach_cloudwatch_logs_policy = true
}
# Grant lambda function access to the resources
resource "aws_iam_role_policy" "role_policy" {
  role = module.datasets_objects_maker.lambda_role_name
  name = "uinlp-datasets-objects-maker-role-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "dynamodb:*"
        Effect   = "Allow"
        Resource = module.uinlp_datasets.dynamodb_table_arn
      },
      {
        Action   = "dynamodb:*"
        Effect   = "Allow"
        Resource = module.uinlp_assets.dynamodb_table_arn
      },
      {
        Action   = "s3:*"
        Effect   = "Allow"
        Resource = module.datasets_objects_bucket.s3_bucket_arn
      },
      {
        Action   = "s3:*"
        Effect   = "Allow"
        Resource = module.datasets_temp_bucket.s3_bucket_arn
      },
    ]
  })
}


# ===================================
# S3 Bucket Notification
# ===================================
module "datasets_temp_notification" {
  source = "terraform-aws-modules/s3-bucket/aws//modules/notification"

  bucket = module.datasets_temp_bucket.s3_bucket_id

  lambda_notifications = {
    datasets_objects_maker = {
      function_arn  = module.datasets_objects_maker.lambda_function_arn
      function_name = module.datasets_objects_maker.lambda_function_name
      events        = ["s3:ObjectCreated:Put", "s3:ObjectCreated:Post"]
    }
  }
  create_sqs_policy = false
  create_sns_policy = false
}
