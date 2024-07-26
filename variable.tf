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
