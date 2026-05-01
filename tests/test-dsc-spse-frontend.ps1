#Requires -PSEdition Desktop

$randomChars = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 8 | ForEach-Object { [char] $_ })
$password = New-Object -TypeName System.Security.SecureString
$randomChars.ToCharArray() | ForEach-Object { $password.AppendChar($_) }
$password.MakeReadOnly()

$DomainAdminCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "yvand", $password
$SPSetupCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "spsetup", $password
$SPFarmCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "spfarm", $password
$SPPassphraseCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "Passphrase", $password
$DNSServerIP = "10.1.1.4"
$DomainFQDN = "contoso.local"
$DCServerName = "DC"
$SQLServerName = "SQL"
$SQLAlias = "SQLAlias"
$SharePointVersion = "SPRTM" #"SPLatest"
$SharePointSitesAuthority = "spsites"
$EnableAnalysis = $true
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