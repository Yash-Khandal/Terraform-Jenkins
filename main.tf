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
  client_id       = "YOUR_CLIENT_ID"  # Replace with your client ID
  client_secret   = "YOUR_PREVIOUS_SECRET"
  tenant_id       = "341f4047-ffad-4c4a-a0e7-b86c7963832b"  # Replace with your tenant ID
  subscription_id = "YOUR_SUBSCRIPTION_ID" # Replace with your subscription ID
}

# Define the Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-storage-linux-cicd"
  location = "eastus" # Choose an appropriate Azure region
}

# Define the Azure Linux Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = "uniquestorageaccount1" # Unique storage account name
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
