#Requires -PSEdition Desktop

param(
    [Parameter(Mandatory = $false)] [string] $vmName = "*"
)

$dscFolderPath = Join-Path -Path $PSScriptRoot -ChildPath "../src" | Resolve-Path
$testFolderPath = Join-Path -Path $PSScriptRoot -ChildPath "../tests" | Resolve-Path
if ($vmName.StartsWith("dsc-")) { $vmName = $vmName.Substring(4) }

$randomChars = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 8 | ForEach-Object { [char] $_ })
$password = New-Object -TypeName System.Security.SecureString
$randomChars.ToCharArray() | ForEach-Object { $password.AppendChar($_) }
$password.MakeReadOnly()

function Invoke-Test {
    param(
        [Parameter(Mandatory = $true)] [string] $testFileName,
        [Parameter(Mandatory = $true)] [string] $functionName,
        [Parameter(Mandatory = $true)] [hashtable] $functionArgs
    )
    
    $configFileName = $testFileName.Substring(5)
    $configFilePath = Get-ChildItem $dscFolderPath -File -Filter "$configFileName.ps1" | Resolve-Path
    $outputPath = Join-Path -Path $testFolderPath -ChildPath "$functionName"

    $functionArgsPath = [System.IO.Path]::ChangeExtension([System.IO.Path]::GetTempFileName(), ".clixml")
    $runnerScriptPath = [System.IO.Path]::ChangeExtension([System.IO.Path]::GetTempFileName(), ".ps1")
    try {
        # Simple version: Run the test in the current session instead of a new PowerShell session, which is faster and allows debugging if needed.
        # . "$configFilePath"
        # & $functionName @functionArgs -outputPath $outputPath -ConfigurationData @{AllNodes=@(@{ NodeName="localhost"; PSDscAllowPlainTextPassword=$true })}

        $functionArgs | Export-Clixml -Path $functionArgsPath

        @'
param(
    [Parameter(Mandatory = $true)] [string] $ConfigFilePath,
    [Parameter(Mandatory = $true)] [string] $FunctionName,
    [Parameter(Mandatory = $true)] [string] $FunctionArgsPath,
    [Parameter(Mandatory = $true)] [string] $OutputPath
)

$functionArgs = Import-Clixml -Path $FunctionArgsPath
. $ConfigFilePath
& $FunctionName @functionArgs -OutputPath $OutputPath -ConfigurationData @{AllNodes=@(@{ NodeName="localhost"; PSDscAllowPlainTextPassword=$true })}
'@ | Set-Content -Path $runnerScriptPath

        & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $runnerScriptPath -ConfigFilePath $configFilePath -FunctionName $functionName -FunctionArgsPath $functionArgsPath -OutputPath $outputPath
        if ($LASTEXITCODE -ne 0) {
            throw "DSC test '$testFileName' failed in isolated PowerShell session with exit code $LASTEXITCODE."
        }
    }
    finally {
        if (Test-Path -Path $functionArgsPath) { Remove-Item -Path $functionArgsPath -Force }
        if (Test-Path -Path $runnerScriptPath) { Remove-Item -Path $runnerScriptPath -Force }
        if (Test-Path -Path $outputPath) { Remove-Item -Path $outputPath -Recurse -Force }
    }
}

$testFileNamePattern = "test-{0}"
$dscSourceFilesPath = Get-ChildItem $dscFolderPath -File -Filter "dsc-$vmName*.ps1"
foreach ($dscSourceFilePath in $dscSourceFilesPath) {
    $testFileName = [string]::Format($testFileNamePattern, $dscSourceFilePath.BaseName)
    $testFilePath = Join-Path -Path $testFolderPath -ChildPath "$testFileName.ps1" -Resolve
    Write-Host "Run test '$testFileName'..." -ForegroundColor Cyan

    $testParameters = . $testFilePath -password $password
    Invoke-Test -testFileName "$testFileName" -functionName $testParameters.functionName -functionArgs $testParameters.functionArgs
}