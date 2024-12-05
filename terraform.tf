terraform {
  required_version = ">= 1.9.7"
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }

  backend "azurerm" {
    subscription_id      = "5cbe474c-dccc-41c5-b910-d6af4ae286ae"
    resource_group_name  = "kw-cloudops-neu-dev-rsg"
    storage_account_name = "saneudevcloudstd01"
    container_name       = "github-enterprise"
    key                  = "terraform.tfstate"
  }
}

provider "github" {
  owner = "KantarWorldpanel"
}