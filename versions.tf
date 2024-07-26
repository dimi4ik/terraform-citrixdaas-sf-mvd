terraform {
  required_version = ">= 1.4.0"

  required_providers {
    citrix = {
      source  = "citrix/citrix"
      version = ">=0.6.3"
    }
  }

  backend "local" {}
}


provider "citrix" {
  storefront_remote_host = {
    computer_name     = var.computer_name
    ad_admin_username = var.ad_admin_username
    ad_admin_password = var.ad_admin_password
  }
}
