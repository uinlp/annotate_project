output "uinlp_datasets_table_name" {
  value = module.uinlp_datasets.dynamodb_table_id
}

output "uinlp_datasets_table_arn" {
  value = module.uinlp_datasets.dynamodb_table_arn
}

output "uinlp_assets_table_name" {
  value = module.uinlp_assets.dynamodb_table_id
}

output "uinlp_assets_table_arn" {
  value = module.uinlp_assets.dynamodb_table_arn
}

output "datasets_objects_bucket_name" {
  value = module.datasets_objects_bucket.s3_bucket_id
}

output "datasets_objects_bucket_arn" {
  value = module.datasets_objects_bucket.s3_bucket_arn
}

output "datasets_temp_bucket_name" {
  value = module.datasets_temp_bucket.s3_bucket_id
}

output "datasets_temp_bucket_arn" {
  value = module.datasets_temp_bucket.s3_bucket_arn
}

output "assets_publishes_bucket_name" {
  value = module.assets_publishes_bucket.s3_bucket_id
}

output "assets_publishes_bucket_arn" {
  value = module.assets_publishes_bucket.s3_bucket_arn
}
