#Requires -PSEdition Desktop

param(
    [Parameter(Mandatory = $false)] [string] $vmName = "*"
)

$dscFolderPath = Join-Path -Path $PSScriptRoot -ChildPath "../src" | Resolve-Path

if (-not (Test-Path -PathType Container -Path $dscFolderPath)) {
    throw "folder '$dscFolderPath' not found"
}

$testFileNamePattern = "test-{0}"
if ($vmName.StartsWith("dsc-")) { $vmName = $vmName.Substring(4) }

$dscSourceFilesPath = Get-ChildItem $dscFolderPath -File -Filter "dsc-$vmName*.ps1"
foreach ($dscSourceFilePath in $dscSourceFilesPath) {
    $testFileName = [string]::Format($testFileNamePattern, $dscSourceFilePath.BaseName)
    $testFilePath = Join-Path -Path $dscFolderPath -ChildPath "$testFileName.ps1" -Resolve
    Write-Host "Run test '$testFileName'..." -ForegroundColor Cyan
    . $testFilePath
}