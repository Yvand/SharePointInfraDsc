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
$DNSServerIP = "10.1.1.4"
$DomainFQDN = "contoso.local"
$DCServerName = "DC"
$SQLServerName = "SQL"
$SQLAlias = "SQLAlias"
$SharePointVersion = "2019"
$SharePointSitesAuthority = "spsites"
$SharePointCentralAdminPort = 5000
$EnableAnalysis = $true
$SharePointBits = @()

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
    "SharePointBits" = $SharePointBits
}

return @{
    "functionName" = $functionName
    "functionArgs" = $functionArgs
}
