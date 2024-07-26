output "stf_deployment_site_id" {
  description = "The site ID of the STF deployment"
  value       = citrix_stf_deployment.stf_deployment_0.site_id
}

output "authentication_service_virtual_path" {
  description = "The virtual path of the authentication service"
  value       = citrix_stf_authentication_service.example-stf-authentication-service.virtual_path
}

output "store_service_virtual_path" {
  description = "The virtual path of the store service"
  value       = citrix_stf_store_service.example-stf-store-service.virtual_path
}

output "webreceiver_service_virtual_path" {
  description = "The virtual path of the web receiver service"
  value       = citrix_stf_webreceiver_service.example-stf-webreceiver-service.virtual_path
}

/* output "webreceiver_service_gateway_url" {
  description = "The gateway URL of the web receiver service"
  value       = citrix_stf_webreceiver_service.example-stf-webreceiver-service.gateway_url
} */

output "store_farm_name" {
  description = "The name of the store farm"
  value       = citrix_stf_store_farm.example-stf-store-farm.farm_name
}

output "roaming_gateway_url" {
  description = "The URL of the roaming gateway"
  value       = citrix_stf_roaming_gateway.example-stf-roaming-gateway.gateway_url
}
