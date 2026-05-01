#Requires -PSEdition Desktop

param(
    [Parameter(Mandatory = $true)] [System.Security.SecureString] $password
)

$functionName = "ConfigSql"
$DomainAdminCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "yvand", $password
$SqlSvcCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqlsvc", $password
$DNSServerIP = "10.1.1.100"
$DomainFQDN = "contoso.local"
$SPSetupUserName = "spsetup"

$functionArgs = @{
    "DomainAdminCreds" = $DomainAdminCreds
    "SqlSvcCreds" = $SqlSvcCreds
    "DNSServerIP" = $DNSServerIP
    "DomainFQDN" = $DomainFQDN
    "SPSetupUserName" = $SPSetupUserName
}

return @{
    "functionName" = $functionName
    "functionArgs" = $functionArgs
}