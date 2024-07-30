########################################################################
### die Vars muss im voraus als Environment Variables gesetzt werden ###
### export VMM Variable                                 s      werden ###
########################################################################


variable "ad_admin_password" {
  description = "client_secret"
  type        = string
  sensitive   = true
}

variable "computer_name" {
  type        = string
  description = "The hostname of the Citrix DDC server"
}



########################################################################
### die Vars muss im voraus als Environment Variables gesetzt werden ###
###  ###
########################################################################


variable "ad_admin_username" {
  type        = string
  description = "The username of the Active Directory user with administrative rights"

}
variable "host_base_url" {
  type        = string
  description = "The base URL of the StoreFront server"
}
variable "virtual_path" {
  type        = string
  description = "The virtual path of the store service."
}


variable "virtual_path_web" {
  type        = string
  description = "The virtual path of the store service."
}

variable "servers_sta" {
  description = "List of servers for the StoreFront farm"
  type        = list(string)
  default     = []
}


variable "gateway_url" {
  type = string

  description = "value of the gateway url"
}


variable "internal_ip" {
  type        = string
  description = "The internal IP address of the Roaming Beacon"
}


variable "external_ips" {
  type        = list(string)
  description = "The external IP addresses of the Roaming Beacon"
}



# citrix.tf variables
## On-Premises customer provider settings
variable "provider_hostname" {
  description = "The hostname of the Citrix Virtual Apps and Desktops Delivery Controller."
  type        = string
  default     = "" # Leave this variable empty for Citrix Cloud customer.
}

variable "provider_domain_fqdn" {
  description = "The domain FQDN of the on-premises Active Directory."
  type        = string
  default     = null # Leave this variable empty for Citrix Cloud customer.
}

variable "provider_disable_ssl_verification" {
  description = "Disable SSL verification for the Citrix Virtual Apps and Desktops Delivery Controller."
  type        = bool
  default     = false # Set this field to true if DDC does not have a valid SSL certificate configured. Omit this variable for Citrix Cloud customer. 
}



# Common provider settings
# For On-Premises customers: Domain Admin username and password are needed to interact with the Citrix Virtual Apps and Desktops Delivery Controller.
# For Citrix Cloud customers: API key client id and secret are needed to interact with Citrix DaaS APIs. These can be created/found under Identity and Access Management > API Access
variable "provider_client_id" {
  description = "The Domain Admin username of the on-premises Active Directory / The API key client id for Citrix Cloud customer."
  type        = string
  default     = ""
}

variable "provider_client_secret" {
  description = "The Domain Admin password of the on-premises Active Directory / The API key client secret for Citrix Cloud customer."
  type        = string
  default     = ""
}

# delivery_groups.tf variables
variable "delivery_group_name" {
  description = "Name of the Delivery Group to create"
  type        = string
  default     = "example-delivery-group"
}

variable "allow_list" {
  description = "List of users to allow for the Delivery Group in DOMAIN\\username format"
  type        = list(string)
  default = [ "m001\\advmadmin" ]
}
