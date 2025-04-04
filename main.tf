# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.70" # Or the latest version you prefer
    }
  }
}

provider "azurerm" {
  features {}
  
}

# Define the Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-storage-linux-cicd"
  location = "eastus" # Choose an appropriate Azure region
}

# Define the Azure Linux Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = "unique-storage-1" # Unique storage account name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS" # Locally-redundant storage
  account_kind             = "StorageV2"
  

  tags = {
    environment = "dev"
    owner       = "cicd-pipeline"
  }
}

# Generate a random ID for uniqueness
resource "random_id" "id" {
  byte_length = 8
}

# Output the storage account name
output "storage_account_name" {
  value = azurerm_storage_account.storage.name
}
