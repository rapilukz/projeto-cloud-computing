variable "subscription_id" {}

provider "azurerm" {
    features {}
    subscription_id = var.subscription_id
}

#############################################
# 1) Resource Group
#############################################

# Create Base Resource Group
resource "azurerm_resource_group" "rg" {
    name     = "${var.prefix}-rg"
    location = var.location
}

#############################################
# 2) Azure Database for MySQL Server + DB
#############################################

# Setup Azure MySQL Server
resource "azurerm_mysql_server" "mysql" {
    name                            = "${var.prefix}-mysql"
    resource_group_name             = azurerm_resource_group.rg.name
    location                        = azurerm_resource_group.rg.location
    version                         = "8.0"

    administrator_login             = var.db_admin_username
    administrator_password          = var.db_admin_password

    sku_name                        = "GP_Gen5_2"
    storage_mb                      = 51200

    geo_redundant_backup_enabled    = false
    public_network_access_enabled   = true
}

# Firewall rule to allow access from Azure services
resource "azurerm_mysql_server_firewall_rule" "allow_azure" {
    name                = "allow_azure_services"
    resource_group_name = azurerm_resource_group.rg.name
    server_name         = azurerm_mysql_server.mysql.name

    start_ip_address    = "0.0.0.0"
    end_ip_address      = "0.0.0.0"
}

# Create the database
resource "azurerm_mysql_database" "db" {
    name                = var.db_name
    resource_group_name = azurerm_resource_group.rg.name
    server_name         = azurerm_mysql_server.mysql.name

    charset             = "utf8"
    collation           = "utf8_general_ci"
}

#############################################
# 3) App Service Plan (Linux) + Web App PHP
#############################################

# App Serivice Plan (Linux)
resource "azurerm_app_service_plan" "asp" {
    name                = "${var.prefix}-asp-linux"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    kind                = "Linux"
    reserved            = true

    sku {
        tier     = "Basic"
        size     = "B1"
    }
}


# Web App Php (App Service) - runtime Linux + PHP 8.0
resource "azurerm_app_service" "name" {
    name = "${var.prefix}-webapp"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    app_service_plan_id = azurerm_app_service_plan.asp.id

    # Configs for PHP
    site_config {
        linux_fx_version = "PHP|8.0"
    }

    app_settings = {
        "DB_HOST"     = azurerm_mysql_server.mysql.fqdn
        "DB_NAME"     = var.db_name
        "DB_USER"     = "${var.db_admin_username}@${azurerm_mysql_server.mysql.name}"
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
