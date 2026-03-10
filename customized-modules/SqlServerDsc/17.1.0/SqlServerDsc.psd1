@{
    # Script module or binary module file associated with this manifest.
    RootModule           = 'SqlServerDsc.psm1'

    # Version number of this module.
    ModuleVersion        = '17.1.0'

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
    FunctionsToExport    = @('Add-SqlDscNode','Add-SqlDscTraceFlag','Complete-SqlDscFailoverCluster','Complete-SqlDscImage','Connect-SqlDscDatabaseEngine','ConvertFrom-SqlDscDatabasePermission','ConvertFrom-SqlDscServerPermission','ConvertTo-SqlDscDatabasePermission','ConvertTo-SqlDscEditionName','ConvertTo-SqlDscServerPermission','Disable-SqlDscAudit','Disconnect-SqlDscDatabaseEngine','Enable-SqlDscAudit','Get-SqlDscAudit','Get-SqlDscConfigurationOption','Get-SqlDscDatabasePermission','Get-SqlDscInstalledInstance','Get-SqlDscManagedComputer','Get-SqlDscManagedComputerService','Get-SqlDscPreferredModule','Get-SqlDscRSSetupConfiguration','Get-SqlDscServerPermission','Get-SqlDscStartupParameter','Get-SqlDscTraceFlag','Import-SqlDscPreferredModule','Initialize-SqlDscRebuildDatabase','Install-SqlDscBIReportServer','Install-SqlDscReportingService','Install-SqlDscServer','Invoke-SqlDscQuery','New-SqlDscAudit','Remove-SqlDscAudit','Remove-SqlDscNode','Remove-SqlDscTraceFlag','Repair-SqlDscBIReportServer','Repair-SqlDscReportingService','Repair-SqlDscServer','Save-SqlDscSqlServerMediaFile','Set-SqlDscAudit','Set-SqlDscDatabasePermission','Set-SqlDscServerPermission','Set-SqlDscStartupParameter','Set-SqlDscTraceFlag','Test-SqlDscIsDatabasePrincipal','Test-SqlDscIsLogin','Test-SqlDscIsRole','Test-SqlDscIsSupportedFeature','Test-SqlDscRSInstalled','Uninstall-SqlDscBIReportServer','Uninstall-SqlDscReportingService','Uninstall-SqlDscServer')

    # Cmdlets to export from this module
    CmdletsToExport      = @()

    # Variables to export from this module
    VariablesToExport    = @()

    # Aliases to export from this module
    AliasesToExport      = @()

    DscResourcesToExport = @('SqlAudit','SqlDatabasePermission','SqlPermission','SqlRSSetup','SqlAG','SqlAGDatabase','SqlAgentAlert','SqlAgentFailsafe','SqlAgentOperator','SqlAGListener','SqlAGReplica','SqlAlias','SqlAlwaysOnService','SqlConfiguration','SqlDatabase','SqlDatabaseDefaultLocation','SqlDatabaseMail','SqlDatabaseObjectPermission','SqlDatabaseRole','SqlDatabaseUser','SqlEndpoint','SqlEndpointPermission','SqlLogin','SqlMaxDop','SqlMemory','SqlProtocol','SqlProtocolTcpIp','SqlReplication','SqlRole','SqlRS','SqlScript','SqlScriptQuery','SqlSecureConnection','SqlServiceAccount','SqlSetup','SqlTraceFlag','SqlWaitForAG','SqlWindowsFirewall')

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
            ReleaseNotes = '## [17.1.0] - 2025-05-22

### Removed

- SqlServerDsc
  - Revert workaround in GitHub Actions workflows as new version of ModuleBuilder
    was released.
- SqlServerDsc.Common
  - Removed the function `Get-RegistryPropertyValue`, `Format-Path` and
    `Test-PendingRestart` in favor of the commands with the same names in
    the module _DscResource.Common_.
- SqlRSSetup
  - The DSC resource has been refactored into a class-based resource.
    - The parameter `SourcePath` was replaced with `MediaPath`.
    - The parameter `IAcceptLicensTerms` was replaced with a boolean parameter
      `AcceptLicensingTerms`.
    - The parameter `SourceCredential` was removed. Because of this, the
      functionality that allowed copying the media from a UNC path using
      those credentials was also removed. If this was something you used,
      please open an issue.
    - The version validation no longer gets the current version from the
      installed package (using `Get-Package`), but instead from the registry.
    - Prior when install was successful, the resource checked whether there
      were any pending rename operations. Since the install returns 3010
      if a restart is needed it is now assumed that the setup process takes
      care of this. If that is not the case, and this check is needed, then
      open an issue to discuss in what cases this is needed.
    - The `Edition` option ''Development` was replaced by the value
      `Developer`.
    - The read-only properties `CurrentVersion`, `ServiceName` and `ErrorDumpDirectory`
      were removed.

### Added

- Public commands:
  - `Get-SqlDscInstalledInstance` to retrieve installed SQL instances.
  - `Get-SqlDscRSSetupConfiguration` to retrieve the setup configuration of
    SQL Server Reporting Services or Power BI Report Server ([issue #2072](https://github.com/dsccommunity/SqlServerDsc/issues/2072)).
    - Add additional properties to `Get-SqlDscRSSetupConfiguration` output.
  - `Install-SqlDscReportingService` to install SQL Server Reporting Services
    ([issue #2010](https://github.com/dsccommunity/SqlServerDsc/issues/2010)).
    - Add `PassThru` parameter to return exit code.
  - `Install-SqlDscBIReportServer` to install SQL Server BI Report Server.
    ([issue #2010](https://github.com/dsccommunity/SqlServerDsc/issues/2010)).
    - Add `PassThru` parameter to return exit code.
  - `Repair-SqlDscReportingService` to repair an already installed SQL Server
    Reporting Services ([issue #2064](https://github.com/dsccommunity/SqlServerDsc/issues/2064)).
    - Add `PassThru` parameter to return exit code.
  - `Repair-SqlDscBIReportServer` to repair an already installed SQL Server
    BI Report Server ([issue #2064](https://github.com/dsccommunity/SqlServerDsc/issues/2064)).
    - Add `PassThru` parameter to return exit code.
  - `Test-SqlDscRSInstalled` to test whether an instance is installed or not
     ([issue #2078](https://github.com/dsccommunity/SqlServerDsc/issues/2078)).
  - `Uninstall-SqlDscReportingService` to uninstall SQL Server Reporting
    Services ([issue #2065](https://github.com/dsccommunity/SqlServerDsc/issues/2065)).
    - Add `PassThru` parameter to return exit code.
  - `Uninstall-SqlDscBIReportServer` to uninstall SQL Server BI Report Server
    ([issue #2065](https://github.com/dsccommunity/SqlServerDsc/issues/2065)).
    - Add `PassThru` parameter to return exit code.
  - `ConvertTo-SqlDscEditionName` to return the edition name of the specified
    edition ID.
- Private function:
  - `Invoke-ReportServerSetupAction` to run setup actions for Reporting
    Services and Power BI Report Server.
- Added new instructions for GitHub Copilot that might assist when developing
  command and private functions in the module. More instructions should be
  added as needed to help generated code and tests.

### Changed

- SqlServerDsc
  - The examples that was located in the README in the examples folder has
    now been moved to the WikiSource folder. The examples are published to
    the repository Wiki. The README has been updated to link to the new
    location ([issue #2051](https://github.com/dsccommunity/SqlServerDsc/issues/2051)).
  - Integration test stages has been modified to split the testing into
    several different areas. The tests are dependent on this order:
    - Quality_Test_and_Unit_Test
    - Integration_Test_Commands_SqlServer
      - Integration_Test_Commands_ReportingServices
      - Integration_Test_Commands_BIReportServer
    - Integration_Test_Resources_SqlServer
      - Integration_Test_Resources_SqlServer_dbatools
      - Integration_Test_Resources_ReportingServices
        - Integration_Test_Resources_ReportingServices_dbatools
  - Update build script path in integration tests.
  - Fix style formatting in all PowerShell script files.
  - Update module description on GitHub, in the conceptual help, and in
    the module manifest.
  - Now integration tests will fail on an exception when the command `Test-DscConfiguration`
    is run.
  - Added Test-SqlDscIsRole to be used like Test-SqlDscIsLogin but tests
    for a server role as principal.
  - Refine and enhance clarity in Copilot instructions.
- SqlSetup
  - Fixed issue with AddNode where cluster IP information was not being passed to
    setup.exe ([issue #1171](https://github.com/dsccommunity/SqlServerDsc/issues/1171)).
- SqlRSSetup
  - The DSC resource has been refactored into a class-based resource.
- `Set-SqlDscServerPermission`
  - Added support for assigning permissions to a server role.

### Fixed

- Fixed workaround for the GitHub Actions to support building module in Windows
  PowerShell.
- Fix tests to redirect output streams correctly.
- SqlServerDsc
  - Fix localization tests.
  - Cleanup in unit tests for classes.
  - Cleanup in localization string files.
- `SqlAudit`
  - Fix localization strings in `Assert` method.
- `Save-SqlDscSqlServerMediaFile`
  - Fix localizations strings that used wrong keys.
  - Fix unit tests so they work cross-platform.
- `Install-SqlDscServer` and private function `Invoke-SetupAction`
  - Fix localization string keys naming.
  - Fix unit tests to use correct localization string names.
  - Remove redundant unit tests.
- `SqlConfiguration`
  - Change the alias command to real command name, to pass HQRM tests.
- `SqlDatabaseUser`
  - Change the alias command to real command name, to pass HQRM tests.
- `SqlMaxDop`
  - Change the alias command to real command name, to pass HQRM tests.
- `SqlMemory`
  - Change the alias command to real command name, to pass HQRM tests.
- `SqlReplication`
  - Change the alias command to real command name, to pass HQRM tests.
- `SqlRSSetup`
  - Change the alias command to real command name, to pass HQRM tests.
- `SqlServiceAccount`
  - Change the alias command to real command name, to pass HQRM tests.
- `Get-SqlDscRSSetupConfiguration`
  - The integration test was updated to verify so that the `CurrentVersion`
    and `ProductVersion` strings can be converted to valid versions and
    that they always are higher than what we expect.
- `SqlRS`
  - Re-enable integration tests.
- `SqlAG`
  - Fix SeedingMode existence condition.
- `SqlAGReplica`
  - Fix SeedingMode existence condition.

'

        } # End of PSData hashtable

    } # End of PrivateData hashtable
}
