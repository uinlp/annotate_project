#!/bin/bash
echo "Terraform init"
terraform init
echo "Terraform plan"
terraform plan
echo "Terraform apply"
terraform apply -auto-approve