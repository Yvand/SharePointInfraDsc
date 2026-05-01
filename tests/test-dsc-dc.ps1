#Requires -PSEdition Desktop

$randomChars = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 8 | ForEach-Object { [char] $_ })
$password = New-Object -TypeName System.Security.SecureString
$randomChars.ToCharArray() | ForEach-Object { $password.AppendChar($_) }
$password.MakeReadOnly()

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
    "ConfigurationData" = @{AllNodes=@(@{ NodeName="localhost"; PSDscAllowPlainTextPassword=$true })}
}

return @{
    "functionName" = $functionName
    "functionArgs" = $functionArgs
}



# $dscFolderPath = Join-Path -Path $PSScriptRoot -ChildPath "../src" | Resolve-Path
# $configFileName = [IO.Path]::GetFileNameWithoutExtension($PSCommandPath).Substring(5)
# $configFilePath = Get-ChildItem $dscFolderPath -File -Filter "$configFileName.ps1"  | Resolve-Path
# $outputPath = ".\$configFileName"

# $randomChars = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 8 | ForEach-Object { [char] $_ })
# $password = New-Object -TypeName System.Security.SecureString
# $randomChars.ToCharArray() | ForEach-Object { $password.AppendChar($_) }
# $password.MakeReadOnly()

# $functionName = "ConfigDc"
# $Admincreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "yvand", $password
# $AdfsSvcCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "adfssvc", $password
# $SqlSvcCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqlsvc", $password
# $SPSetupCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "spsetup", $password
# $DomainFQDN = "contoso.local"
# $PrivateIP = "10.1.1.100"
# $SPServerName = "SP"
# $SharePointSitesAuthority = "spsites"
# $SharePointCentralAdminPort = 5000

# try
# {
#     . "$configFilePath"
    
#     $functionArgs = @{
#         "Admincreds" = $Admincreds
#         "AdfsSvcCreds" = $AdfsSvcCreds
#         "SqlSvcCreds" = $SqlSvcCreds
#         "SPSetupCreds" = $SPSetupCreds
#         "DomainFQDN" = $DomainFQDN
#         "PrivateIP" = $PrivateIP
#         "SPServerName" = $SPServerName
#         "SharePointSitesAuthority" = $SharePointSitesAuthority
#         "SharePointCentralAdminPort" = $SharePointCentralAdminPort
#         "ConfigurationData" = @{AllNodes=@(@{ NodeName="localhost"; PSDscAllowPlainTextPassword=$true })}
#         "OutputPath" = $outputPath
#     }

#     & $functionName @functionArgs
# }
# finally
# {
#     Remove-Item -Path $outputPath -Recurse
# }