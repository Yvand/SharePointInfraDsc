#Requires -PSEdition Desktop #reason: https://github.com/dsccommunity/DnsServerDsc/issues/264 / https://github.com/dsccommunity/DnsServerDsc/issues/268
#Requires -Module Az.Compute

param(
    [Parameter(Mandatory=$false)] [string] $vmName = "*"
)

$ErrorActionPreference = "Stop"

$dscFolderPath = Join-Path -Path $PSScriptRoot -ChildPath "../src" | Resolve-Path
$scriptsFolderPath = Join-Path -Path $PSScriptRoot -ChildPath "../setup" | Resolve-Path

if (-not (Test-Path -PathType Container -Path $dscFolderPath)) {
    throw "folder '$dscFolderPath' not found"
}

# Ensure DSC file can successfully generate the MOF file before generating the archive
& "$($scriptsFolderPath)/Test-DscFiles.ps1" -vmName $vmName

if ($vmName.StartsWith("dsc-")) { $vmName = $vmName.Substring(4) }
$dscSourceFilePaths = Get-ChildItem $dscFolderPath -File -Filter "dsc-$vmName*.ps1"
foreach ($dscSourceFilePath in $dscSourceFilePaths) {
    Write-Host "Creating DSC archive for '$($dscSourceFilePath.BaseName)' in folder '$dscFolderPath'..." -ForegroundColor Cyan
    $dscArchiveFilePath = "$($dscSourceFilePath.DirectoryName)\$($dscSourceFilePath.BaseName).zip"
    Publish-AzVMDscConfiguration -ConfigurationPath "$dscFolderPath\$($dscSourceFilePath.Name)" -OutputArchivePath $dscArchiveFilePath -Force #-Verbose
}