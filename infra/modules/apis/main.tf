# IAM role for Lambda execution
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "uinlp" {
  name               = "uinlp_lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "uinlp_basic_execution" {
  role       = aws_iam_role.uinlp.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "uinlp_ecr_read" {
  role       = aws_iam_role.uinlp.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_ecr_repository" "uinlp_repository" {
  name                 = "uinlp-repository"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_lambda_function" "uinlp" {
  function_name = "uinlp_lambda_function"
  role          = aws_iam_role.uinlp.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.uinlp_repository.repository_url}:latest"

#   image_config {
#     entry_point = ["/lambda-entrypoint.sh"]
#     command     = ["app.handler"]
#   }

  memory_size = 512
  timeout     = 30

  architectures = ["arm64"] # Graviton support for better price/performance
}