terraform {
    required_providers {
        azurerm = {
        source  = "hashicorp/azurerm"
        version = "~> 4.32.0"
        }
    }
    
    required_version = ">= 1.3.0"
}

provider "azurerm" {
    features {}
    subscription_id = var.subscription_id
}
