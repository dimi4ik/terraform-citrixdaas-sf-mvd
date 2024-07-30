resource "citrix_machine_catalog" "example-manual-non-power-managed-mtsession" {
  name              = "example-manual-non-power-managed-mtsession"
  description       = "Example manual non power managed multi-session catalog"
  zone              = "e6127276-003a-4863-9652-0f64d0ae1153"
  allocation_type   = "Random"
  session_support   = "MultiSession"
  is_power_managed  = false
  is_remote_pc      = false
  provisioning_type = "Manual"
  machine_accounts = [
    {
      machines = [
        {
          machine_account = "m001\\vda"
        } #,
        #{
        #    machine_account = "DOMAIN\\MachineName2"
        #}
      ]
    }
  ]
}




resource "citrix_delivery_group" "example-delivery-group" {
    name = var.delivery_group_name
    associated_machine_catalogs = [
        {
            machine_catalog = citrix_machine_catalog.example-manual-non-power-managed-mtsession.id
            machine_count = 1
        }
    ]
    desktops = [
        {
            published_name = "Example Desktop"
            description = "Description for example desktop"
            restricted_access_users = {
                allow_list = var.allow_list
            }
            enabled = true
            enable_session_roaming = false
        }
    ] 
    
    restricted_access_users = {
        allow_list = var.allow_list
    }
}