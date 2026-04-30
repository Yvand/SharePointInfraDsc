$randomChars = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 8 | % { [char] $_ })
$password = ConvertTo-SecureString -String "$randomChars" -AsPlainText -Force

$DomainAdminCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "yvand", $password
$SPSetupCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "spsetup", $password
$SPFarmCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "spfarm", $password
$SPSvcCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "spsvc", $password
$SPAppPoolCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "spapppool", $password
$SPADDirSyncCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "spaddirsync", $password
$SPPassphraseCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "Passphrase", $password
$SPSuperUserCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "spSuperUser", $password
$SPSuperReaderCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "spSuperReader", $password
$DNSServerIP = "10.1.1.4"
$DomainFQDN = "contoso.local"
$DCServerName = "DC"
$SQLServerName = "SQL"
$SQLAlias = "SQLAlias"
$SharePointVersion = "2019"
$SharePointSitesAuthority = "spsites"
$SharePointCentralAdminPort = 5000
$EnableAnalysis = $true

$configFileName = (Split-Path $PSCommandPath -Leaf).Substring(5)
$functionName = "ConfigSpMain"
$outputPath = "."
Push-Location $PSScriptRoot
try
{
    . ".\$configFileName"
    & $functionName -DomainAdminCreds $DomainAdminCreds -SPSetupCreds $SPSetupCreds -SPFarmCreds $SPFarmCreds -SPSvcCreds $SPSvcCreds -SPAppPoolCreds $SPAppPoolCreds -SPADDirSyncCreds $SPADDirSyncCreds -SPPassphraseCreds $SPPassphraseCreds -SPSuperUserCreds $SPSuperUserCreds -SPSuperReaderCreds $SPSuperReaderCreds -DNSServerIP $DNSServerIP -DomainFQDN $DomainFQDN -DCServerName $DCServerName -SQLServerName $SQLServerName -SQLAlias $SQLAlias -SharePointVersion $SharePointVersion -SharePointSitesAuthority $SharePointSitesAuthority -SharePointCentralAdminPort $SharePointCentralAdminPort -EnableAnalysis $EnableAnalysis -ConfigurationData @{AllNodes=@(@{ NodeName="localhost"; PSDscAllowPlainTextPassword=$true })} -OutputPath $outputPath
    Remove-Item -Path "$outputPath\$functionName" -Recurse
}
finally
{
    Pop-Location
}