﻿
# Copyright © 2024. Citrix Systems, Inc. All Rights Reserved.
<#
Currently this script is still in TechPreview
.SYNOPSIS
    Script to onboard an existing Storefront resources to terraform.

.DESCRIPTION
    The script should be able to collect the list of resources from Storefront Server, import into terraform, and generate the TF skeletons.

.Parameter StorefrontHostname
    The Storefront Server Hostname. This can be an IP address or a FQDN.

.Parameter ADAdminUsername
    The Active Directory Admin Username for authentication with the Storefront Server.

.Parameter ADAdminPassword
    The Active Directory Admin Password for authentication with the Storefront Server.


#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string] $StorefrontHostname,

    [Parameter(Mandatory = $true)]
    [string] $ADAdminUsername,

    [Parameter(Mandatory = $true)]
    [string] $ADAdminPassword
)

### Helper Functions ###

function BuildAuth {
    param(
        [Parameter(Mandatory=$true)]
        [string] $remoteCompName,
        [Parameter(Mandatory=$true)]
        [string]$username,
        [Parameter(Mandatory=$true)]
        [string]$password
    )

    if ($remoteCompName -eq "") {
        return ""
    }
    elseif ($remoteCompName -like "*https*") {
        $securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
        $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $securePassword
        return @{
            ConnectionUri = $remoteCompName
            Credential = $credential
        }
    }
    else {

        $securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
        $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $securePassword
        return @{
            ComputerName = $remoteCompName
            Credential = $credential
        }
    }
}


function Start-GetRequest {
    param(
        [parameter(Mandatory = $true)][string] $requestCmdlet
    )
    $auth = BuildAuth -remoteCompName $script:computerName -username $script:adUsername -password $script:adPassword
    $session = New-PSSession @auth

    $response = Invoke-Command -Session $session -ScriptBlock {
        param($command)
        Invoke-Expression $command
    } -ArgumentList $requestCmdlet

    Remove-PSSession  $session

    return $response
}

function New-RequiredFiles {
    $script:processedadUsername = $script:adUsername.Replace("\", "\\")
    # Create temporary import.tf for terraform import
    if (!(Test-Path ".\citrix.tf")) {
        New-Item -path ".\" -name "citrix.tf" -type "file" -Force
        Write-Verbose "Created new file for terraform citrix provider configuration."
    }
    $config = @"
provider "citrix" {
    storefront_remote_host = {
        computer_name                = "$script:computerName"
        ad_admin_username            = "$script:processedadUsername"
        ad_admin_password            = "$script:adPassword"
    }
}
"@
    Set-Content -Path ".\citrix.tf" -Value $config

    if (!(Test-Path ".\import.tf")) {
        New-Item -path ".\" -name "import.tf" -type "file" -Force
        Write-Verbose "Created new file for terraform import."
    }
    else {
        Clear-Content -path ".\import.tf"
        Write-Verbose "Cleared content in terraform import file."
    }

    # Create resource.tf for final terraform resources
    if (!(Test-Path ".\resource.tf")) {
        New-Item -path ".\" -name "resource.tf" -type "file" -Force
        Write-Verbose "Created new file for terraform resource."
    }
    else {
        Clear-Content -path ".\resource.tf"
        Write-Verbose "Cleared content in terraform resource file."
    }

}

# Function to get list of resources for a given resource provider
function Get-ResourceList {
    param(
        [parameter(Mandatory = $true)]
        [string] $requestCmdlet
    )

    $response = Start-GetRequest -requestCmdlet $requestCmdlet
    $resourceList = @()
    $pathMap = @{}
    foreach ($item in $response) {
        $resourceList += $item.SiteId
    }
    return $resourceList, $pathMap
}

# Function to get import map for each resource
function Get-ImportMap {
    param(
        [parameter(Mandatory = $true)]
        [string] $resourceApi,

        [parameter(Mandatory = $true)]
        [string] $resourceProviderName,

        [parameter(Mandatory = $false)]
        [string] $parentId = ""
    )

    $list, $pathMap = Get-ResourceList -requestCmdlet $resourceApi
    $resourceMap = @{}
    $index = 0
    foreach ($id in $list) {
        if ($parentId -ne "") {
            $resourceName = "$($resourceProviderName)_$($index)"
            $resourceMapKey = "$($parentId),$($id)"
        }
        else {
            $resourceName = "$($resourceProviderName)_$($index)"
            $resourceMapKey = $id
        }

        $resourceMap[$resourceMapKey] = $resourceName
        $resourceContent = "resource `"citrix_$resourceProviderName`" `"$resourceName`" {}`n"
        Add-Content -Path ".\import.tf" -Value $resourceContent
        $index += 1
    }

    return $resourceMap
}

# List all CVAD objects from existing site
function Get-ExistingSFResources {

    $resources = @{
        "stf_deployment"               = @{
            "resourceApi"          = "Get-STFDeployment"
            "resourceProviderName" = "stf_deployment"
        }
    }

    $script:cvadResourcesMap = @{}
    #iterate through all resources
    foreach ($resource in $resources.Keys) {
        $api = $resources[$resource].resourceApi
        $resourceProviderName = $resources[$resource].resourceProviderName

        # Create resource hash map for each resource
        if ($resource -like "*deployment") {
            $script:cvadResourcesMap[$resource] = Get-ImportMap -resourceApi $api -resourceProviderName $resourceProviderName
        }else{
            $script:cvadResourcesMap[$resource] = Get-ImportMap -resourceApi $api -resourceProviderName $resourceProviderName -parentId $id
        }

    }
}

# Function to import terraform resources into state
function Import-ResourcesToState {
    foreach ($resource in  $script:cvadResourcesMap.Keys) {
        foreach ($id in  $script:cvadResourcesMap[$resource].Keys) {
            Write-Output "citrix_$($resource).$($script:cvadResourcesMap[$resource][$id])"
            terraform import "citrix_$($resource).$($script:cvadResourcesMap[$resource][$id])" "$id"
        }
    }
}

function InjectSecretValues {
    param(
        [parameter(Mandatory = $true)]
        [string] $targetProperty,

        [parameter(Mandatory = $true)]
        [string] $newProperty,

        [parameter(Mandatory = $true)]
        [string] $content
    )

    $regex = "(\s+)$targetProperty(\s+)= (\S+)"
    if ($content -match $regex) {
        $target = $Matches[0]
        $newContent = $target -replace $targetProperty, $newProperty
        $newContent = $newContent -replace "`"\S+`"", "`"<input $($newProperty) value>`""
        if ("username" -eq $targetProperty) {
            # In this case, it would be on-premises hypervisor. We need to have password format.
            $format = $target -replace $targetProperty, "password_format"
            $format = $format -replace "`"\S+`"", "`"PlainText`""
            $content = $content -replace $regex, "$($target)$($newContent)$($format)"
        } else {
            $content = $content -replace $regex, "$($target)$($newContent)"
        }
    }

    return $content
}

function RemoveComputedProperties {
    param(
        [parameter(Mandatory = $true)]
        [string] $content
    )

    return $content
}

function ReplaceDependencyRelationships {
    param(
        [parameter(Mandatory = $true)]
        [string] $content
    )

    if (-not $script:SetDependencyRelationship) {
        return $content
    }

    # Create dependency relationships between resources with id references
    foreach ($resource in $script:cvadResourcesMap.Keys) {
        foreach ($id in $script:cvadResourcesMap[$resource].Keys) {
            $content = $content -replace "`"$id`"", "citrix_$($resource).$($script:cvadResourcesMap[$resource][$id]).id"
        }
    }

    return $content
}

function InjectPlaceHolderSensitiveValues {
    param(
        [parameter(Mandatory = $true)]
        [string] $content
    )

    ### hypervisor secrets ###
    $content = InjectSecretValues -targetProperty "application_id" -newProperty "application_secret" -content $content

    return $content
}

function PostProcessTerraformOutput {

    # Post-process the terraform output
    $content = Get-Content -Path ".\resource.tf" -Raw

    # Remove computed properties
    $content = RemoveComputedProperties -content $content

    # Set dependency relationships
    $content = ReplaceDependencyRelationships -content $content

    # Inject placeholder for sensitive values in tf
    $content = InjectPlaceHolderSensitiveValues -content $content

    # Overwrite extracted terraform with processed value
    Set-Content -Path ".\resource.tf" -Value $content
}

function PostProcessProviderConfig {

    # Post-process the provider config output in citrix.tf
    $content = Get-Content -Path ".\citrix.tf" -Raw

    # Uncomment field for client secret in provider config
    $content =$content -replace "# ", ""

    # Overwrite provider config with processed value
    Set-Content -Path ".\citrix.tf" -Value $content
}


# Initialize script variables
$script:computerName = $StorefrontHostname
$script:adUsername = $ADAdminUsername
$script:adPassword = $ADAdminPassword

# Set environment variables for client secret
$env:CITRIX_CLIENT_SECRET = $ClientSecret

try {
    New-RequiredFiles

    # Get CVAD resources from existing site
    Get-ExistingSFResources

    # Initialize terraform
    terraform init

    # Import terraform resources into state
    Import-ResourcesToState

    # Export terraform resources
    terraform show >> ".\resource.tf"

    # Post-process citrix.tf output
    PostProcessProviderConfig

    # Post-process terraform output
    PostProcessTerraformOutput

    # Remove temporary TF file
    Remove-Item ".\import.tf"

    # Format terraform files
    terraform fmt
} finally {
    # Clean up environment variables for client secret
    $env:CITRIX_CLIENT_SECRET = ''
}
