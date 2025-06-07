variable "subscription_id" {}

provider "azurerm" {
    features {}
    subscription_id = var.subscription_id
}

#############################################
# 1) Resource Group + Random Suffix
#############################################

# Create Base Resource Group
resource "azurerm_resource_group" "rg" {
    name     = "${var.prefix}-rg"
    location = var.location
}

# Generate a random suffix for resource names
resource "random_string" "suffix" {
    length  = 6
    upper   = false
    special = false
}

locals {
    unique_suffix = random_string.suffix.result
}

#############################################
# 2) Azure Database for SQL Server + DB
#############################################

# Setup Azure SQL Server
resource "azurerm_mssql_server" "sql_server" {
    name                         = "carsappsqlserver-${local.unique_suffix}"
    resource_group_name          = azurerm_resource_group.rg.name
    location                     = azurerm_resource_group.rg.location
    version                      = "12.0"
    administrator_login          = var.db_admin_username
    administrator_login_password = var.db_admin_password

    depends_on = [ azurerm_resource_group.rg ]
}

resource "azurerm_mssql_database" "db" {
    name           = var.db_name
    server_id      = azurerm_mssql_server.sql_server.id
    sku_name       = "Basic"
    collation      = "SQL_Latin1_General_CP1_CI_AS"
    max_size_gb    = 2

    depends_on = [ azurerm_mssql_server.sql_server ]
}

resource "azurerm_mssql_firewall_rule" "allow_all" {
    name                = "AllowLocal"
    server_id           = azurerm_mssql_server.sql_server.id
    start_ip_address    = "0.0.0.0"
    end_ip_address      = "255.255.255.255"

    depends_on = [ azurerm_mssql_server.sql_server ]
}

#############################################
# 3) App Service Plan (Linux) + Web App PHP
#############################################

# App Serivice Plan (Linux)
resource "azurerm_service_plan" "asp" {
    name                = "${var.prefix}-asp"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    os_type             = "Linux"
    sku_name            = "B1"  # Basic tier
}


# Web App Php (App Service) - runtime Linux + PHP 8.0
resource "azurerm_linux_web_app" "webapp" {
    name                = "${var.prefix}-webapp"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    service_plan_id     = azurerm_service_plan.asp.id
    # Configs for PHP
    site_config {
        application_stack {
            php_version = "8.0"
        }
    }

    app_settings = {
        "DB_HOST"     = azurerm_mssql_server.sql_server.fully_qualified_domain_name
        "DB_NAME"     = azurerm_mssql_database.db.name
        "DB_USER"     = "${var.db_admin_username}@${azurerm_mssql_server.sql_server.name}"
        "DB_PASSWORD" = var.db_admin_password
        
        # Necessary for "config.zip" via Azure CLI
        "WEBSITE_RUN_FROM_PACKAGE" = "1"
    }
}

#############################################
# 4) Packaging & Deploy of PHP Code
#############################################

# Zip the "app/" directory to deploy the web app
data "archive_file" "app_zip" {
    type        = "zip"
    source_dir  = "${path.module}/app"
    output_path = "${path.module}/app.zip"
}

# Upload the zip file to the web app
resource "null_resource" "deploy_code" {
    depends_on = [
        azurerm_linux_web_app.webapp,
        data.archive_file.app_zip
    ]

    provisioner "local-exec" {
        command = <<EOT
            az webapp deploy --resource-group ${azurerm_resource_group.rg.name} --name ${azurerm_linux_web_app.webapp.name} --src-path "${data.archive_file.app_zip.output_path}" --type zip
        EOT

        interpreter = ["cmd.exe", "/C"]
    }
  
}

# Init SQL Database Schema
resource "null_resource" "sqlserver_init" { 
    depends_on = [ azurerm_mssql_database.db ]

    provisioner "local-exec" {
        command = <<EOT

            sqlcmd -S ${azurerm_mssql_server.sql_server.fully_qualified_domain_name} -U ${var.db_admin_username}@${azurerm_mssql_server.sql_server.name} -P ${var.db_admin_password} -d ${azurerm_mssql_database.db.name} -i "${path.module}/sql/schema.sql"
            echo "Database schema initialized successfully."
        EOT

        interpreter = ["cmd.exe", "/C"]
    }
}

#############################################
# 5) Outputs (URLs, credenciais, etc.)
#############################################

output "webapp_url" {
    description = "The URL of the deployed web app"
    value = azurerm_linux_web_app.webapp.default_hostname
}

output "mysql_server_fqdn" {
    description = "The fully qualified domain name of the MySQL server"
    value = azurerm_mssql_server.sql_server.fully_qualified_domain_name
}

output "db_name" {
    description = "The name of the MySQL database"
    value = azurerm_mssql_database.db.name
}

output "db_user" {
    description = "The MySQL database administrator username"
    value = "${var.db_admin_username}@${azurerm_mssql_server.sql_server.name}"
}