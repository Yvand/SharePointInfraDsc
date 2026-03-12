# #Requires -PSEdition Desktop
#Requires -Module Az.Compute

param(
    [string] $vmName = "*",
    [string] $dscFolderPath
)

if (Test-Path -PathType Container -Path $dscFolderPath) {
    if ($vmName.StartsWith("dsc-")) { $vmName = $vmName.Substring(4) }
    Write-Host "Generating DSC archives in folder '$dscFolderPath' for '$vmName'" -ForegroundColor Cyan
    $dscSourceFilePaths = Get-ChildItem $dscFolderPath -File -Filter "dsc-$vmName*.ps1"
    foreach ($dscSourceFilePath in $dscSourceFilePaths) {
        $dscArchiveFilePath = "$($dscSourceFilePath.DirectoryName)\$($dscSourceFilePath.BaseName).zip"
        Publish-AzVMDscConfiguration -ConfigurationPath "$dscFolderPath\$($dscSourceFilePath.Name)" -OutputArchivePath $dscArchiveFilePath -Force -Verbose
    }
}
else {  
    Write-Host "folder '$dscFolderPath' not found" -ForegroundColor Red
}