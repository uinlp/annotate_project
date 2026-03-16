provider "aws" {}

module "authentications" {
  source = "../../modules/authentications"
}

module "databases" {
  source = "../../modules/databases"

  user_pool_id         = module.authentications.user_pool_id
  user_pool_client_id  = module.authentications.user_pool_client_id
  user_pool_domain     = module.authentications.user_pool_domain
  user_pool_domain_url = module.authentications.user_pool_domain_url
  user_pool_endpoint   = module.authentications.user_pool_endpoint
  user_pool_authority  = module.authentications.user_pool_authority
}

module "apis" {
  source = "../../modules/apis"

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
  publishes_table_name         = module.databases.uinlp_publishes_table_name
  publishes_table_arn          = module.databases.uinlp_publishes_table_arn

  user_pool_id         = module.authentications.user_pool_id
  user_pool_client_id  = module.authentications.user_pool_client_id
  user_pool_domain     = module.authentications.user_pool_domain
  user_pool_domain_url = module.authentications.user_pool_domain_url
  user_pool_endpoint   = module.authentications.user_pool_endpoint
  user_pool_authority  = module.authentications.user_pool_authority
}
