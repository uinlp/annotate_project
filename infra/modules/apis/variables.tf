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
