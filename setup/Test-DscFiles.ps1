#Requires -PSEdition Desktop

param(
    [Parameter(Mandatory = $false)] [string] $vmName = "*",
    [Parameter(Mandatory = $false)] [string] $dscFolderPath = ".\src\"
)

if (-not (Test-Path -PathType Container -Path $dscFolderPath)) {
    throw "folder '$dscFolderPath' not found"
}

$testFileNamePattern = "test-{0}"
if ($vmName.StartsWith("dsc-")) { $vmName = $vmName.Substring(4) }

$dscSourceFilePaths = Get-ChildItem $dscFolderPath -File -Filter "dsc-$vmName*.ps1"
foreach ($dscSourceFilePath in $dscSourceFilePaths) {
    $testFileName = [string]::Format($testFileNamePattern, $dscSourceFilePath.BaseName)
    if (-not (Test-Path -PathType Leaf -Path "$($dscSourceFilePath.DirectoryName)\$($testFileName).ps1")) {
        throw "test file '$testFileName.ps1' is missing."
    }
    
    Write-Host "Run test '$testFileName'..." -ForegroundColor Cyan
    try {
        . "$($dscSourceFilePath.DirectoryName)\$($testFileName).ps1"
    }
    catch {
        Write-Error "test '$testFileName' failed: $($_.Exception.Message)"
        return
    }
}