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




/*
resource "citrix_stf_roaming_gateway" "example-stf-roaming-gateway" {
    callback_url                   = "https://ctx-portal-test.lab.ktzh.ch/CitrixAuthService/AuthService.asmx"
    #deployment                     = "Appliance"
    #edition                        = "Enterprise"
    gateway_url                    = "https://ctx-portal-test.lab.ktzh.ch/"
    gslb_url                       = ""
    is_cloud_gateway               = false
    logon_type                     = "SmartCard"
    name                           = "ctx-portal-test_dtsctx0001"
    request_ticket_two_stas        = false

    secure_ticket_authority_urls   = [

    {
            authority_id           = null
            sta_url                = "https://etsapp0010.lab.zh.ch/scripts/ctxsta.dll"
            sta_validation_enabled = false
            sta_validation_secret  = (sensitive value)
       },
    ]

    session_reliability            = true
    site_id                        = "1"
    smart_card_fallback_logon_type = "None"
    stas_bypass_duration           = "0.1:0:0"
    stas_use_load_balancing        = false
    subnet_ip_address              = ""
    version                        = "Version10_0_69_4"


}



resource "citrix_stf_roaming_beacon" "testSTFRoamingBeacon" {
  internal_ip = "https://test.com"#"https://etsapp0009.lab.zh.ch/"
  external_ips = ["https://ctx-portal-test.lab.ktzh.ch" , "https://otp-portal-test.lab.ktzh.ch"]
  site_id = 1
}
 */
