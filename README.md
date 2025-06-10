# Cloud Computing Project

This project is a simple PHP web application, provisioned and managed using Terraform on Microsoft Azure.

## Project Structure

- `app/` — PHP application source code
  - `config.php`, `create.php`, `delete.php`, `edit.php`, `index.php`
  - `styles/` — CSS stylesheets
- `sql/schema.sql` — Database schema script
- `main.tf`, `providers.tf`, `variables.tf`, `terraform.tfvars` — Terraform configuration files
- `deployment.bat` — Batch script to automate deployment with Terraform
- `app.zip` — Zipped version of the application for deployment
- `requirements/` — Documentation and project requirements

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed
- [Azure](https://portal.azure.com/) account
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed and authenticated
- [PHP](https://www.php.net/downloads) installed (for local development)

## How to Deploy

1. **Configure variables**
   - Edit the `terraform.tfvars` file with values appropriate for your environment.
   - **Mandatory variable:**
     - `subscription_id` — Your Azure subscription ID (required for deployment)
   - Example:
     ```hcl
     subscription_id = "your-azure-subscription-id"
     ```

2. **Run the deployment script**
   - In PowerShell, run:
     ```powershell
     .\deployment.bat
     ```

3. **Access the application**
   - After deployment, access the App Service URL provided by Azure.

## Database

- The `sql/schema.sql` script contains the database structure used by the application.
- Database provisioning is handled by Terraform.

## Terraform Structure

- `main.tf` — Main resources (App Service, Database, etc.)
- `providers.tf` — Azure provider configuration
- `variables.tf` — Input variables
- `terraform.tfvars` — Variable values

## Notes

- It is recommended to use virtual networks (VNet) and private endpoints for better security.
- Store sensitive secrets in Azure Key Vault.

## License

This project is for educational purposes only.
