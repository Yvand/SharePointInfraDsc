#Requires -PSEdition Core
#Requires -Modules GuestConfiguration, PSDesiredStateConfiguration

param(
    [Parameter(Mandatory = $false)] [string] $vmName = "*",
    [Parameter(Mandatory = $false)] [ValidateSet("Audit", "AuditAndSet")] [string] $packageType = "AuditAndSet",
    [Parameter(Mandatory = $false)] [string] $mofFolderPath = ""
)

$ErrorActionPreference = "Stop"

$dscFolderPath = Join-Path -Path $PSScriptRoot -ChildPath "../src" | Resolve-Path
$mofFolder = if ($mofFolderPath) { Resolve-Path -Path $mofFolderPath } else { $dscFolderPath }

if (-not (Test-Path -PathType Container -Path $dscFolderPath)) {
    throw "folder '$dscFolderPath' not found"
}

if ($vmName.StartsWith("dsc-")) { $vmName = $vmName.Substring(4) }
$mofFiles = Get-ChildItem $mofFolder -File -Filter "dsc-$vmName*.mof"
if (-not $mofFiles) {
    throw "No compiled MOF files found in '$mofFolder'. Compile the configuration with PowerShell 7.2 first. Machine configuration packages cannot be compiled with secret parameters in this script."
}

foreach ($mofFile in $mofFiles) {
    Write-Host "Creating machine configuration package for '$($mofFile.BaseName)'..." -ForegroundColor Cyan
    $package = New-GuestConfigurationPackage -Name $mofFile.BaseName -Configuration $mofFile.FullName -Type $packageType -Path $mofFile.DirectoryName -Force
    Test-GuestConfigurationPackage -Path $package.Path
    Write-Host "Created '$($package.Path)'." -ForegroundColor Green
}