#Requires -PSEdition Desktop

param(
    [Parameter(Mandatory = $true)] [System.Security.SecureString] $password
)

$functionName = "ConfigSpFrontend"
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

$functionArgs = @{
    "DomainAdminCreds" = $DomainAdminCreds
    "SPSetupCreds" = $SPSetupCreds
    "SPFarmCreds" = $SPFarmCreds
    "SPPassphraseCreds" = $SPPassphraseCreds
    "DNSServerIP" = $DNSServerIP
    "DomainFQDN" = $DomainFQDN
    "DCServerName" = $DCServerName
    "SQLServerName" = $SQLServerName
    "SQLAlias" = $SQLAlias
    "SharePointVersion" = $SharePointVersion
    "SharePointSitesAuthority" = $SharePointSitesAuthority
    "EnableAnalysis" = $EnableAnalysis
    "SharePointBits" = $SharePointBits
}

return @{
    "functionName" = $functionName
    "functionArgs" = $functionArgs
}