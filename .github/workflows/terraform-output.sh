#!/bin/bash
echo "Terraform init"
terraform init
echo "Terraform output"
uinlp_backend_image_uri=$(terraform output -raw uinlp_backend_image_uri)
echo "uinlp_backend_image_uri=$uinlp_backend_image_uri" >> $GITHUB_OUTPUT
echo "uinlp_backend_image_uri=$uinlp_backend_image_uri"
