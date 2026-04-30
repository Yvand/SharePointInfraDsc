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
$DNSServerIP = "10.1.1.100"
$DomainFQDN = "contoso.local"
$DCServerName = "DC"
$SQLServerName = "SQL"
$SQLAlias = "SQLAlias"
$SharePointVersion = "SPRTM" #"SPLatest"
$SharePointSitesAuthority = "spsites"
$SharePointCentralAdminPort = 5000
$EnableAnalysis = $true
$DefaultZoneMustBeHttps = $false
$SharePointConfigurationLevel = "Light"
$CustomSharePointConfiguration = @("TrustedAuthentication", "UserProfilesService", "ExtendedWebApplication", "Addins", "AdditionalSiteCollections", "StateService")
$SharePointBits = @(
    @{
        Label = "SPRTM"; 
        Packages = @(
            @{ DownloadUrl = "https://go.microsoft.com/fwlink/?linkid=2171943"; ChecksumType = "SHA256"; Checksum = "C576B847C573234B68FC602A0318F5794D7A61D8149EB6AE537AF04470B7FC05" }
        )
    },
    @{
        Label = "SPLatest"; 
        Packages = @(
            @{ DownloadUrl = "https://download.microsoft.com/download/f839c57c-7b4e-4213-b03b-2c1508e13588/uber-subscription-kb5002853-fullfile-x64-glb.exe" }
        )
    }
)

$configFileName = (Split-Path $PSCommandPath -Leaf).Substring(5)
$functionName = "ConfigSpMain"
$outputPath = "."
Push-Location $PSScriptRoot
try
{
    . ".\$configFileName"
    & $functionName -DomainAdminCreds $DomainAdminCreds -SPSetupCreds $SPSetupCreds -SPFarmCreds $SPFarmCreds -SPSvcCreds $SPSvcCreds -SPAppPoolCreds $SPAppPoolCreds -SPADDirSyncCreds $SPADDirSyncCreds -SPPassphraseCreds $SPPassphraseCreds -SPSuperUserCreds $SPSuperUserCreds -SPSuperReaderCreds $SPSuperReaderCreds -DNSServerIP $DNSServerIP -DomainFQDN $DomainFQDN -DCServerName $DCServerName -SQLServerName $SQLServerName -SQLAlias $SQLAlias -SharePointVersion $SharePointVersion -SharePointSitesAuthority $SharePointSitesAuthority -SharePointCentralAdminPort $SharePointCentralAdminPort -EnableAnalysis $EnableAnalysis -DefaultZoneMustBeHttps $DefaultZoneMustBeHttps -SharePointConfigurationLevel $SharePointConfigurationLevel -CustomSharePointConfiguration $CustomSharePointConfiguration -SharePointBits $SharePointBits -ConfigurationData @{AllNodes=@(@{ NodeName="localhost"; PSDscAllowPlainTextPassword=$true })} -OutputPath $outputPath
    Remove-Item -Path "$outputPath\$functionName" -Recurse
}
finally
{
    Pop-Location
}