#Requires -Module Az.Compute

param(
    [string] $dscFilePath
)

#Import-Module Az.Compute
if (Test-Path $dscFilePath) {
    Write-Host "Getting module dependencies for DSC file '$dscFilePath'" -ForegroundColor Cyan
    $parseResult = [Microsoft.WindowsAzure.Commands.Common.Extensions.DSC.Publish.ConfigurationParsingHelper]::ParseConfiguration($dscFilePath)
    return $parseResult.RequiredModules
}
else {  
    Write-Host "file '$dscFilePath' not found" -ForegroundColor Red
}