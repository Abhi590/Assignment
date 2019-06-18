<#
.NOTES
    Author: Abhishek Jaiswal

.Synopsis
    .\DeployResourceGroup.ps1 -RgName [String] -TemplateFilePath [String] -ParameterFilePath [String]

.Description
This script will deploy a Resource Group.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)][String] $TemplateFileResourceGroup,
    [Parameter(Mandatory = $true)][String] $PathToParameters
)

$ErrorActionPreference = 'Stop'

If (![System.IO.File]::Exists($TemplateFileResourceGroup)) {
    Write-Error "The file '$($TemplateFileResourceGroup)' doesn't exists"
}
If (![System.IO.File]::Exists($TemplateFilePolicyAssignment)) {
    Write-Error "The file '$($TemplateFilePolicyAssignment)' doesn't exists"
}


# Validate PathToParameters
If ([System.IO.File]::Exists($PathToParameters)) {
	Try {
		If ($inputvalue = ([System.IO.File]::ReadAllText($PathToParameters) | ConvertFrom-Json)) {
			# Valid input Json file
        }
        Else {
			Write-Error "Failed to read Json file '$($PathToParameters)'"
		}
    }
    Catch {
		Write-Error "Failed to read Json file '$($PathToParameters)'"
	}
}
Else {
	Write-Error "The parameter file '$($PathToParameters)' doesn't exists"
}

# Output of the parameter file
$location = $inputvalue.parameters.ResourceGroupLocation
$RGName = $inputvalue.parameters.ResourceGroupName

If ([System.String]::IsNullOrEmpty($location) -or [System.String]::IsNullOrEmpty($RGName)) {
	Write-Error "The Location and/or RGName is not specified which are required to create an Azure Resource Group within CBSP Azure"
}
$locations = Get-AzLocation
If ($locationResult = $locations | Where-Object -FilterScript { $_.Location -eq $location }) {
    Write-Output "Location '$($locationResult.Location)' with displayName '$($locationResult.DisplayName)' is a valid location"
}
Else {
    Write-Error "The Location '$($location)' doesn't exists within Azure"
}

If ($resourceGroup = Get-AzResourceGroup -Name $RGName -ErrorAction SilentlyContinue) {
    $resourceGroupResourceId = $resourceGroup.ResourceId
    Write-Output "The Resource Group '$($resourceGroup.ResourceGroupName)' currently exists at location '$($resourceGroup.Location)' with Resource Id '$($resourceGroupResourceId)'"
    If ($resourceGroup.Location -ne $location) {
        Write-Warning "The Resource Group '$($resourceGroup.ResourceGroupName)' exists at '$($resourceGroup.Location)', while the deployment location should be '$($location)'"
    }
}
Else {
    Write-Output "The Resource Group '$($RGName)' will be created at location '$($location)'"
}

$resourceGroupTags = @{
    "Product"      = $inputvalue.parameters.ResourceGroupTags.productTag
    "Organization"    = $inputvalue.parameters.ResourceGroupTags.Organization
    "Application"     = $inputvalue.parameters.ResourceGroupTags.Application
    "BillingId"       = $inputvalue.parameters.ResourceGroupTags.BillingId
}

If ($createResourceGroup) {
    $parameterObject = @{
        "ResourceGroupName"     = $RGName
        "ResourceGroupLocation" = $location
        "ResourceGroupTags"     = $resourceGroupTags
    }

    Write-Output "Validate template '$TemplateFileResourceGroup' and parameters"
    Test-AzDeployment -Location $location -TemplateFile $TemplateFileResourceGroup -TemplateParameterObject $parameterObject
    Write-Output "Deploy Resource Group '$($resourceGroupName)'"
    $deploymentResult = New-AzDeployment -Location $location -TemplateFile $TemplateFileResourceGroup -TemplateParameterObject $parameterObject
    $resourceGroupResourceId = $deploymentResult.Outputs.Item("resourceId").Value
    Write-Output "Resource Group deployed with ResourceId '$($resourceGroupResourceId)'"
}