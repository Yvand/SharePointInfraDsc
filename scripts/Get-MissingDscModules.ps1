#Requires -Module Az.Compute

param(
    [string] $dscFilePath
)

#Import-Module Az.Compute
$dscFilePathResolved = Resolve-Path -Path $dscFilePath -ErrorAction SilentlyContinue
if (Test-Path -PathType Leaf -Path $dscFilePathResolved) {
    Write-Host "Getting module dependencies for DSC file '$dscFilePathResolved'" -ForegroundColor Cyan
    $parseResult = [Microsoft.WindowsAzure.Commands.Common.Extensions.DSC.Publish.ConfigurationParsingHelper]::ParseConfiguration($dscFilePathResolved)
    # return $parseResult.RequiredModules
    Write-Host "$($parseResult.Errors.Count) errors"
    foreach ($parseErr in $parseResult.Errors) { Write-Host "Error: '$($parseErr.Message)' ($($parseErr.ErrorId) - $($parseErr.Extent))" }
    return $parseResult.Errors | Where-Object ErrorId -eq "ModuleNotFoundDuringParse" | Select-Object -Property Extent
}
else {
    Write-Host "file '$dscFilePath' not found" -ForegroundColor Red
}