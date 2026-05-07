# Changelog for SharePointInfraDsc

## Unreleased

## [3.0.1] - 2026-05-07

### Fixed

- DSC for SharePoint
  - Fix script CreatePersonalSites if ProvisionTrustedAuthentication is false
- Customized Modules
  - SharePointDSC: Instead of bypassing the logging to the event viewer, set ErrorAction to SilentlyContinue in `Write-EventLog`

### Added

- SharePointInfraDsc
  - Test the DSC files to ensure they can create a MOF file

## [3.0.0] - 2026-04-30

### Added

- DSC for SharePoint
  - **BREAKING CHANGE**: Added parameter CustomSharePointConfiguration
- DSC for DC
  - **BREAKING CHANGE**: Added parameter GlobalConfiguration

### Changed

- DSC for SharePoint
  - **BREAKING CHANGE**: Renamed parameter ConfigurationLevel to SharePointConfigurationLevel
  - **BREAKING CHANGE**: Removed unnecessary parameters in the frontend config
  - Changed the name of the SPTrustedIdentityTokenIssuer config, in SharePoint, to 'trusted'
  - Multiple optimizations

### Fixed

- DSC for SharePoint
  - Only call the resource SPSiteUrl if needed
  - Fix dependencies on CreateTeamSite
- Customized Modules
  - SharePointDSC: Improved reliability by bypassing the logging to the event viewer, which randomly threw an error and caused deployment to fail

## [2.3.0] - 2026-04-15

### Changed

- DSC for DC
  - Re-added a reboot just before creating the AD forest, to avoid rare configuration failures because a reboot was required before it could proceed
- DSC for SQL
  - Added a max attempts counter to function WaitForSqlSetup, as a safeguard to prevent infinite waits that happened very rarely
- Customized Modules
  - SharePointDSC: Apply the change made to resource SPInstallPrereqs in v5.7.1-preview0001
- SharePointInfraDsc
  - Specify what parameters are mandatory in the PowerShell setup scripts
  - Enable workflow "Build DSC archives" when a pull request targets the main branch

## [2.2.0] - 2026-04-07

### Changed

- DSC for DC
  - Optimized the dependencies of the resources
  - Removed the install of any Windows feature that is not strictly required
- DSC for SPSE-main
  - Moved install of Windows feature "RSAT-AD-Tools" as late as possible, because its test function randomly takes 60-80 secs (called after each reboot)

## [2.1.0] - 2026-04-02

### Changed

- SharePointInfraDsc
  - Updated script `Install-Modules.ps1` to install the prerequisites if necessary
  - Removed the setup task in workflow action 'Build DSC archives' since installing prerequisites is now taken care of in `Install-Modules.ps1`

- DSC for all configurations
  - Ensure `UseBasicParsing` is always set with cmdlet `Invoke-WebRequest`, to address security update for [CVE-2025-54100](https://msrc.microsoft.com/update-guide/vulnerability/CVE-2025-54100).

- DSC for DC
  - Removed unnecessary features and reboot to speed up the provisioning time.
  - Focused on reducing the time to wait before other machines can join the AD domain.

- Dependencies
  - Updated module `SqlServerDsc` from 17.1.0 to 17.5.1
  - Updated module `ActiveDirectoryDsc` from 6.7.0 to 6.7.1
  - Updated module `DnsServerDsc` from 3.0.1 to 3.0.3

## [2.0.0] - 2026-04-01

### Changed

- SharePointInfraDsc
  - **BREAKING CHANGE**: Renamed all the DSC configurations.
  - Overall, many optimizations made on all the DSC configurations, resulting in a more reliable and faster deployment.
  - Renamed folders in the repo.
  - Updated the PowerShell scripts and GitHub workflows, to have most of the logic in the scripts, so that this project can be easily setup in a new machine.
  - Stopped using a customized version of module `ComputerManagementDsc`.

- DSC for DC
  - **BREAKING CHANGE**: Added parameters `SqlSvcCreds` and `SPSetupCreds`.
  - Multiple optimizations.

- DSC for SQL
  - **BREAKING CHANGE**: Renamed parameter `SPSetupCreds` to `SPSetupUserName`.
  - Multiple optimizations.

- DSC for SharePoint Subscription main
  - **BREAKING CHANGE**: Renamed parameter `DefaultZoneIsHttps` to `DefaultZoneMustBeHttps`.
  - **BREAKING CHANGE**: Added parameter `ConfigurationLevel`: Admin can now choose how much SharePoint configuration is performed
  - Other breaking changes and multiple optimizations.

- DSC for SharePoint Subscription frontend
  - **BREAKING CHANGE**: Renamed parameter `DefaultZoneIsHttps` to `DefaultZoneMustBeHttps`.
  - **BREAKING CHANGE**: Added parameter `ConfigurationLevel`: Admin can now choose how much SharePoint configuration is performed
  - Other breaking changes and multiple optimizations.

- DSC for SharePoint Legacy main and frontend
  - Made the minimum changes necessary to keep them working, but no investment was made to improve them

## [1.0.0] - 2026-03-16

- Initial release in this dedicated repository. The DSC configurations themselves have been developed for a very long time in https://github.com/Yvand/AzureRM-Templates.
