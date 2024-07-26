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

  #pna = {
  #  enabled = true
  #}
  enumeration_options = {
    enhanced_enumeration            = false
    maximum_concurrent_enumerations = 2
    filter_by_keywords_include      = ["AppSet1", "AppSet2"]
  }
  launch_options = {
    vda_logon_data_provider = "FASLogonDataProvider"
  }
  /*
  farm_settings = {
    enable_file_type_association   = true
    communication_timeout          = "0.0:0:0"
    connection_timeout             = "0.0:0:0"
    leasing_status_expiry_failed   = "0.0:0:0"
    leasing_status_expiry_leasing  = "0.0:0:0"
    leasing_status_expiry_pending  = "0.0:0:0"
    pooled_sockets                 = false
    server_communication_attempts  = 5
    background_healthcheck_polling = "0.0:0:0"
    advanced_healthcheck           = false
    cert_revocation_policy         = "MustCheck"
  }
  */
  gateway_settings = {
    enable      = true
    gateway_url = "https://xsl-ddc.ctx-ad.local"
  }
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





resource "citrix_stf_store_farm" "example-stf-store-farm" {
  store_virtual_path = citrix_stf_store_service.example-stf-store-service.virtual_path
  farm_name          = "Controller1"
  farm_type          = "XenDesktop"
  servers            = var.servers_sta
  port               = 443
  zones              = ["Primary", "Secondary", "Thirds"]
}


resource "citrix_stf_roaming_gateway" "example-stf-roaming-gateway" {
    site_id                        = citrix_stf_deployment.stf_deployment_0.site_id
    name                           = "Example Roaming Gateway Name"
    logon_type                     = "Domain"
    smart_card_fallback_logon_type = "None"
    gateway_url                    = "https://example.gateway.com/"
    #callback_url                   = "https://exampleremote.callback.com/"
    version                        = "Version10_0_69_4"
    subnet_ip_address              = "10.0.0.1"
    stas_bypass_duration           = "0.1:0:0"
    #gslb_url                       = "https://example.gslb.url"
    session_reliability            = false
    request_ticket_two_stas        = false
    stas_use_load_balancing        = false
    is_cloud_gateway               = false
    /*
    secure_ticket_authority_urls   = [
        "https://example.sta1.com/",
        "https://example.sta2.url/"
    ]
    */
    
}

resource "citrix_stf_roaming_beacon" "testSTFRoamingBeacon" {
  internal_ip = "https://example.internal.url/"
  external_ips = ["https://abc1.com/" , "https://abc2.com/"]
  site_id = 1
}