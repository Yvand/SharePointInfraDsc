#Requires -PSEdition Desktop

param(
    [Parameter(Mandatory = $true)] [System.Security.SecureString] $password
)

$functionName = "ConfigDc"
$Admincreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "yvand", $password
$AdfsSvcCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "adfssvc", $password
$SqlSvcCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqlsvc", $password
$SPSetupCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "spsetup", $password
$DomainFQDN = "contoso.local"
$PrivateIP = "10.1.1.100"
$SPServerName = "SP"
$SharePointSitesAuthority = "spsites"
$SharePointCentralAdminPort = 5000

$functionArgs = @{
    "Admincreds" = $Admincreds
    "AdfsSvcCreds" = $AdfsSvcCreds
    "SqlSvcCreds" = $SqlSvcCreds
    "SPSetupCreds" = $SPSetupCreds
    "DomainFQDN" = $DomainFQDN
    "PrivateIP" = $PrivateIP
    "SPServerName" = $SPServerName
    "SharePointSitesAuthority" = $SharePointSitesAuthority
    "SharePointCentralAdminPort" = $SharePointCentralAdminPort
}

return @{
    "functionName" = $functionName
    "functionArgs" = $functionArgs
}