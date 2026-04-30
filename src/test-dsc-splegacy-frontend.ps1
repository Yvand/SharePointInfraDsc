#Requires -PSEdition Desktop

$randomChars = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 8 | % { [char] $_ })
$password = ConvertTo-SecureString -String "$randomChars" -AsPlainText -Force

$password = ConvertTo-SecureString -String "mytopsecurepassword" -AsPlainText -Force
$DomainAdminCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "yvand", $password
$SPSetupCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "spsetup", $password
$SPFarmCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "spfarm", $password
$SPPassphraseCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "Passphrase", $password
$DNSServerIP = "10.1.1.4"
$DomainFQDN = "contoso.local"
$DCServerName = "DC"
$SQLServerName = "SQL"
$SQLAlias = "SQLAlias"
$SharePointVersion = "2019"
$SharePointSitesAuthority = "spsites"
$EnableAnalysis = $false
$SharePointBits = @()

$configFileName = [IO.Path]::GetFileNameWithoutExtension($PSCommandPath).Substring(5)
$functionName = "ConfigSpFrontend"
$outputPath = ".\$configFileName"
Push-Location $PSScriptRoot
try
{
    . ".\$configFileName.ps1"
    & $functionName -DomainAdminCreds $DomainAdminCreds -SPSetupCreds $SPSetupCreds -SPFarmCreds $SPFarmCreds -SPPassphraseCreds $SPPassphraseCreds -DNSServerIP $DNSServerIP -DomainFQDN $DomainFQDN -DCServerName $DCServerName -SQLServerName $SQLServerName -SQLAlias $SQLAlias -SharePointVersion $SharePointVersion -SharePointSitesAuthority $SharePointSitesAuthority -EnableAnalysis $EnableAnalysis -SharePointBits $SharePointBits -ConfigurationData @{AllNodes=@(@{ NodeName="localhost"; PSDscAllowPlainTextPassword=$true })} -OutputPath $outputPath
    Remove-Item -Path $outputPath -Recurse
}
finally
{
    Pop-Location
}