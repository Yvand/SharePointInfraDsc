#Requires -PSEdition Desktop

$randomChars = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 8 | ForEach-Object { [char] $_ })
$password = New-Object -TypeName System.Security.SecureString
$randomChars.ToCharArray() | ForEach-Object { $password.AppendChar($_) }
$password.MakeReadOnly()

$Admincreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "yvand", $password
$AdfsSvcCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "adfssvc", $password
$SqlSvcCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqlsvc", $password
$SPSetupCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "spsetup", $password
$DomainFQDN = "contoso.local"
$PrivateIP = "10.1.1.100"
$SPServerName = "SP"
$SharePointSitesAuthority = "spsites"
$SharePointCentralAdminPort = 5000

$configFileName = [IO.Path]::GetFileNameWithoutExtension($PSCommandPath).Substring(5)
$functionName = "ConfigDc"
$outputPath = ".\$configFileName"
Push-Location $PSScriptRoot
try
{
    . ".\$configFileName.ps1"
    & $functionName -Admincreds $Admincreds -AdfsSvcCreds $AdfsSvcCreds -SqlSvcCreds $SqlSvcCreds -SPSetupCreds $SPSetupCreds -DomainFQDN $DomainFQDN -PrivateIP $PrivateIP -SPServerName $SPServerName -SharePointSitesAuthority $SharePointSitesAuthority -SharePointCentralAdminPort $SharePointCentralAdminPort -ConfigurationData @{AllNodes=@(@{ NodeName="localhost"; PSDscAllowPlainTextPassword=$true })} -OutputPath $outputPath
    Remove-Item -Path $outputPath -Recurse
}
finally
{
    Pop-Location
}