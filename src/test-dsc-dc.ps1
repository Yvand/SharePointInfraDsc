$randomChars = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 8 | % { [char] $_ })
$password = ConvertTo-SecureString -String "$randomChars" -AsPlainText -Force

$Admincreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "yvand", $password
$AdfsSvcCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "adfssvc", $password
$SqlSvcCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqlsvc", $password
$SPSetupCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "spsetup", $password
$DomainFQDN = "contoso.local"
$PrivateIP = "10.1.1.100"
$SPServerName = "SP"
$SharePointSitesAuthority = "spsites"
$SharePointCentralAdminPort = 5000

$configFileName = (Split-Path $PSCommandPath -Leaf).Substring(5)
$functionName = "ConfigDc"
$outputPath = "."
Push-Location $PSScriptRoot
try
{
    . ".\$configFileName"
    & $functionName -Admincreds $Admincreds -AdfsSvcCreds $AdfsSvcCreds -SqlSvcCreds $SqlSvcCreds -SPSetupCreds $SPSetupCreds -DomainFQDN $DomainFQDN -PrivateIP $PrivateIP -SPServerName $SPServerName -SharePointSitesAuthority $SharePointSitesAuthority -SharePointCentralAdminPort $SharePointCentralAdminPort -ConfigurationData @{AllNodes=@(@{ NodeName="localhost"; PSDscAllowPlainTextPassword=$true })} -OutputPath $outputPath
    Remove-Item -Path "$outputPath\$functionName" -Recurse
}
finally
{
    Pop-Location
}