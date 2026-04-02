@{
    # Script module or binary module file associated with this manifest.
    RootModule           = 'SqlServerDsc.psm1'

    # Version number of this module.
    ModuleVersion        = '17.5.1'

    # ID used to uniquely identify this module
    GUID                 = '693ee082-ed36-45a7-b490-88b07c86b42f'

    # Author of this module
    Author               = 'DSC Community'

    # Company or vendor of this module
    CompanyName          = 'DSC Community'

    # Copyright statement for this module
    Copyright            = 'Copyright the DSC Community contributors. All rights reserved.'

    # Description of the functionality provided by this module
    Description          = 'This module contains commands and DSC resources for deployment and configuration of Microsoft SQL Server, SQL Server Reporting Services and Power BI Report Server.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion    = '5.0'

    # Minimum version of the common language runtime (CLR) required by this module
    CLRVersion           = '4.0'

    # Functions to export from this module
    FunctionsToExport    = @('Add-SqlDscFileGroup','Add-SqlDscNode','Add-SqlDscRSSslCertificateBinding','Add-SqlDscRSUrlReservation','Add-SqlDscTraceFlag','Assert-SqlDscAgentOperator','Assert-SqlDscLogin','Backup-SqlDscDatabase','Backup-SqlDscRSEncryptionKey','Complete-SqlDscFailoverCluster','Complete-SqlDscImage','Connect-SqlDscDatabaseEngine','ConvertFrom-SqlDscDatabasePermission','ConvertFrom-SqlDscServerPermission','ConvertTo-SqlDscDatabasePermission','ConvertTo-SqlDscDataFile','ConvertTo-SqlDscEditionName','ConvertTo-SqlDscFileGroup','ConvertTo-SqlDscServerPermission','Deny-SqlDscServerPermission','Disable-SqlDscAgentOperator','Disable-SqlDscAudit','Disable-SqlDscDatabaseSnapshotIsolation','Disable-SqlDscLogin','Disable-SqlDscRsSecureConnection','Disconnect-SqlDscDatabaseEngine','Enable-SqlDscAgentOperator','Enable-SqlDscAudit','Enable-SqlDscDatabaseSnapshotIsolation','Enable-SqlDscLogin','Enable-SqlDscRsSecureConnection','Get-SqlDscAgentAlert','Get-SqlDscAgentOperator','Get-SqlDscAudit','Get-SqlDscBackupFileList','Get-SqlDscCompatibilityLevel','Get-SqlDscConfigurationOption','Get-SqlDscDatabase','Get-SqlDscDatabasePermission','Get-SqlDscDateTime','Get-SqlDscInstalledInstance','Get-SqlDscLogin','Get-SqlDscManagedComputer','Get-SqlDscManagedComputerInstance','Get-SqlDscManagedComputerService','Get-SqlDscPreferredModule','Get-SqlDscRole','Get-SqlDscRSConfigFile','Get-SqlDscRSConfiguration','Get-SqlDscRSDatabaseInstallation','Get-SqlDscRSExecutionLog','Get-SqlDscRSIPAddress','Get-SqlDscRSLogPath','Get-SqlDscRSPackage','Get-SqlDscRSServiceAccount','Get-SqlDscRSSetupConfiguration','Get-SqlDscRSSslCertificate','Get-SqlDscRSSslCertificateBinding','Get-SqlDscRSUrl','Get-SqlDscRSUrlReservation','Get-SqlDscRSVersion','Get-SqlDscRSWebPortalApplicationName','Get-SqlDscServerPermission','Get-SqlDscServerProtocol','Get-SqlDscServerProtocolName','Get-SqlDscServerProtocolTcpIp','Get-SqlDscSetupLog','Get-SqlDscStartupParameter','Get-SqlDscTraceFlag','Grant-SqlDscServerPermission','Import-SqlDscPreferredModule','Initialize-SqlDscFailoverCluster','Initialize-SqlDscImage','Initialize-SqlDscRebuildDatabase','Initialize-SqlDscRS','Install-SqlDscFailoverCluster','Install-SqlDscPowerBIReportServer','Install-SqlDscReportingService','Install-SqlDscServer','Invoke-SqlDscQuery','Invoke-SqlDscScalarQuery','New-SqlDscAgentAlert','New-SqlDscAgentOperator','New-SqlDscAudit','New-SqlDscDatabase','New-SqlDscDatabaseSnapshot','New-SqlDscDataFile','New-SqlDscFileGroup','New-SqlDscLogin','New-SqlDscRole','New-SqlDscRSEncryptionKey','Remove-SqlDscAgentAlert','Remove-SqlDscAgentOperator','Remove-SqlDscAudit','Remove-SqlDscDatabase','Remove-SqlDscLogin','Remove-SqlDscNode','Remove-SqlDscRole','Remove-SqlDscRSEncryptedInformation','Remove-SqlDscRSEncryptionKey','Remove-SqlDscRSSslCertificateBinding','Remove-SqlDscRSUnattendedExecutionAccount','Remove-SqlDscRSUrlReservation','Remove-SqlDscTraceFlag','Repair-SqlDscPowerBIReportServer','Repair-SqlDscReportingService','Repair-SqlDscServer','Request-SqlDscRSDatabaseRightsScript','Request-SqlDscRSDatabaseScript','Request-SqlDscRSDatabaseUpgradeScript','Restart-SqlDscRSService','Restore-SqlDscDatabase','Restore-SqlDscRSEncryptionKey','Resume-SqlDscDatabase','Revoke-SqlDscServerPermission','Save-SqlDscSqlServerMediaFile','Set-SqlDscAgentAlert','Set-SqlDscAgentOperator','Set-SqlDscAudit','Set-SqlDscConfigurationOption','Set-SqlDscDatabaseDefault','Set-SqlDscDatabaseOwner','Set-SqlDscDatabasePermission','Set-SqlDscDatabaseProperty','Set-SqlDscRSDatabaseConnection','Set-SqlDscRSDatabaseTimeout','Set-SqlDscRSServiceAccount','Set-SqlDscRSSmtpConfiguration','Set-SqlDscRSSslCertificateBinding','Set-SqlDscRSUnattendedExecutionAccount','Set-SqlDscRSUrlReservation','Set-SqlDscRSVirtualDirectory','Set-SqlDscServerPermission','Set-SqlDscStartupParameter','Set-SqlDscTraceFlag','Start-SqlDscRSWebService','Start-SqlDscRSWindowsService','Stop-SqlDscRSWebService','Stop-SqlDscRSWindowsService','Suspend-SqlDscDatabase','Test-SqlDscAgentAlertProperty','Test-SqlDscBackupFile','Test-SqlDscConfigurationOption','Test-SqlDscDatabaseProperty','Test-SqlDscIsAgentAlert','Test-SqlDscIsAgentOperator','Test-SqlDscIsDatabase','Test-SqlDscIsDatabasePrincipal','Test-SqlDscIsLogin','Test-SqlDscIsLoginEnabled','Test-SqlDscIsRole','Test-SqlDscIsSupportedFeature','Test-SqlDscRSAccessible','Test-SqlDscRSInitialized','Test-SqlDscRSInstalled','Test-SqlDscServerPermission','Uninstall-SqlDscPowerBIReportServer','Uninstall-SqlDscReportingService','Uninstall-SqlDscServer','Update-SqlDscServer','Update-SqlDscServerEdition')

    # Cmdlets to export from this module
    # Use wildcard to avoid PSDesiredStateConfiguration 2.0.7 filtering class-based DSC resources (see #2109).
    CmdletsToExport      = '*'

    # Variables to export from this module
    VariablesToExport    = @()

    # Aliases to export from this module
    AliasesToExport      = @('Disable-SqlDscRSTls','Enable-SqlDscRSTls','Install-SqlDscBIReportServer','Install-SqlDscPBIReportServer','Repair-SqlDscBIReportServer','Repair-SqlDscPBIReportServer','Test-SqlDscAgentAlert','Uninstall-SqlDscBIReportServer','Uninstall-SqlDscPBIReportServer')

    DscResourcesToExport = @('SqlAgentAlert','SqlAudit','SqlDatabase','SqlDatabasePermission','SqlPermission','SqlRSSetup','SqlAG','SqlAGDatabase','SqlAgentFailsafe','SqlAgentOperator','SqlAGListener','SqlAGReplica','SqlAlias','SqlAlwaysOnService','SqlConfiguration','SqlDatabaseDefaultLocation','SqlDatabaseMail','SqlDatabaseObjectPermission','SqlDatabaseRole','SqlDatabaseUser','SqlEndpoint','SqlEndpointPermission','SqlLogin','SqlMaxDop','SqlMemory','SqlProtocol','SqlProtocolTcpIp','SqlReplication','SqlRole','SqlRS','SqlScript','SqlScriptQuery','SqlSecureConnection','SqlServiceAccount','SqlSetup','SqlTraceFlag','SqlWaitForAG','SqlWindowsFirewall')

    RequiredAssemblies   = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData          = @{

        PSData = @{
            # Set to a prerelease string value if the release should be a prerelease.
            Prerelease   = ''

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @('DesiredStateConfiguration', 'DSC', 'DSCResourceKit', 'DSCResource', 'SqlServer', 'PowerBI', 'ReportingServices', 'ReportServer')

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/dsccommunity/SqlServerDsc/blob/main/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/dsccommunity/SqlServerDsc'

            # A URL to an icon representing this module.
            IconUri      = 'https://dsccommunity.org/images/DSC_Logo_300p.png'

            # ReleaseNotes of this module
            ReleaseNotes = '## [17.5.1] - 2026-02-04

### Added

- SqlServerDsc
  - Added private functions `ConvertTo-SqlString` and `ConvertTo-EscapedQueryString`
    to safely escape T-SQL string literals and query arguments
    ([issue #2442](https://github.com/dsccommunity/SqlServerDsc/issues/2442)).
- DSC_SqlReplication
  - Updated `Install-RemoteDistributor` to escape T-SQL arguments for SQL Server
    2025 to prevent SQL injection and ensure proper password redaction
    ([issue #2442](https://github.com/dsccommunity/SqlServerDsc/issues/2442)).

### Changed

- SqlServerDsc
  - Updated Pester test guidance in AI instructions in community style guidelines.
  - Added SChannelDsc as a required module for integration tests and enabled the
    prerequisites tests `Ensure TLS 1.2 is enabled`  ([issue #2441](https://github.com/dsccommunity/SqlServerDsc/issues/2441)).

'

        } # End of PSData hashtable

    } # End of PrivateData hashtable
}
