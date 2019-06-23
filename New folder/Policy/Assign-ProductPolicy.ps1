<#
.SYNOPSIS
Assigns one or more policy initiatives for products on a resource group.

.DESCRIPTION
Assigns one or more policy initiatives for products on a resource group. 
The initiative must have been created already and must not have any parameters.

.PARAMETER PolicyFilesPath
This path in which (sub)folders will be scanned for policy initiative 
definition files.

.PARAMETER ResourceGroupName
The name of the resource group on which the initiatives must be assigned.

.OUTPUTS
None
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [String] $PolicyFilesPath,
    [Parameter(Mandatory = $true)]
    [String] $ResourceGroupName
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# This will throw an error when the resource group does not exist.
$resourceGroup = Get-AzureRmResourceGroup -Name $ResourceGroupName

$initiativeFiles = @(Get-ChildItem -Path $PolicyFilesPath -File -Recurse -Filter "initiative*.json")
If ($initiativeFiles) {
    $fileCounter = 1
    ForEach ($initiativeFile In $initiativeFiles) {
        Write-Host "Processing policy initiative file $fileCounter/$($initiativeFiles.Count) with name '$($initiativeFile.FullName)'."
        $fileCounter++

        $initiativeSource = Get-Content -Path $initiativeFile.FullName | ConvertFrom-Json

        $initiative = Get-AzureRmPolicySetDefinition -Name $initiativeSource.name

        # Check if PSCustomObject is empty via this construct
        If ("$($initiative.Properties.parameters)") {
            Write-Host "Don't assign initiative which requires parameter values."
            Continue
        }

        Write-Host "Removing policy assignments for initiative '$($initiative.ResourceId)'."
        Get-AzureRmPolicyAssignment -PolicyDefinitionId $initiative.ResourceId -Scope $resourceGroup.ResourceId `
            | ForEach-Object { Remove-AzureRmPolicyAssignment -Id $_.ResourceId }

        Write-Host "Assigning initiative '$($initiative.ResourceId)' on resource group '$($resourceGroup.ResourceGroupName)'."

        New-AzureRmPolicyAssignment -PolicySetDefinition $initiative `
                                    -Scope $resourceGroup.ResourceId `
                                    -Name $initiative.Name `
                                    -Description $initiative.Properties.displayName 
    }
}
