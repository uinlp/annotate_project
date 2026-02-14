terraform {
  backend "s3" {
    bucket       = "uinlp-terraform-state"
    key          = "annotate-prod/terraform.tfstate"
    use_lockfile = true
  }
  # required_providers {
  #   docker = {
  #     source  = "kreuzwerker/docker",
  #     version = "~> 3.0"
  #   }
  #   aws = {
  #     source  = "hashicorp/aws",
  #     version = "~> 5.0"
  #   }
  # }
}
