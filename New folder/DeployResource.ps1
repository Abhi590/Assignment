<#
.NOTES
    Author: Abhishek Jaiswal

.Synopsis
    .\DeployResource.ps1 -RgName [String] -TemplateFilePath [String] -ParameterFilePath [String]

.Description
This script will deploy a resource based on the template file provided.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)][String] $RgName,
    [Parameter(Mandatory = $true)][String] $TemplateFilePath,
    [Parameter(Mandatory = $true)][String] $ParameterFilePath
)

$ErrorActionPreference = 'Stop'

If (![System.IO.File]::Exists($TemplateFilePath)) {
    Write-Error "The file '$($TemplateFilePath)' doesn't exists"
}
If (![System.IO.File]::Exists($ParameterFilePath)) {
    Write-Error "The file '$($ParameterFilePath)' doesn't exists"
}

$paramList = @{
    ResourceGroupName     = $RgName
    TemplateFile          = $TemplateFilePath
    TemplateParameterFile = $ParameterFilePath
}

Try{
    Get-AzResourceGroup -Name $RgName -ErrorAction stop
}
catch {
    Write-Error "Could not find Resource Group: $($RgName)"
}

If ([System.IO.File]::Exists($TemplateFilePath) -and [System.IO.File]::Exists($ParameterFilePath)) {
    try {
        Write-Output "Validate template '$TemplateFilePath' and parameters"
        Test-AzResourceGroupDeployment @paramList
        Write-Output "Template Validation successful, deploying the resource"
        New-AzResourceGroupDeployment @paramList
        Write-Output "Resource has been deployed successfully"
    }
    catch {
        Throw "$($_.Exception.Message)"
        Write-Error "Unable to Deploy the resource"
    }
}