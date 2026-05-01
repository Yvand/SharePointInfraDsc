#Requires -PSEdition Desktop

param(
    [Parameter(Mandatory = $true)] [System.Security.SecureString] $password
)

$functionName = "ConfigSpMain"
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
$SharePointConfigurationLevel = "Full"
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

$functionArgs = @{
    "DomainAdminCreds" = $DomainAdminCreds
    "SPSetupCreds" = $SPSetupCreds
    "SPFarmCreds" = $SPFarmCreds
    "SPSvcCreds" = $SPSvcCreds
    "SPAppPoolCreds" = $SPAppPoolCreds
    "SPADDirSyncCreds" = $SPADDirSyncCreds
    "SPPassphraseCreds" = $SPPassphraseCreds
    "SPSuperUserCreds" = $SPSuperUserCreds
    "SPSuperReaderCreds" = $SPSuperReaderCreds
    "DNSServerIP" = $DNSServerIP
    "DomainFQDN" = $DomainFQDN
    "DCServerName" = $DCServerName
    "SQLServerName" = $SQLServerName
    "SQLAlias" = $SQLAlias
    "SharePointVersion" = $SharePointVersion
    "SharePointSitesAuthority" = $SharePointSitesAuthority
    "SharePointCentralAdminPort" = $SharePointCentralAdminPort
    "EnableAnalysis" = $EnableAnalysis
    "DefaultZoneMustBeHttps" = $DefaultZoneMustBeHttps
    "SharePointConfigurationLevel" = $SharePointConfigurationLevel
    "CustomSharePointConfiguration" = $CustomSharePointConfiguration
    "SharePointBits" = $SharePointBits
}

return @{
    "functionName" = $functionName
    "functionArgs" = $functionArgs
}