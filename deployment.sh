#!/usr/bin/env bash
set -e

# Init Terraform
terraform init

# Plan Terraform
terraform plan -out=tfplan

# Automatically apply the Terraform plan
terraform apply -auto-approve tfplan

echo ""
echo "-------"
echo "Deployment completed successfully!"
echo "Web App URL: https://$(terraform output -raw webapp_url)/"
echo "SQL Server FQDN: $(terraform output -raw sql_fqdn)"
echo "Base de Dados:   carsdb"
echo "Utilizador SQL:  sqladminuser@carsappsqlserver"
echo "-------"
