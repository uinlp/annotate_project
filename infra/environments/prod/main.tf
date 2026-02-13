provider "aws" {}

module "apis" {
  source = "../../modules/apis"
}

# module "databases" {
#   source = "../../modules/databases"
# }
