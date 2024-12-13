terraform {
  required_version = ">= 1.9.7"
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }

  backend "azurerm" {
    subscription_id      = "f401adca-63c1-44e1-9aa3-9c9d18d3fc1b"
    resource_group_name  = "rg-iac-backend"
    storage_account_name = "tfbackendepamarmpit"
    container_name       = "github-enterprise"
    key                  = "terraform.tfstate"
  }
}

provider "github" {
  owner = "apindustries"
}