#!/bin/bash
echo "Terraform init"
terraform init
echo "Terraform destroy"
terraform destroy -auto-approve