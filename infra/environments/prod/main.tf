provider "aws" {
  region = "af-south-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "databases" {
  source = "../../modules/databases"
}

module "apis" {
  source = "../../modules/apis"

  providers = {
    aws.us_east_1 = aws.us_east_1
  }

  datasets_table_name          = module.databases.uinlp_datasets_table_name
  assets_table_name            = module.databases.uinlp_assets_table_name
  datasets_objects_bucket_name = module.databases.datasets_objects_bucket_name
  datasets_temp_bucket_name    = module.databases.datasets_temp_bucket_name
  datasets_table_arn           = module.databases.uinlp_datasets_table_arn
  assets_table_arn             = module.databases.uinlp_assets_table_arn
  datasets_objects_bucket_arn  = module.databases.datasets_objects_bucket_arn
  datasets_temp_bucket_arn     = module.databases.datasets_temp_bucket_arn
  assets_publishes_bucket_name = module.databases.assets_publishes_bucket_name
  assets_publishes_bucket_arn  = module.databases.assets_publishes_bucket_arn
}
