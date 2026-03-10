#Requires -PSEdition Desktop
#Requires -Module Az.Compute

# Get-Command -Verb Publish -Noun AzVM* -Module Az.Compute

param(
    [string] $dscConfigFile = "*",
    [string] $dscFolderPath
)

if (Test-Path $dscFolderPath) {
    Write-Host "Generating DSC archives in folder '$dscFolderPath' for '$dscConfigFile'" -ForegroundColor Cyan
    $dscSourceFilePaths = Get-ChildItem $dscFolderPath -File -Filter "$dscConfigFile*.ps1"
    foreach ($dscSourceFilePath in $dscSourceFilePaths) {
        $dscArchiveFilePath = "$($dscSourceFilePath.DirectoryName)\$($dscSourceFilePath.BaseName).zip"
        Publish-AzVMDscConfiguration -ConfigurationPath "$dscFolderPath\$($dscSourceFilePath.Name)" -OutputArchivePath $dscArchiveFilePath -Force -Verbose
    }
}
else {  
    Write-Host "folder '$dscFolderPath' not found" -ForegroundColor Red
}