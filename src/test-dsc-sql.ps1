#Requires -PSEdition Desktop

$randomChars = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 8 | % { [char] $_ })
$password = ConvertTo-SecureString -String "$randomChars" -AsPlainText -Force

$DomainAdminCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "yvand", $password
$SqlSvcCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqlsvc", $password
$DNSServerIP = "10.1.1.100"
$DomainFQDN = "contoso.local"
$SPSetupUserName = "spsetup"

$configFileName = [IO.Path]::GetFileNameWithoutExtension($PSCommandPath).Substring(5)
$functionName = "ConfigSql"
$outputPath = ".\$configFileName"
Push-Location $PSScriptRoot
try
{
    . ".\$configFileName.ps1"
    & $functionName -DNSServerIP $DNSServerIP -DomainFQDN $DomainFQDN -DomainAdminCreds $DomainAdminCreds -SqlSvcCreds $SqlSvcCreds -SPSetupUserName $SPSetupUserName -ConfigurationData @{AllNodes=@(@{ NodeName="localhost"; PSDscAllowPlainTextPassword=$true })} -OutputPath $outputPath
    Remove-Item -Path $outputPath -Recurse
}
finally
{
    Pop-Location
}