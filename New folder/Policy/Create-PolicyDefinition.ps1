<#
.SYNOPSIS
Creates policy and policy initiative definitions at subscription scope.

.DESCRIPTION
Creates policy and policy initiative definitions at subscription scope.

.PARAMETER PolicyFilesPath
This path in which (sub)folders will be scanned for policy and policy initiative 
definition files to deploy.

.OUTPUTS
None
#>
[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [String] $PolicyFilesPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Create the policy definitions before the initiatives, because the initiatives might depend on them.

$policyFiles = @(Get-ChildItem -Path $PolicyFilesPath -File -Recurse -Filter "policy*.json")
If ($policyFiles) {
    $fileCounter = 1
    ForEach ($policyFile In $policyFiles) {
        Write-Host "Processing policy definition file $fileCounter/$($policyFiles.Count) with name '$($policyFile.FullName)'."
        $policyFileContent = Get-Content -Path $policyFile.FullName -Raw
        $policySource = ConvertFrom-Json -InputObject $policyFileContent

        $rule = ConvertTo-Json -Depth 50 -InputObject $policySource.properties.policyRule
        $params = ConvertTo-Json -Depth 50 -InputObject $policySource.properties.parameters

        # This will create the definition in the current Azure context. This must be subscription scope for now.
        New-AzureRmPolicyDefinition -DisplayName $policySource.properties.displayName `
                                    -Description $policySource.properties.description `
                                    -Parameter $params `
                                    -Policy $rule `
                                    -Name $policySource.name

        $fileCounter++
    }            
}

$initiativeFiles = @(Get-ChildItem -Path $PolicyFilesPath -File -Recurse -Filter "initiative*.json")
If ($initiativeFiles) {
    $fileCounter = 1
    ForEach ($initiativeFile In $initiativeFiles) {
        Write-Host "Processing policy initiative file $fileCounter/$($initiativeFiles.Count) with name '$($initiativeFile.FullName)'."
        $initiativeFileContent = Get-Content -Path $initiativeFile.FullName -Raw
        $initiativeSource = ConvertFrom-Json -InputObject $initiativeFileContent

        # Check for common error where the subscription id placeholder has not been replaced yet
        ForEach ($policyDefinitionRef In $initiativeSource.properties.policyDefinitions) {
            If ($policyDefinitionRef.policyDefinitionId.Contains('#{subscriptionId}#')) {
                Write-Error "Cannot proceed as #{subscriptionId}# token has not been replaced yet in '$($policyDefinitionRef.policyDefinitionId)'."
            }
            If ($policyDefinitionRef.policyDefinitionId.Contains('#{')) {
                Write-Error "Detected unreplaced token in parameter '$($policyDefinitionRef.policyDefinitionId)'."
            }

            # Do nothing for an "empty" PSCustomObject, use this construct to test for it.
            If (-not "$($policyDefinitionRef.parameters)") {
                Continue
            }
            
            ForEach ($parametersRef In $policyDefinitionRef.parameters) {
                If ($parametersRef.psobject.properties.name) {
                    ForEach ($parameter In $parametersRef.psobject.properties.name) {
                        $parameterRef = $parametersRef.$parameter
                        If ($parameterRef.Value.Contains('#{')) {
                            Write-Error "Detected unreplaced token in parameter '$($parameterRef.Value)'."
                        }
                    }
                }
            }
        }

        $definitions = ConvertTo-Json -Depth 50 -InputObject $initiativeSource.properties.policyDefinitions
        $params = ConvertTo-Json -Depth 50 -InputObject $initiativeSource.properties.parameters

        # This will create the initiative in the current Azure context. This must be subscription scope for now.
        New-AzureRmPolicySetDefinition -DisplayName $initiativeSource.properties.displayName `
                                       -Description $initiativeSource.properties.description `
                                       -Parameter $params `
                                       -PolicyDefinition $definitions `
                                       -Name $initiativeSource.name

        $fileCounter++
    }
}