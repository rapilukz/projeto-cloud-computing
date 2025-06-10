# Init Terraform
terraform init

# Plan Terraform
terraform plan -out=tfplan

# Automatically apply the Terraform plan
terraform apply -auto-approve tfplan