variable "subscription_id" {}

resource "azurerm_resource_group" "rg" {
    name     = "${var.prefix}-rg"
    location = var.location
}

resource "random_string" "suffix" {
    length  = 6
    upper   = false
    special = false
}

locals {
    unique_suffix = random_string.suffix.result
}

resource "azurerm_service_plan" "name" {
    name                = "${var.prefix}-serviceplan-${local.unique_suffix}"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    os_type             = "Linux"
    sku_name            = "B1"  # Basic tier
}

resource "azurerm_linux_web_app" "webapp" {
    name                = "${var.prefix}-webapp-${local.unique_suffix}"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    service_plan_id     = azurerm_service_plan.name.id

    site_config {
        minimum_tls_version = "1.2"
        application_stack {
            php_version = "8.3"  # Specify the PHP version
        }
    }
    connection_string {
        name  = "DefaultConnection"
        type  = "SQLAzure"
        value = "Server=tcp:${azurerm_mssql_server.sql.name}.database.windows.net;Database=${var.db_name};User ID=${var.db_admin_username}@${azurerm_mssql_server.sql.name};Password=${var.db_admin_password};Encrypt=true;TrustServerCertificate=false;Connection Timeout=30;"
    }
}

resource "azurerm_mssql_server" "sql" {
    name                         = "${var.prefix}-sql-${local.unique_suffix}"
    resource_group_name          = azurerm_resource_group.rg.name
    location                     = azurerm_resource_group.rg.location
    version                      = "12.0"
    administrator_login          = var.db_admin_username
    administrator_login_password = var.db_admin_password
}

resource "azurerm_mssql_database" "db" {
    name           = var.db_name
    server_id      = azurerm_mssql_server.sql.id
    sku_name       = "Basic"
    collation      = "SQL_Latin1_General_CP1_CI_AS"
    max_size_gb    = 2

    depends_on = [ azurerm_mssql_server.sql ]
}

# Just to allow all IPs for testing purposes, not recommended for production
resource "azurerm_mssql_firewall_rule" "allow_all_ips" {
    name                = "AllowAllIPs"
    server_id         = azurerm_mssql_server.sql.id
    start_ip_address    = "0.0.0.0"
    end_ip_address      = "255.255.255.255"

    depends_on = [ azurerm_mssql_server.sql ]
}

resource "archive_file" "app_zip" {
    type        = "zip"
    source_dir  = "${path.module}/app"
    output_path = "${path.module}/app.zip"
    
    depends_on = [ azurerm_linux_web_app.webapp ]
}

resource "terraform_data" "deploy_code" {
    depends_on = [ archive_file.app_zip ]

    provisioner "local-exec" {
        command = "az webapp deploy --resource-group ${azurerm_resource_group.rg.name} --name ${azurerm_linux_web_app.webapp.name} --src-path ${archive_file.app_zip.output_path}"
    }
}

resource "terraform_data" "initialize_db_schema" {
    depends_on = [ azurerm_mssql_database.db,
            azurerm_mssql_firewall_rule.allow_all_ips
        ]

    provisioner "local-exec" {
        command = <<EOT
            sqlcmd -S ${azurerm_mssql_server.sql.fully_qualified_domain_name} -d ${azurerm_mssql_database.db.name} -U ${var.db_admin_username} -P ${var.db_admin_password} -i ${path.module}/sql/schema.sql
        EOT
    }
}

output "webapp_url" {
    description = "The URL of the deployed web app"
    value = "https://${azurerm_linux_web_app.webapp.default_site_hostname}"
}

output "db_user" {
    description = "The SQL server database administrator username"
    value = "${var.db_admin_username}@${azurerm_mssql_server.sql.name}"
}

output "db_name" {
    description = "The name of the SQL database"
    value = azurerm_mssql_database.db.name
}

output "mysql_server_fqdn" {
    description = "The fully qualified domain name of the SQL server"
    value = azurerm_mssql_server.sql.fully_qualified_domain_name
}