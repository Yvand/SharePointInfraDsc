#Requires -Module Az.Compute

param(
    [string] $dscFilePath
)

#Import-Module Az.Compute
$dscFilePathResolved = Resolve-Path -Path $dscFilePath -ErrorAction SilentlyContinue
if (Test-Path -PathType Leaf -Path $dscFilePathResolved) {
    Write-Host "Getting module dependencies for DSC file '$dscFilePathResolved'" -ForegroundColor Cyan
    $parseResult = [Microsoft.WindowsAzure.Commands.Common.Extensions.DSC.Publish.ConfigurationParsingHelper]::ParseConfiguration($dscFilePathResolved)
    
    $missingModules = @()
    foreach ($parseErr in $parseResult.Errors | Where-Object ErrorId -eq "ModuleNotFoundDuringParse") { 
        # Typical message: "Could not find the module '<ActiveDirectoryDsc, 6.7.0>'."
        if ($parseErr.Message -match "<(?<module>\w*),\s(?<version>[\d|.]*)>") {
            $moduleName = $matches['module']
            $moduleVersion = $matches['version']
            # Write-Host "Module '$moduleName' version '$moduleVersion' is missing" -ForegroundColor Yellow
            $missingModules += [PSCustomObject]@{
                Name = $moduleName
                Version = $moduleVersion
            }
        }
     }
    return $missingModules
}
else {
    Write-Host "file '$dscFilePath' not found" -ForegroundColor Red
}