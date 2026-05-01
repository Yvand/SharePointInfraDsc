#Requires -PSEdition Desktop

param(
    [Parameter(Mandatory = $false)] [string] $vmName = "*"
)

$dscFolderPath = Join-Path -Path $PSScriptRoot -ChildPath "../src" | Resolve-Path
$testFolderPath = Join-Path -Path $PSScriptRoot -ChildPath "../tests" | Resolve-Path

$testFileNamePattern = "test-{0}"
if ($vmName.StartsWith("dsc-")) { $vmName = $vmName.Substring(4) }

$dscSourceFilesPath = Get-ChildItem $dscFolderPath -File -Filter "dsc-$vmName*.ps1"
foreach ($dscSourceFilePath in $dscSourceFilesPath) {
    $testFileName = [string]::Format($testFileNamePattern, $dscSourceFilePath.BaseName)
    $testFilePath = Join-Path -Path $testFolderPath -ChildPath "$testFileName.ps1" -Resolve
    Write-Host "Run test '$testFileName'..." -ForegroundColor Cyan
    . $testFilePath
}