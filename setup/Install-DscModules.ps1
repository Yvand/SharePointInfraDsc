#Requires -PSEdition Desktop #reason: https://github.com/dsccommunity/DnsServerDsc/issues/264 / https://github.com/dsccommunity/DnsServerDsc/issues/268
#Requires -RunAsAdministrator #reason: Install-Module with -Scope AllUsers requires admin privileges

param(
    [Parameter(Mandatory=$false)] [string] $vmName,
    [Parameter(Mandatory=$false)] [bool] $copyCustomizedModules = $false
)

# Ensure prerequisites are installed
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
$psGalleryRepo = Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue
if (-not $psGalleryRepo) {
    # Register the default PSGallery repository if it is not present
    Register-PSRepository -Default
    $psGalleryRepo = Get-PSRepository -Name PSGallery -ErrorAction Stop
}
if ($psGalleryRepo.InstallationPolicy -ne "Trusted") {
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}
if (-not (Get-InstalledModule -Name "Az.Compute" -ErrorAction SilentlyContinue)) {
    Install-Module Az.Compute -Scope AllUsers
}

$dscFolderPath = Join-Path -Path $PSScriptRoot -ChildPath "../src" | Resolve-Path
$scritpsFolderPath = Join-Path -Path $PSScriptRoot -ChildPath "../setup" | Resolve-Path
$customizedModulesPath = Join-Path -Path $PSScriptRoot -ChildPath "../customized-modules" | Resolve-Path

Write-Host "Get DSC files in folder '$dscFolderPath'" -ForegroundColor Cyan
$dscFilesPath = Get-ChildItem "$dscFolderPath" -File -Filter "dsc-$vmName*.ps1"
foreach ($dscFilePath in $dscFilesPath) {
    $dscMissingModules = & "$($scritpsFolderPath)/Get-MissingDscModules.ps1" -dscFilePath "$($dscFilePath.FullName)"
    Write-Host "Found $($dscMissingModules.Count) missing DSC module(s) for '$dscFilePath'."
    foreach ($dscMissingModule in $dscMissingModules) {
        Write-Host "Installing module '$($dscMissingModule.Name)' version '$($dscMissingModule.Version)'..."
        Install-Module -Name $dscMissingModule.Name -RequiredVersion $dscMissingModule.Version -Scope AllUsers
    }
}

if ($copyCustomizedModules) {
    Write-Host "Overwrite DSC modules with the customized ones..." -ForegroundColor Cyan
    $customizedModules = Get-ChildItem -Path $customizedModulesPath -Directory
    foreach ($customizedModule in $customizedModules) {
        $destinationPath = "$($env:ProgramFiles)\WindowsPowerShell\Modules\$($customizedModule.Name)"
        if (Test-Path -Path $destinationPath) {
            Write-Host "Removing existing module '$($customizedModule.Name)' from '$destinationPath'..." -ForegroundColor Yellow
            Remove-Item -Path $destinationPath -Recurse -Force
        }
        Write-Host "Copying customized module '$($customizedModule.Name)' to '$destinationPath'..." -ForegroundColor Green
        Copy-Item -Path $customizedModule.FullName -Destination $destinationPath -Recurse
    }
}