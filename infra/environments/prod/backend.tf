terraform {
  backend "s3" {
    bucket       = "uinlp-terraform-state"
    key          = "annotate-prod/terraform.tfstate"
    use_lockfile = true
  }
}
