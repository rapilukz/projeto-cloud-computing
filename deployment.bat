@echo off
REM Init Terraform
terraform init

REM Plan Terraform
terraform plan -out=tfplan

REM Automatically apply the Terraform plan
terraform apply -auto-approve tfplan
