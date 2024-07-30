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
      # On-Premises customer provider settings
    # Please comment out / remove this provider settings block if you are a Citrix Cloud customer

    hostname                 = var.provider_hostname
    client_id                = var.ad_admin_username #"${var.provider_domain_fqdn}\\${var.provider_client_id}"
    client_secret            = var.ad_admin_password
    disable_ssl_verification = var.provider_disable_ssl_verification

  
}
