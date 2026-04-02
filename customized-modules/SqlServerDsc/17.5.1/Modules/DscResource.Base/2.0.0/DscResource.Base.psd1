@{
    # Script module or binary module file associated with this manifest.
    RootModule           = 'DscResource.Base.psm1'

    # Version number of this module.
    ModuleVersion        = '2.0.0'

    # ID used to uniquely identify this module
    GUID                 = '693ee082-ed36-45a7-b490-88b07c86b42f'

    # Author of this module
    Author               = 'DSC Community'

    # Company or vendor of this module
    CompanyName          = 'DSC Community'

    # Copyright statement for this module
    Copyright            = 'Copyright the DSC Community contributors. All rights reserved.'

    # Description of the functionality provided by this module
    Description          = 'This module contains common classes that can be used for class-based DSC resources development.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion    = '5.0'

    # Minimum version of the common language runtime (CLR) required by this module
    CLRVersion           = '4.0'

    # Functions to export from this module
    FunctionsToExport    = @()

    # Cmdlets to export from this module
    CmdletsToExport      = @()

    # Variables to export from this module
    VariablesToExport    = @()

    # Aliases to export from this module
    AliasesToExport      = @()

    DscResourcesToExport = @()

    RequiredAssemblies   = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData          = @{

        PSData = @{
            # Set to a prerelease string value if the release should be a prerelease.
            Prerelease   = ''

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @('DesiredStateConfiguration', 'DSC', 'DSCResourceKit', 'DSCResource')

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/dsccommunity/DscResource.Base/blob/main/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/dsccommunity/DscResource.Base'

            # A URL to an icon representing this module.
            IconUri      = 'https://dsccommunity.org/images/DSC_Logo_300p.png'

            # ReleaseNotes of this module
            ReleaseNotes = '## [2.0.0] - 2025-12-28

### Changed

- `azure-pipelines.yml`
  - Remove `windows-2019` images fixes [#43](https://github.com/dsccommunity/DscResource.Base/issues/43)
  - Move individual tasks to `windows-latest`.
- `ResourceBase`
  - Cache properties not in desired state.
  - Make `Set()` call `Test()` and `Test()` call `Get()`.
  - Remove use of array addition and `ForEach-Object`.
  - Output only relevant state output at Verbose. Fixes [#45](https://github.com/dsccommunity/DscResource.Base/issues/45).

### Removed

- `ResourceBase`
  - Remove `Compare()` method as not used.
  - Removed feature flags and alternate behavior.

'

        } # End of PSData hashtable

    } # End of PrivateData hashtable
}
