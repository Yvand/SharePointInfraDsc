# Changelog for SharePointInfraDsc

## [2.0.0] - 

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
