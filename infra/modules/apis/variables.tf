variable "project_name" {
  default = "uinlp"
  type    = string
}

variable "datasets_table_name" {
  type = string
}

variable "datasets_table_arn" {
  type = string
}

variable "assets_table_name" {
  type = string
}

variable "assets_table_arn" {
  type = string
}

variable "publishes_table_name" {
  type = string
}

variable "publishes_table_arn" {
  type = string
}

variable "datasets_objects_bucket_name" {
  type = string
}

variable "datasets_objects_bucket_arn" {
  type = string
}

variable "datasets_temp_bucket_name" {
  type = string
}

variable "datasets_temp_bucket_arn" {
  type = string
}

variable "assets_publishes_bucket_name" {
  type = string
}

variable "assets_publishes_bucket_arn" {
  type = string
}

variable "user_pool_id" {
  type = string
}

variable "user_pool_client_id" {
  type = string
}

variable "user_pool_domain" {
  type = string
}

variable "user_pool_domain_url" {
  type = string
}

variable "user_pool_endpoint" {
  type = string
}

variable "user_pool_authority" {
  type = string
}
