# citrix_stf_deployment.stf_deployment_0:
resource "citrix_stf_deployment" "stf_deployment_0" {
  host_base_url = var.host_base_url
  site_id       = "1"
}

### Create an authentication service
resource "citrix_stf_authentication_service" "example-stf-authentication-service" {
  site_id       = citrix_stf_deployment.stf_deployment_0.site_id
  friendly_name = "Auth"
  virtual_path  = "/Citrix/Authentication"
}


resource "citrix_stf_store_service" "example-stf-store-service" {
  site_id                             = citrix_stf_deployment.stf_deployment_0.site_id
  virtual_path                        = var.virtual_path
  friendly_name                       = "Store"
  authentication_service_virtual_path = citrix_stf_authentication_service.example-stf-authentication-service.virtual_path
  #farm_config = {
  #  farm_name = "Controller"
  #  farm_type = "XenDesktop"
  # servers   = ["cvad.storefront.com"]
  #}
}


resource "citrix_stf_webreceiver_service" "example-stf-webreceiver-service" {
  site_id            = citrix_stf_deployment.stf_deployment_0.site_id
  virtual_path       = var.virtual_path_web
  friendly_name      = "Receiver2"
  store_virtual_path = citrix_stf_store_service.example-stf-store-service.virtual_path
  authentication_methods = [
    "ExplicitForms",
  ]
  plugin_assistant = {
    enabled                 = true
    html5_single_tab_launch = true
    upgrade_at_login        = true
    html5_enabled           = "Off"
  }
}
