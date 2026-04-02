# Changelog for SharePointInfraDsc

## Unreleased

### Changed

- DSC for all configurations
  - Ensure `UseBasicParsing` is always set with cmdlet `Invoke-WebRequest`, to address security update for [CVE-2025-54100](https://msrc.microsoft.com/update-guide/vulnerability/CVE-2025-54100).

- DSC for DC
  - Removed unnecessary features and reboot to speed up the provisionning time.
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
