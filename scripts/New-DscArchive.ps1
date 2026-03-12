#Requires -PSEdition Desktop #reason: https://github.com/dsccommunity/DnsServerDsc/issues/264
#Requires -Module Az.Compute

param(
    [string] $vmName = "*",
    [string] $dscFolderPath
)

if (-not (Test-Path -PathType Container -Path $dscFolderPath)) {
    throw "folder '$dscFolderPath' not found"
}

if ($vmName.StartsWith("dsc-")) { $vmName = $vmName.Substring(4) }
$dscSourceFilePaths = Get-ChildItem $dscFolderPath -File -Filter "dsc-$vmName*.ps1"
foreach ($dscSourceFilePath in $dscSourceFilePaths) {
    Write-Host "Creating DSC archive for '$($dscSourceFilePath.BaseName)' in folder '$dscFolderPath'..." -ForegroundColor Cyan
    $dscArchiveFilePath = "$($dscSourceFilePath.DirectoryName)\$($dscSourceFilePath.BaseName).zip"
    Publish-AzVMDscConfiguration -ConfigurationPath "$dscFolderPath\$($dscSourceFilePath.Name)" -OutputArchivePath $dscArchiveFilePath -Force #-Verbose
}
    