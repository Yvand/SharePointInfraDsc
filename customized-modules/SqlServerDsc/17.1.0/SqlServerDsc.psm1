#Region '.\prefix.ps1' -1

using module .\Modules\DscResource.Base

$script:dscResourceCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Modules/DscResource.Common'
Import-Module -Name $script:dscResourceCommonModulePath

# TODO: The goal would be to remove this, when no classes and public or private functions need it.
$script:sqlServerDscCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Modules/SqlServerDsc.Common'
Import-Module -Name $script:sqlServerDscCommonModulePath

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'
#EndRegion '.\prefix.ps1' 11
#Region '.\Enum\001.InstallAction.ps1' -1

<#
    .SYNOPSIS
        The possible states for the commands and DSC resources with the parameter
        Action.
#>
enum InstallAction
{
    Install = 1
    Repair
    Uninstall
}
#EndRegion '.\Enum\001.InstallAction.ps1' 12
#Region '.\Classes\001.SqlReason.ps1' -1

<#
    .SYNOPSIS
        The reason a property of a DSC resource is not in desired state.

    .DESCRIPTION
        A DSC resource can have a read-only property `Reasons` that the compliance
        part (audit via Azure Policy) of Azure AutoManage Machine Configuration
        uses. The property Reasons holds an array of SqlReason. Each SqlReason
        explains why a property of a DSC resource is not in desired state.
#>

class SqlReason
{
    [DscProperty()]
    [System.String]
    $Code

    [DscProperty()]
    [System.String]
    $Phrase
}
#EndRegion '.\Classes\001.SqlReason.ps1' 22
#Region '.\Classes\002.DatabasePermission.ps1' -1

<#
    .SYNOPSIS
        The possible database permission states.

    .PARAMETER State
        The state of the permission.

    .PARAMETER Permission
        The permissions to be granted or denied for the user in the database.

    .NOTES
        The DSC properties specifies the attribute Mandatory but State was meant
        to be attribute Key, but those attributes are not honored correctly during
        compilation in the current implementation of PowerShell DSC. If the
        attribute would have been left as Key then it would not have been possible
        to add an identical instance of DatabasePermission in two separate DSC
        resource instances in a DSC configuration. The Key property only works
        on the top level DSC properties. E.g. two resources instances of
        SqlDatabasePermission in a DSC configuration trying to grant the database
        permission 'connect' in two separate databases would have failed compilation
        as a the property State would have been seen as "duplicate resource".

        Since it is not possible to use the attribute Key the State property is
        evaluate during runtime so that no two states are enforcing the same
        permission.

        This class cannot inherit a parent class. If it would have, then the
        DSC resource (e.g. SqlDatabasePermission) that uses the complex type fail
        with the error:

            "The 'Permission' property with type 'DatabasePermission' of DSC resource
            class 'SqlDatabasePermission' is not supported."

        The method Equals() returns $false if type is not the same on both sides
        of the comparison. There was a thought to throw an exception if the object
        being compared was of another type, but since there was issues with using
        for example [ServerPermission[]], it was left out. This can be the correct
        way since if moving for example [ServerPermission[]] to the left side and
        the for example [ServerPermission] to the right side, then the left side
        array is filtered with the matching values on the right side. This is the
        normal behavior for other types.

    .EXAMPLE
        [DatabasePermission] @{}

        Initializes a new instance of the DatabasePermission class without any
        property values.

    .EXAMPLE
        [DatabasePermission] @{ State = 'Grant'; Permission = @('Connect', 'Select') }

        Initializes a new instance of the DatabasePermission class with property
        values.

#>
class DatabasePermission : IComparable, System.IEquatable[Object]
{
    [DscProperty(Mandatory)]
    [ValidateSet('Grant', 'GrantWithGrant', 'Deny')]
    [System.String]
    $State

    [DscProperty(Mandatory)]
    [AllowEmptyCollection()]
    [ValidateSet(
        'AdministerDatabaseBulkOperations',
        'Alter',
        'AlterAnyApplicationRole',
        'AlterAnyAssembly',
        'AlterAnyAsymmetricKey',
        'AlterAnyCertificate',
        'AlterAnyColumnEncryptionKey',
        'AlterAnyColumnMasterKey',
        'AlterAnyContract',
        'AlterAnyDatabaseAudit',
        'AlterAnyDatabaseDdlTrigger',
        'AlterAnyDatabaseEventNotification',
        'AlterAnyDatabaseEventSession',
        'AlterAnyDatabaseEventSessionAddEvent',
        'AlterAnyDatabaseEventSessionAddTarget',
        'AlterAnyDatabaseEventSessionDisable',
        'AlterAnyDatabaseEventSessionDropEvent',
        'AlterAnyDatabaseEventSessionDropTarget',
        'AlterAnyDatabaseEventSessionEnable',
        'AlterAnyDatabaseEventSessionOption',
        'AlterAnyDatabaseScopedConfiguration',
        'AlterAnyDataspace',
        'AlterAnyExternalDataSource',
        'AlterAnyExternalFileFormat',
        'AlterAnyExternalJob',
        'AlterAnyExternalLanguage',
        'AlterAnyExternalLibrary',
        'AlterAnyExternalStream',
        'AlterAnyFulltextCatalog',
        'AlterAnyMask',
        'AlterAnyMessageType',
        'AlterAnyRemoteServiceBinding',
        'AlterAnyRole',
        'AlterAnyRoute',
        'AlterAnySchema',
        'AlterAnySecurityPolicy',
        'AlterAnySensitivityClassification',
        'AlterAnyService',
        'AlterAnySymmetricKey',
        'AlterAnyUser',
        'AlterLedger',
        'AlterLedgerConfiguration',
        'Authenticate',
        'BackupDatabase',
        'BackupLog',
        'Checkpoint',
        'Connect',
        'ConnectReplication',
        'Control',
        'CreateAggregate',
        'CreateAnyDatabaseEventSession',
        'CreateAssembly',
        'CreateAsymmetricKey',
        'CreateCertificate',
        'CreateContract',
        'CreateDatabase',
        'CreateDatabaseDdlEventNotification',
        'CreateDefault',
        'CreateExternalLanguage',
        'CreateExternalLibrary',
        'CreateFulltextCatalog',
        'CreateFunction',
        'CreateMessageType',
        'CreateProcedure',
        'CreateQueue',
        'CreateRemoteServiceBinding',
        'CreateRole',
        'CreateRoute',
        'CreateRule',
        'CreateSchema',
        'CreateService',
        'CreateSymmetricKey',
        'CreateSynonym',
        'CreateTable',
        'CreateType',
        'CreateUser',
        'CreateView',
        'CreateXmlSchemaCollection',
        'Delete',
        'DropAnyDatabaseEventSession',
        'EnableLedger',
        'Execute',
        'ExecuteAnyExternalEndpoint',
        'ExecuteAnyExternalScript',
        'Insert',
        'KillDatabaseConnection',
        'OwnershipChaining',
        'References',
        'Select',
        'Showplan',
        'SubscribeQueryNotifications',
        'TakeOwnership',
        'Unmask',
        'Update',
        'ViewAnyColumnEncryptionKeyDefinition',
        'ViewAnyColumnMasterKeyDefinition',
        'ViewAnySensitivityClassification',
        'ViewCryptographicallySecuredDefinition',
        'ViewDatabasePerformanceState',
        'ViewDatabaseSecurityAudit',
        'ViewDatabaseSecurityState',
        'ViewDatabaseState',
        'ViewDefinition',
        'ViewLedgerContent',
        'ViewPerformanceDefinition',
        'ViewSecurityDefinition'
    )]
    [System.String[]]
    $Permission

    DatabasePermission ()
    {
    }

    [System.Boolean] Equals([System.Object] $object)
    {
        $isEqual = $false

        if ($object -is $this.GetType())
        {
            if ($this.Grant -eq $object.Grant)
            {
                if (-not (Compare-Object -ReferenceObject $this.Permission -DifferenceObject $object.Permission))
                {
                    $isEqual = $true
                }
            }
        }

        return $isEqual
    }

    [System.Int32] CompareTo([Object] $object)
    {
        [System.Int32] $returnValue = 0

        if ($null -eq $object)
        {
            return 1
        }

        if ($object -is $this.GetType())
        {
            <#
                Less than zero    - The current instance precedes the object specified by the CompareTo
                                    method in the sort order.
                Zero              - This current instance occurs in the same position in the sort order
                                    as the object specified by the CompareTo method.
                Greater than zero - This current instance follows the object specified by the CompareTo
                                    method in the sort order.
            #>
            $returnValue = 0

            # Order objects in the order 'Grant', 'GrantWithGrant', 'Deny'.
            switch ($this.State)
            {
                'Grant'
                {
                    if ($object.State -in @('GrantWithGrant', 'Deny'))
                    {
                        # This current instance precedes $object
                        $returnValue = -1
                    }
                }

                'GrantWithGrant'
                {
                    if ($object.State -in @('Grant'))
                    {
                        # This current instance follows $object
                        $returnValue = 1
                    }

                    if ($object.State -in @('Deny'))
                    {
                        # This current instance precedes $object
                        $returnValue = -1
                    }
                }

                'Deny'
                {
                    if ($object.State -in @('Grant', 'GrantWithGrant'))
                    {
                        # This current instance follows $object
                        $returnValue = 1
                    }
                }
            }
        }
        else
        {
            $errorMessage = $script:localizedData.InvalidTypeForCompare -f @(
                $this.GetType().FullName,
                $object.GetType().FullName
            )

            New-InvalidArgumentException -ArgumentName 'Object' -Message $errorMessage
        }

        return $returnValue
    }

    [System.String] ToString()
    {
        $concatenatedPermission = ($this.Permission | Sort-Object) -join ', '

        return ('{0}: {1}' -f $this.State, $concatenatedPermission)
    }
}
#EndRegion '.\Classes\002.DatabasePermission.ps1' 276
#Region '.\Classes\002.ServerPermission.ps1' -1

<#
    .SYNOPSIS
        The possible server permission states.

    .PARAMETER State
        The state of the permission.

    .PARAMETER Permission
        The permissions to be granted or denied for the user in the database.

    .NOTES
        The DSC properties specifies the attribute Mandatory but State was meant
        to be attribute Key, but those attributes are not honored correctly during
        compilation in the current implementation of PowerShell DSC. If the
        attribute would have been left as Key then it would not have been possible
        to add an identical instance of ServerPermission in two separate DSC
        resource instances in a DSC configuration. The Key property only works
        on the top level DSC properties. E.g. two resources instances of
        SqlPermission in a DSC configuration trying to grant the database
        permission 'AlterAnyDatabase' in two separate databases would have failed compilation
        as a the property State would have been seen as "duplicate resource".

        Since it is not possible to use the attribute Key the State property is
        evaluate during runtime so that no two states are enforcing the same
        permission.

        This class cannot inherit a parent class. If it would have, then the
        DSC resource (e.g. SqlServerPermission) that uses the complex type fail
        with the error:

            "The 'Permission' property with type 'ServerPermission' of DSC resource
            class 'SqlServerPermission' is not supported."

        The method Equals() returns $false if type is not the same on both sides
        of the comparison. There was a thought to throw an exception if the object
        being compared was of another type, but since there was issues with using
        for example [ServerPermission[]], it was left out. This can be the correct
        way since if moving for example [ServerPermission[]] to the left side and
        the for example [ServerPermission] to the right side, then the left side
        array is filtered with the matching values on the right side. This is the
        normal behavior for other types.

    .EXAMPLE
        [ServerPermission] @{}

        Initializes a new instance of the ServerPermission class without any
        property values.

    .EXAMPLE
        [ServerPermission] @{ State = 'Grant'; Permission = @('ConnectSql', 'ViewServerState') }

        Initializes a new instance of the ServerPermission class with property
        values.
#>
class ServerPermission : IComparable, System.IEquatable[Object]
{
    [DscProperty(Mandatory)]
    [ValidateSet('Grant', 'GrantWithGrant', 'Deny')]
    [System.String]
    $State

    [DscProperty(Mandatory)]
    [AllowEmptyCollection()]
    [ValidateSet(
        'AdministerBulkOperations',
        'AlterAnyServerAudit',
        'AlterAnyCredential',
        'AlterAnyConnection',
        'AlterAnyDatabase',
        'AlterAnyEventNotification',
        'AlterAnyEndpoint',
        'AlterAnyLogin',
        'AlterAnyLinkedServer',
        'AlterResources',
        'AlterServerState',
        'AlterSettings',
        'AlterTrace',
        'AuthenticateServer',
        'ControlServer',
        'ConnectSql',
        'CreateAnyDatabase',
        'CreateDdlEventNotification',
        'CreateEndpoint',
        'CreateTraceEventNotification',
        'Shutdown',
        'ViewAnyDefinition',
        'ViewAnyDatabase',
        'ViewServerState',
        'ExternalAccessAssembly',
        'UnsafeAssembly',
        'AlterAnyServerRole',
        'CreateServerRole',
        'AlterAnyAvailabilityGroup',
        'CreateAvailabilityGroup',
        'AlterAnyEventSession',
        'SelectAllUserSecurables',
        'ConnectAnyDatabase',
        'ImpersonateAnyLogin'
    )]
    [System.String[]]
    $Permission

    ServerPermission ()
    {
    }

    <#
        TODO: It was not possible to move this to a parent class. But since these are
              generic functions for DatabasePermission and ServerPermission we
              could make this a private function.
    #>
    [System.Boolean] Equals([System.Object] $object)
    {
        $isEqual = $false

        if ($object -is $this.GetType())
        {
            if ($this.Grant -eq $object.Grant)
            {
                if (-not (Compare-Object -ReferenceObject $this.Permission -DifferenceObject $object.Permission))
                {
                    $isEqual = $true
                }
            }
        }

        return $isEqual
    }

    <#
        TODO: It was not possible to move this to a parent class. But since these are
              generic functions for DatabasePermission and ServerPermission we
              could make this a private function.
    #>
    [System.Int32] CompareTo([Object] $object)
    {
        [System.Int32] $returnValue = 0

        if ($null -eq $object)
        {
            return 1
        }

        if ($object -is $this.GetType())
        {
            <#
                Less than zero    - The current instance precedes the object specified by the CompareTo
                                    method in the sort order.
                Zero              - This current instance occurs in the same position in the sort order
                                    as the object specified by the CompareTo method.
                Greater than zero - This current instance follows the object specified by the CompareTo
                                    method in the sort order.
            #>
            $returnValue = 0

            # Order objects in the order 'Grant', 'GrantWithGrant', 'Deny'.
            switch ($this.State)
            {
                'Grant'
                {
                    if ($object.State -in @('GrantWithGrant', 'Deny'))
                    {
                        # This current instance precedes $object
                        $returnValue = -1
                    }
                }

                'GrantWithGrant'
                {
                    if ($object.State -in @('Grant'))
                    {
                        # This current instance follows $object
                        $returnValue = 1
                    }

                    if ($object.State -in @('Deny'))
                    {
                        # This current instance precedes $object
                        $returnValue = -1
                    }
                }

                'Deny'
                {
                    if ($object.State -in @('Grant', 'GrantWithGrant'))
                    {
                        # This current instance follows $object
                        $returnValue = 1
                    }
                }
            }
        }
        else
        {
            $errorMessage = $script:localizedData.InvalidTypeForCompare -f @(
                $this.GetType().FullName,
                $object.GetType().FullName
            )

            New-InvalidArgumentException -ArgumentName 'Object' -Message $errorMessage
        }

        return $returnValue
    }

    [System.String] ToString()
    {
        $concatenatedPermission = ($this.Permission | Sort-Object) -join ', '

        return ('{0}: {1}' -f $this.State, $concatenatedPermission)
    }
}
#EndRegion '.\Classes\002.ServerPermission.ps1' 213
#Region '.\Classes\004.StartupParameters.ps1' -1

<#
    .SYNOPSIS
        A class to handle startup parameters of a manged computer service object.

    .EXAMPLE
        $startupParameters = [StartupParameters]::Parse(((Get-SqlDscManagedComputer).Services | ? type -eq 'SqlServer').StartupParameters)
        $startupParameters | fl
        $startupParameters.ToString()

        Parses the startup parameters of the database engine default instance on the
        current node, and then outputs the resulting object. Also shows how the object
        can be turned back to a startup parameters string by calling ToString().

    .NOTES
        This class supports an array of data file paths, log file paths, and error
        log paths though currently it seems that there can only be one of each.
        This class was made with arrays in case there is an unknown edge case where
        it is possible to have more than one of those paths.
#>
class StartupParameters
{
    [System.String[]]
    $DataFilePath

    [System.String[]]
    $LogFilePath

    [System.String[]]
    $ErrorLogPath

    [System.UInt32[]]
    $TraceFlag

    [System.UInt32[]]
    $InternalTraceFlag

    StartupParameters ()
    {
    }

    static [StartupParameters] Parse([System.String] $InstanceStartupParameters)
    {
        Write-Debug -Message (
            $script:localizedData.StartupParameters_DebugParsingStartupParameters -f 'StartupParameters.Parse()', $InstanceStartupParameters
        )

        $startupParameters = [StartupParameters]::new()

        $startupParameterValues = $InstanceStartupParameters -split ';'

        $startupParameters.TraceFlag = [System.UInt32[]] @(
            $startupParameterValues |
                Where-Object -FilterScript {
                    $_ -cmatch '^-T\d+'
                } |
                ForEach-Object -Process {
                    [System.UInt32] $_.TrimStart('-T')
                }
        )

        Write-Debug -Message (
            $script:localizedData.StartupParameters_DebugFoundTraceFlags -f 'StartupParameters.Parse()', ($startupParameters.TraceFlag -join ', ')
        )

        $startupParameters.DataFilePath = [System.String[]] @(
            $startupParameterValues |
                Where-Object -FilterScript {
                    $_ -cmatch '^-d'
                } |
                ForEach-Object -Process {
                    $_.TrimStart('-d')
                }
        )

        $startupParameters.LogFilePath = [System.String[]] @(
            $startupParameterValues |
                Where-Object -FilterScript {
                    $_ -cmatch '^-l'
                } |
                ForEach-Object -Process {
                    $_.TrimStart('-l')
                }
        )

        $startupParameters.ErrorLogPath = [System.String[]] @(
            $startupParameterValues |
                Where-Object -FilterScript {
                    $_ -cmatch '^-e'
                } |
                ForEach-Object -Process {
                    $_.TrimStart('-e')
                }
        )

        $startupParameters.InternalTraceFlag = [System.UInt32[]] @(
            $startupParameterValues |
                Where-Object -FilterScript {
                    $_ -cmatch '^-t\d+'
                } |
                ForEach-Object -Process {
                    [System.UInt32] $_.TrimStart('-t')
                }
        )

        return $startupParameters
    }

    [System.String] ToString()
    {
        $startupParametersValues = [System.String[]] @()

        if ($this.DataFilePath)
        {
            $startupParametersValues += $this.DataFilePath |
                ForEach-Object -Process {
                    '-d{0}' -f $_
                }
        }

        if ($this.ErrorLogPath)
        {
            $startupParametersValues += $this.ErrorLogPath |
                ForEach-Object -Process {
                    '-e{0}' -f $_
                }
        }

        if ($this.LogFilePath)
        {
            $startupParametersValues += $this.LogFilePath |
                ForEach-Object -Process {
                    '-l{0}' -f $_
                }
        }

        if ($this.TraceFlag)
        {
            $startupParametersValues += $this.TraceFlag |
                ForEach-Object -Process {
                    '-T{0}' -f $_
                }
        }

        if ($this.InternalTraceFlag)
        {
            $startupParametersValues += $this.InternalTraceFlag |
                ForEach-Object -Process {
                    '-t{0}' -f $_
                }
        }

        return $startupParametersValues -join ';'
    }
}
#EndRegion '.\Classes\004.StartupParameters.ps1' 155
#Region '.\Classes\011.SqlResourceBase.ps1' -1

<#
    .SYNOPSIS
        The SqlResource base have generic properties and methods for the class-based
        resources.

    .PARAMETER InstanceName
        The name of the _SQL Server_ instance to be configured. Default value is
        `'MSSQLSERVER'`.

    .PARAMETER ServerName
        The host name of the _SQL Server_ to be configured. Default value is the
        current computer name.

    .PARAMETER Credential
        Specifies the credential to use to connect to the _SQL Server_ instance.

        If parameter **Credential'* is not provided then the resource instance is
        run using the credential that runs the configuration.

    .PARAMETER Reasons
        Returns the reason a property is not in desired state.
#>
class SqlResourceBase : ResourceBase
{
    <#
        Property for holding the server connection object.
        This should be an object of type [Microsoft.SqlServer.Management.Smo.Server]
        but using that type fails the build process currently.
        See issue https://github.com/dsccommunity/DscResource.DocGenerator/issues/121.
    #>
    hidden [System.Object] $SqlServerObject

    [DscProperty(Key)]
    [System.String]
    $InstanceName

    [DscProperty()]
    [System.String]
    $ServerName = (Get-ComputerName)

    [DscProperty()]
    [PSCredential]
    $Credential

    [DscProperty(NotConfigurable)]
    [SqlReason[]]
    $Reasons

    # Passing the module's base directory to the base constructor.
    SqlResourceBase () : base ($PSScriptRoot)
    {
        $this.SqlServerObject = $null
    }

    <#
        Returns and reuses the server connection object. If the server connection
        object does not exist a connection to the SQL Server instance will occur.

        This should return an object of type [Microsoft.SqlServer.Management.Smo.Server]
        but using that type fails the build process currently.
        See issue https://github.com/dsccommunity/DscResource.DocGenerator/issues/121.
    #>
    hidden [System.Object] GetServerObject()
    {
        if (-not $this.SqlServerObject)
        {
            $connectSqlDscDatabaseEngineParameters = @{
                ServerName   = $this.ServerName
                InstanceName = $this.InstanceName
                ErrorAction  = 'Stop'
            }

            if ($this.Credential)
            {
                $connectSqlDscDatabaseEngineParameters.Credential = $this.Credential
            }

            $this.SqlServerObject = Connect-SqlDscDatabaseEngine @connectSqlDscDatabaseEngineParameters
        }

        return $this.SqlServerObject
    }
}
#EndRegion '.\Classes\011.SqlResourceBase.ps1' 84
#Region '.\Classes\020.SqlAudit.ps1' -1

<#
    .SYNOPSIS
        The `SqlAudit` DSC resource is used to create, modify, or remove
        server audits.

    .DESCRIPTION
        The `SqlAudit` DSC resource is used to create, modify, or remove
        server audits.

        The built-in parameter **PSDscRunAsCredential** can be used to run the resource
        as another user. The resource will then authenticate to the SQL Server
        instance as that user. It also possible to instead use impersonation by the
        parameter **Credential**.

        ## Requirements

        * Target machine must be running Windows Server 2012 or later.
        * Target machine must be running SQL Server Database Engine 2012 or later.
        * Target machine must have access to the SQLPS PowerShell module or the SqlServer
          PowerShell module.

        ## Known issues

        All issues are not listed here, see [here for all open issues](https://github.com/dsccommunity/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlAudit).

        ### Property **Reasons** does not work with **PSDscRunAsCredential**

        When using the built-in parameter **PSDscRunAsCredential** the read-only
        property **Reasons** will return empty values for the properties **Code**
        and **Phrase. The built-in property **PSDscRunAsCredential** does not work
        together with class-based resources that using advanced type like the parameter
        **Reasons** have.

        ### Using **Credential** property

        SQL Authentication and Group Managed Service Accounts is not supported as
        impersonation credentials. Currently only Windows Integrated Security is
        supported to use as credentials.

        For Windows Authentication the username must either be provided with the User
        Principal Name (UPN), e.g. `username@domain.local` or if using non-domain
        (for example a local Windows Server account) account the username must be
        provided without the NetBIOS name, e.g. `username`. Using the NetBIOS name, e.g
        using the format `DOMAIN\username` will not work.

        See more information in [Credential Overview](https://github.com/dsccommunity/SqlServerDsc/wiki/CredentialOverview).

    .PARAMETER Name
        The name of the audit.

    .PARAMETER LogType
        Specifies the to which log an audit logs to. Mutually exclusive to parameter
        **Path**.

    .PARAMETER Path
        Specifies the destination path for a file audit. Mutually exclusive to parameter
        **LogType**.

    .PARAMETER Filter
        Specifies the filter that should be used on the audit.

    .PARAMETER MaximumFiles
        Specifies the number of files on disk. Mutually exclusive to parameter
        **MaximumRolloverFiles**. Mutually exclusive to parameter **LogType**.

    .PARAMETER MaximumFileSize
        Specifies the maximum file size in units by parameter **MaximumFileSizeUnit**.
        If this is specified the parameter **MaximumFileSizeUnit** must also be
        specified. Mutually exclusive to parameter **LogType**. Minimum allowed value
        is 2 (MB). It also allowed to set the value to 0 which mean unlimited file
        size.

    .PARAMETER MaximumFileSizeUnit
        Specifies the unit that is used for the file size.
        If this is specified the parameter **MaximumFileSize** must also be
        specified. Mutually exclusive to parameter **LogType**.

    .PARAMETER MaximumRolloverFiles
        Specifies the amount of files on disk before SQL Server starts reusing
        the files. Mutually exclusive to parameter **MaximumFiles** and **LogType**.

    .PARAMETER OnFailure
        Specifies what should happen when writing events to the store fails.
        This can be `Continue`, `FailOperation`, or `Shutdown`.

    .PARAMETER QueueDelay
        Specifies the maximum delay before a event is written to the store.
        When set to low this could impact server performance.
        When set to high events could be missing when a server crashes.

    .PARAMETER ReserveDiskSpace
        Specifies if the needed file space should be reserved. only needed
        when writing to a file log. Mutually exclusive to parameter **LogType**.

    .PARAMETER Enabled
        Specifies if the audit should be enabled. Defaults to `$false`.

    .PARAMETER Ensure
        Specifies if the server audit should be present or absent. If set to `Present`
        the audit will be added if it does not exist, or updated if the audit exist.
        If `Absent` then the audit will be removed from the server. Defaults to
        `Present`.

    .PARAMETER Force
        Specifies if it is allowed to re-create the server audit if a current audit
        exist with the same name but of a different audit type. Defaults to `$false`
        not allowing server audits to be re-created.

    .EXAMPLE
        Invoke-DscResource -ModuleName SqlServerDsc -Name SqlAudit -Method Get -Property @{
            ServerName           = 'localhost'
            InstanceName         = 'SQL2017'
            Credential           = (Get-Credential -UserName 'myuser@company.local' -Message 'Password:')
            Name                 = 'Log1'
        }

        This example shows how to call the resource using Invoke-DscResource.
#>
[DscResource(RunAsCredential = 'Optional')]
class SqlAudit : SqlResourceBase
{
    [DscProperty(Key)]
    [System.String]
    $Name

    [DscProperty()]
    [ValidateSet('SecurityLog', 'ApplicationLog')]
    [System.String]
    $LogType

    # The Path is evaluated if exist in AssertProperties().
    [DscProperty()]
    [System.String]
    $Path

    [DscProperty()]
    [System.String]
    $AuditFilter

    [DscProperty()]
    [Nullable[System.UInt32]]
    $MaximumFiles

    [DscProperty()]
    # There is an extra evaluation in AssertProperties() for this range.
    [ValidateRange(0, 2147483647)]
    [Nullable[System.UInt32]]
    $MaximumFileSize

    [DscProperty()]
    [ValidateSet('Megabyte', 'Gigabyte', 'Terabyte')]
    [System.String]
    $MaximumFileSizeUnit

    [DscProperty()]
    [ValidateRange(0, 2147483647)]
    [Nullable[System.UInt32]]
    $MaximumRolloverFiles

    [DscProperty()]
    [ValidateSet('Continue', 'FailOperation', 'Shutdown')]
    [System.String]
    $OnFailure

    [DscProperty()]
    # There is an extra evaluation in AssertProperties() for this range.
    [ValidateRange(0, 2147483647)]
    [Nullable[System.UInt32]]
    $QueueDelay

    [DscProperty()]
    [ValidatePattern('^[0-9a-fA-F]{8}-(?:[0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$')]
    [System.String]
    $AuditGuid

    [DscProperty()]
    [Nullable[System.Boolean]]
    $ReserveDiskSpace

    [DscProperty()]
    [Nullable[System.Boolean]]
    $Enabled

    [DscProperty()]
    [Ensure]
    $Ensure = [Ensure]::Present

    [DscProperty()]
    [Nullable[System.Boolean]]
    $Force

    SqlAudit () : base ()
    {
        # These properties will not be enforced.
        $this.ExcludeDscProperties = @(
            'ServerName'
            'InstanceName'
            'Name'
            'Credential'
            'Force'
        )
    }

    [SqlAudit] Get()
    {
        # Call the base method to return the properties.
        return ([ResourceBase] $this).Get()
    }

    [System.Boolean] Test()
    {
        # Call the base method to test all of the properties that should be enforced.
        return ([ResourceBase] $this).Test()
    }

    [void] Set()
    {
        # Call the base method to enforce the properties.
        ([ResourceBase] $this).Set()
    }

    <#
        Base method Get() call this method to get the current state as a hashtable.
        The parameter properties will contain the key properties.
    #>
    hidden [System.Collections.Hashtable] GetCurrentState([System.Collections.Hashtable] $properties)
    {
        Write-Verbose -Message (
            $this.localizedData.EvaluateServerAudit -f @(
                $properties.Name,
                $properties.InstanceName
            )
        )

        $currentStateCredential = $null

        if ($this.Credential)
        {
            <#
                This does not work, even if username is set, the method Get() will
                return an empty PSCredential-object. Kept it here so it at least
                return a Credential object.
            #>
            $currentStateCredential = [PSCredential]::new(
                $this.Credential.UserName,
                [SecureString]::new()
            )
        }

        <#
            Only set key property Name if the audit exist. Base class will set it
            and handle Ensure.
        #>
        $currentState = @{
            Credential   = $currentStateCredential
            InstanceName = $properties.InstanceName
            ServerName   = $this.ServerName
            Force        = $this.Force
        }

        $serverObject = $this.GetServerObject()

        $auditObjectArray = $serverObject |
            Get-SqlDscAudit -Name $properties.Name -ErrorAction 'SilentlyContinue'

        # Pick the only object in the array.
        $auditObject = $auditObjectArray | Select-Object -First 1

        if ($auditObject)
        {
            $currentState.Name = $properties.Name

            if ($auditObject.DestinationType -in @('ApplicationLog', 'SecurityLog'))
            {
                $currentState.LogType = $auditObject.DestinationType.ToString()
            }

            if ($auditObject.FilePath)
            {
                # Remove trailing slash or backslash.
                $currentState.Path = $auditObject.FilePath -replace '[\\|/]*$'
            }

            $currentState.AuditFilter = $auditObject.Filter
            $currentState.MaximumFiles = [System.UInt32] $auditObject.MaximumFiles
            $currentState.MaximumFileSize = [System.UInt32] $auditObject.MaximumFileSize

            # The value of MaximumFileSizeUnit can be zero, so have to check against $null
            if ($null -ne $auditObject.MaximumFileSizeUnit)
            {
                $convertedMaximumFileSizeUnit = (
                    @{
                        0 = 'Megabyte'
                        1 = 'Gigabyte'
                        2 = 'Terabyte'
                    }
                ).($auditObject.MaximumFileSizeUnit.value__)

                $currentState.MaximumFileSizeUnit = $convertedMaximumFileSizeUnit
            }

            $currentState.MaximumRolloverFiles = [System.UInt32] $auditObject.MaximumRolloverFiles
            $currentState.OnFailure = $auditObject.OnFailure
            $currentState.QueueDelay = [System.UInt32] $auditObject.QueueDelay
            $currentState.AuditGuid = $auditObject.Guid
            $currentState.ReserveDiskSpace = $auditObject.ReserveDiskSpace
            $currentState.Enabled = $auditObject.Enabled
        }

        return $currentState
    }

    <#
        Base method Set() call this method with the properties that should be
        enforced are not in desired state. It is not called if all properties
        are in desired state. The variable $properties contain the properties
        that are not in desired state.
    #>
    hidden [void] Modify([System.Collections.Hashtable] $properties)
    {
        $serverObject = $this.GetServerObject()
        $auditObject = $null

        if ($properties.Keys -contains 'Ensure')
        {
            # Evaluate the desired state for property Ensure.
            switch ($properties.Ensure)
            {
                'Present'
                {
                    # Create the audit since it was missing. Always created disabled.
                    $auditObject = $this.CreateAudit()
                }

                'Absent'
                {
                    # Remove the audit since it was present
                    $serverObject | Remove-SqlDscAudit -Name $this.Name -Force
                }
            }
        }
        else
        {
            <#
                Update any properties not in desired state if the audit should be present.
                At this point it is assumed the audit exist since Ensure property was
                in desired state.

                If the desired state happens to be Absent then ignore any properties not
                in desired state (user have in that case wrongly added properties to an
                "absent configuration").
            #>
            if ($this.Ensure -eq [Ensure]::Present)
            {
                $auditObjectArray = $serverObject |
                    Get-SqlDscAudit -Name $this.Name -ErrorAction 'Stop'

                # Pick the only object in the array.
                $auditObject = $auditObjectArray | Select-Object -First 1

                if ($auditObject)
                {
                    $auditIsWrongType = (
                        # If $auditObject.DestinationType is not null.
                        $null -ne $auditObject.DestinationType -and (
                            # Path is not in desired state but the audit is not of type File.
                            $properties.ContainsKey('Path') -and $auditObject.DestinationType -ne 'File'
                        ) -or (
                            # LogType is not in desired state but the audit is of type File.
                            $properties.ContainsKey('LogType') -and $auditObject.DestinationType -eq 'File'
                        )
                    )

                    # Does the audit need to be re-created?
                    if ($auditIsWrongType)
                    {
                        if ($this.Force -eq $true)
                        {
                            $auditObject | Remove-SqlDscAudit -Force

                            $auditObject = $this.CreateAudit()
                        }
                        else
                        {
                            New-InvalidOperationException -Message $this.localizedData.AuditIsWrongType
                        }
                    }
                    else
                    {
                        <#
                            Should evaluate DestinationType so that is does not try to set a
                            File audit property when audit type is of a Log-type.
                        #>
                        if ($null -ne $auditObject.DestinationType -and $auditObject.DestinationType -ne 'File')
                        {
                            # Look for file audit properties not in desired state
                            $fileAuditProperty = $properties.Keys.Where({
                                    $_ -in @(
                                        'Path'
                                        'MaximumFiles'
                                        'MaximumFileSize'
                                        'MaximumFileSizeUnit'
                                        'MaximumRolloverFiles'
                                        'ReserveDiskSpace'
                                    )
                                })

                            # If a property was found, throw an exception.
                            if ($fileAuditProperty.Count -gt 0)
                            {
                                New-InvalidOperationException -Message ($this.localizedData.AuditOfWrongTypeForUseWithProperty -f $auditObject.DestinationType)
                            }
                        }

                        # Get all optional properties that has an assigned value.
                        $assignedOptionalDscProperties = $this | Get-DscProperty -HasValue -Attribute 'Optional' -ExcludeName @(
                            # Remove optional properties that is not an audit property.
                            'ServerName'
                            'Ensure'
                            'Force'
                            'Credential'

                            # Remove this audit property since it must be handled later.
                            'Enabled'
                        )

                        <#
                            Only call Set when there is a property to Set. The property
                            Enabled was ignored, so it could be the only one that was
                            not in desired state (Enabled is handled later).
                        #>
                        if ($assignedOptionalDscProperties.Count -gt 0)
                        {
                            <#
                                This calls Set-SqlDscAudit to set all the desired value
                                even if they were in desired state. Then the no logic is
                                needed to make sure we call using the correct parameter
                                set that Set-SqlDscAudit requires.
                            #>
                            $auditObject | Set-SqlDscAudit @assignedOptionalDscProperties -Force
                        }
                    }
                }
            }
        }

        <#
            If there is an audit object either from a newly created or fetched from
            current state, and if the desired state is Present, evaluate if the
            audit should be enable or disable.
        #>
        if ($auditObject -and $this.Ensure -eq [Ensure]::Present -and $properties.Keys -contains 'Enabled')
        {
            switch ($properties.Enabled)
            {
                $true
                {
                    $serverObject | Enable-SqlDscAudit -Name $this.Name -Force
                }

                $false
                {
                    $serverObject | Disable-SqlDscAudit -Name $this.Name -Force
                }
            }
        }
    }

    <#
        Base method Assert() call this method with the properties that was assigned
        a value.
    #>
    hidden [void] AssertProperties([System.Collections.Hashtable] $properties)
    {
        # The properties MaximumFiles and MaximumRolloverFiles are mutually exclusive.
        $assertBoundParameterParameters = @{
            BoundParameterList     = $properties
            MutuallyExclusiveList1 = @(
                'MaximumFiles'
            )
            MutuallyExclusiveList2 = @(
                'MaximumRolloverFiles'
            )
        }

        Assert-BoundParameter @assertBoundParameterParameters

        # LogType is mutually exclusive from any of the File audit properties.
        $assertBoundParameterParameters = @{
            BoundParameterList     = $properties
            MutuallyExclusiveList1 = @(
                'LogType'
            )
            MutuallyExclusiveList2 = @(
                'Path'
                'MaximumFiles'
                'MaximumFileSize'
                'MaximumFileSizeUnit'
                'MaximumRolloverFiles'
                'ReserveDiskSpace'
            )
        }

        Assert-BoundParameter @assertBoundParameterParameters

        # Get all assigned *FileSize properties.
        $assignedSizeProperty = $properties.Keys.Where({
                $_ -in @(
                    'MaximumFileSize',
                    'MaximumFileSizeUnit'
                )
            })

        <#
            Neither or both of the properties MaximumFileSize and MaximumFileSizeUnit
            must be assigned.
        #>
        if ($assignedSizeProperty.Count -eq 1)
        {
            $errorMessage = $this.localizedData.BothFileSizePropertiesMustBeSet

            New-InvalidArgumentException -ArgumentName 'MaximumFileSize, MaximumFileSizeUnit' -Message $errorMessage
        }

        <#
            Since we cannot use [ValidateScript()], and it is no possible to exclude
            a value in the [ValidateRange()], evaluate so 1 is not assigned.
        #>
        if ($properties.Keys -contains 'MaximumFileSize' -and $properties.MaximumFileSize -eq 1)
        {
            $errorMessage = $this.localizedData.MaximumFileSizeValueInvalid

            New-InvalidArgumentException -ArgumentName 'MaximumFileSize' -Message $errorMessage
        }

        <#
            Since we cannot use [ValidateScript()], and it is no possible to exclude
            a value in the [ValidateRange()], evaluate so 1-999 is not assigned.
        #>
        if ($properties.Keys -contains 'QueueDelay' -and $properties.QueueDelay -in 1..999)
        {
            $errorMessage = $this.localizedData.QueueDelayValueInvalid

            New-InvalidArgumentException -ArgumentName 'QueueDelay' -Message $errorMessage
        }

        # ReserveDiskSpace can only be used with MaximumFiles.
        if ($properties.Keys -contains 'ReserveDiskSpace' -and $properties.Keys -notcontains 'MaximumFiles')
        {
            $errorMessage = $this.localizedData.ReservDiskSpaceWithoutMaximumFiles

            New-InvalidArgumentException -ArgumentName 'ReserveDiskSpace' -Message $errorMessage
        }

        # Test so that the path exists.
        if ($properties.Keys -contains 'Path' -and -not (Test-Path -Path $properties.Path))
        {
            $errorMessage = $this.localizedData.PathInvalid -f $properties.Path

            New-InvalidArgumentException -ArgumentName 'Path' -Message $errorMessage
        }
    }

    <#
        Create and returns the desired audit object. Always created disabled.

        This should return an object of type [Microsoft.SqlServer.Management.Smo.Audit]
        but using that type fails the build process currently.
        See issue https://github.com/dsccommunity/DscResource.DocGenerator/issues/121.
    #>
    hidden [System.Object] CreateAudit()
    {
        # Get all properties that has an assigned value.
        $assignedDscProperties = $this | Get-DscProperty -HasValue -Attribute @(
            'Key'
            'Optional'
        ) -ExcludeName @(
            # Remove properties that is not an audit property.
            'InstanceName'
            'ServerName'
            'Ensure'
            'Force'
            'Credential'

            # Remove this audit property since it must be handled later.
            'Enabled'
        )

        if ($assignedDscProperties.Keys -notcontains 'LogType' -and $assignedDscProperties.Keys -notcontains 'Path')
        {
            New-InvalidOperationException -Message $this.localizedData.CannotCreateNewAudit
        }

        $serverObject = $this.GetServerObject()

        $auditObject = $serverObject | New-SqlDscAudit @assignedDscProperties -Force -PassThru

        return $auditObject
    }
}
#EndRegion '.\Classes\020.SqlAudit.ps1' 601
#Region '.\Classes\020.SqlDatabasePermission.ps1' -1

<#
    .SYNOPSIS
        The `SqlDatabasePermission` DSC resource is used to grant, deny or revoke
        permissions for a user in a database.

    .DESCRIPTION
        The `SqlDatabasePermission` DSC resource is used to grant, deny or revoke
        permissions for a user in a database. For more information about permissions,
        please read the article [Permissions (Database Engine)](https://docs.microsoft.com/en-us/sql/relational-databases/security/permissions-database-engine).

        > [!CAUTION]
        > When revoking permission with PermissionState 'GrantWithGrant', both the
        > grantee and _all the other users the grantee has granted the same permission_
        > _to_, will also get their permission revoked.

        ## Requirements

        * Target machine must be running Windows Server 2012 or later.
        * Target machine must be running SQL Server Database Engine 2012 or later.

        ## Known issues

        All issues are not listed here, see [here for all open issues](https://github.com/dsccommunity/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlDatabasePermission).

        ### `PSDscRunAsCredential` not supported

        The built-in property `PSDscRunAsCredential` does not work with class-based
        resources that using advanced type like the parameters `Permission` and
        `Reasons` has. Use the parameter `Credential` instead of `PSDscRunAsCredential`.

        ### Using `Credential` property.

        SQL Authentication and Group Managed Service Accounts is not supported as
        impersonation credentials. Currently only Windows Integrated Security is
        supported to use as credentials.

        For Windows Authentication the username must either be provided with the User
        Principal Name (UPN), e.g. 'username@domain.local' or if using non-domain
        (for example a local Windows Server account) account the username must be
        provided without the NetBIOS name, e.g. 'username'. The format 'DOMAIN\username'
        will not work.

        See more information in [Credential Overview](https://github.com/dsccommunity/SqlServerDsc/wiki/CredentialOverview).

        ### Invalid values during compilation

        The parameter Permission is of type `[DatabasePermission]`. If a property
        in the type is set to an invalid value an error will occur, correct the
        values in the properties to valid values.
        This happens when the values are validated against the `[ValidateSet()]`
        of the resource. When there is an invalid value the following error will
        be thrown when the configuration is run (it will not show during compilation):

        ```plaintext
        Failed to create an object of PowerShell class SqlDatabasePermission.
            + CategoryInfo          : InvalidOperation: (root/Microsoft/...ConfigurationManager:String) [], CimException
            + FullyQualifiedErrorId : InstantiatePSClassObjectFailed
            + PSComputerName        : localhost
        ```

    .PARAMETER DatabaseName
        The name of the database.

    .PARAMETER Name
        The name of the user that should be granted or denied the permission.

    .PARAMETER Permission
        An array of database permissions to enforce. Any permission that is not
        part of the desired state will be revoked.

        Must provide all permission states (`Grant`, `Deny`, `GrantWithGrant`) with
        at least an empty string array for the advanced type `DatabasePermission`'s
        property `Permission`.

        Valid permission names can be found in the article [DatabasePermissionSet Class properties](https://docs.microsoft.com/en-us/dotnet/api/microsoft.sqlserver.management.smo.databasepermissionset#properties).

        This is an array of CIM instances of advanced type `DatabasePermission` from
        the namespace `root/Microsoft/Windows/DesiredStateConfiguration`.

    .PARAMETER PermissionToInclude
        An array of database permissions to include to the current state. The
        current state will not be affected unless the current state contradict the
        desired state. For example if the desired state specifies a deny permissions
        but in the current state that permission is granted, that permission will
        be changed to be denied.

        Valid permission names can be found in the article [DatabasePermissionSet Class properties](https://docs.microsoft.com/en-us/dotnet/api/microsoft.sqlserver.management.smo.databasepermissionset#properties).

        This is an array of CIM instances of advanced type `DatabasePermission` from
        the namespace `root/Microsoft/Windows/DesiredStateConfiguration`.

    .PARAMETER PermissionToExclude
        An array of database permissions to exclude (revoke) from the current state.

        Valid permission names can be found in the article [DatabasePermissionSet Class properties](https://docs.microsoft.com/en-us/dotnet/api/microsoft.sqlserver.management.smo.databasepermissionset#properties).

        This is an array of CIM instances of advanced type `DatabasePermission` from
        the namespace `root/Microsoft/Windows/DesiredStateConfiguration`.

    .EXAMPLE
        Invoke-DscResource -ModuleName SqlServerDsc -Name SqlDatabasePermission -Method Get -Property @{
            ServerName           = 'localhost'
            InstanceName         = 'SQL2017'
            DatabaseName         = 'AdventureWorks'
            Credential           = (Get-Credential -UserName 'myuser@company.local' -Message 'Password:')
            Name                 = 'INSTANCE\SqlUser'
            Permission           = [Microsoft.Management.Infrastructure.CimInstance[]] @(
                (
                    New-CimInstance -ClientOnly -Namespace root/Microsoft/Windows/DesiredStateConfiguration -ClassName DatabasePermission -Property @{
                            State = 'Grant'
                            Permission = @('select')
                    }
                )
                (
                    New-CimInstance -ClientOnly -Namespace root/Microsoft/Windows/DesiredStateConfiguration -ClassName DatabasePermission -Property @{
                        State = 'GrantWithGrant'
                        Permission = [System.String[]] @()
                    }
                )
                (
                    New-CimInstance -ClientOnly -Namespace root/Microsoft/Windows/DesiredStateConfiguration -ClassName DatabasePermission -Property @{
                        State = 'Deny'
                        Permission = [System.String[]] @()
                    }
                )
            )
        }

        This example shows how to call the resource using Invoke-DscResource.

    .NOTES
        The built-in property `PsDscRunAsCredential` is not supported on this DSC
        resource as it uses a complex type (another class as the type for a DSC
        property). If the property `PsDscRunAsCredential` would be used, then the
        complex type will not return any values from Get(). This is most likely an
        issue (bug) with _PowerShell DSC_. Instead (as a workaround) the property
        `Credential` must be used to specify how to connect to the _SQL Server_
        instance.
#>

[DscResource(RunAsCredential = 'NotSupported')]
class SqlDatabasePermission : SqlResourceBase
{
    [DscProperty(Key)]
    [System.String]
    $DatabaseName

    [DscProperty(Key)]
    [System.String]
    $Name

    [DscProperty()]
    [DatabasePermission[]]
    $Permission

    [DscProperty()]
    [DatabasePermission[]]
    $PermissionToInclude

    [DscProperty()]
    [DatabasePermission[]]
    $PermissionToExclude

    SqlDatabasePermission() : base ()
    {
        # These properties will not be enforced.
        $this.ExcludeDscProperties = @(
            'ServerName'
            'InstanceName'
            'DatabaseName'
            'Name'
            'Credential'
        )
    }

    [SqlDatabasePermission] Get()
    {
        # Call the base method to return the properties.
        return ([ResourceBase] $this).Get()
    }

    [System.Boolean] Test()
    {
        # Call the base method to test all of the properties that should be enforced.
        return ([ResourceBase] $this).Test()
    }

    [void] Set()
    {
        # Call the base method to enforce the properties.
        ([ResourceBase] $this).Set()
    }

    <#
        Base method Get() call this method to get the current state as a hashtable.
        The parameter properties will contain the key properties.
    #>
    hidden [System.Collections.Hashtable] GetCurrentState([System.Collections.Hashtable] $properties)
    {
        $currentStateCredential = $null

        if ($this.Credential)
        {
            <#
                This does not work, even if username is set, the method Get() will
                return an empty PSCredential-object. Kept it here so it at least
                return a Credential object.
            #>
            $currentStateCredential = [PSCredential]::new(
                $this.Credential.UserName,
                [SecureString]::new()
            )
        }

        $currentState = @{
            Credential = $currentStateCredential
            Permission = [DatabasePermission[]] @()
        }

        Write-Verbose -Message (
            $this.localizedData.EvaluateDatabasePermissionForPrincipal -f @(
                $properties.Name,
                $properties.DatabaseName,
                $properties.InstanceName
            )
        )

        $serverObject = $this.GetServerObject()

        $databasePermissionInfo = $serverObject |
            Get-SqlDscDatabasePermission -DatabaseName $this.DatabaseName -Name $this.Name -ErrorAction 'SilentlyContinue'

        # If permissions was returned, build the current permission array of [DatabasePermission].
        if ($databasePermissionInfo)
        {
            [DatabasePermission[]] $currentState.Permission = $databasePermissionInfo | ConvertTo-SqlDscDatabasePermission
        }

        # Always return all State; 'Grant', 'GrantWithGrant', and 'Deny'.
        foreach ($currentPermissionState in @('Grant', 'GrantWithGrant', 'Deny'))
        {
            if ($currentState.Permission.State -notcontains $currentPermissionState)
            {
                [DatabasePermission[]] $currentState.Permission += [DatabasePermission] @{
                    State      = $currentPermissionState
                    Permission = @()
                }
            }
        }

        $isPropertyPermissionToIncludeAssigned = $this | Test-DscProperty -Name 'PermissionToInclude' -HasValue

        if ($isPropertyPermissionToIncludeAssigned)
        {
            $currentState.PermissionToInclude = [DatabasePermission[]] @()

            # Evaluate so that the desired state is present in the current state.
            foreach ($desiredIncludePermission in $this.PermissionToInclude)
            {
                <#
                    Current state will always have all possible states, so this
                    will always return one item.
                #>
                $currentStatePermissionForState = $currentState.Permission |
                    Where-Object -FilterScript {
                        $_.State -eq $desiredIncludePermission.State
                    }

                $currentStatePermissionToInclude = [DatabasePermission] @{
                    State      = $desiredIncludePermission.State
                    Permission = @()
                }

                foreach ($desiredIncludePermissionName in $desiredIncludePermission.Permission)
                {
                    if ($currentStatePermissionForState.Permission -contains $desiredIncludePermissionName)
                    {
                        <#
                            If the permission exist in the current state, add the
                            permission to $currentState.PermissionToInclude so that
                            the base class's method Compare() sees the property as
                            being in desired state (when the property PermissionToInclude
                            in the current state and desired state are equal).
                        #>
                        $currentStatePermissionToInclude.Permission += $desiredIncludePermissionName
                    }
                    else
                    {
                        Write-Verbose -Message (
                            $this.localizedData.DesiredPermissionAreAbsent -f @(
                                $desiredIncludePermissionName
                            )
                        )
                    }
                }

                [DatabasePermission[]] $currentState.PermissionToInclude += $currentStatePermissionToInclude
            }
        }

        $isPropertyPermissionToExcludeAssigned = $this | Test-DscProperty -Name 'PermissionToExclude' -HasValue

        if ($isPropertyPermissionToExcludeAssigned)
        {
            $currentState.PermissionToExclude = [DatabasePermission[]] @()

            # Evaluate so that the desired state is missing from the current state.
            foreach ($desiredExcludePermission in $this.PermissionToExclude)
            {
                <#
                    Current state will always have all possible states, so this
                    will always return one item.
                #>
                $currentStatePermissionForState = $currentState.Permission |
                    Where-Object -FilterScript {
                        $_.State -eq $desiredExcludePermission.State
                    }

                $currentStatePermissionToExclude = [DatabasePermission] @{
                    State      = $desiredExcludePermission.State
                    Permission = @()
                }

                foreach ($desiredExcludedPermissionName in $desiredExcludePermission.Permission)
                {
                    if ($currentStatePermissionForState.Permission -contains $desiredExcludedPermissionName)
                    {
                        Write-Verbose -Message (
                            $this.localizedData.DesiredAbsentPermissionArePresent -f @(
                                $desiredExcludedPermissionName
                            )
                        )
                    }
                    else
                    {
                        <#
                            If the permission does _not_ exist in the current state, add
                            the permission to $currentState.PermissionToExclude so that
                            the base class's method Compare() sees the property as being
                            in desired state (when the property PermissionToExclude in
                            the current state and desired state are equal).
                        #>
                        $currentStatePermissionToExclude.Permission += $desiredExcludedPermissionName
                    }
                }

                [DatabasePermission[]] $currentState.PermissionToExclude += $currentStatePermissionToExclude
            }
        }

        return $currentState
    }

    <#
        Base method Set() call this method with the properties that should be
        enforced are not in desired state. It is not called if all properties
        are in desired state. The variable $properties contain the properties
        that are not in desired state.
    #>
    hidden [void] Modify([System.Collections.Hashtable] $properties)
    {
        $serverObject = $this.GetServerObject()

        $testSqlDscIsDatabasePrincipalParameters = @{
            ServerObject      = $serverObject
            DatabaseName      = $this.DatabaseName
            Name              = $this.Name
            ExcludeFixedRoles = $true
        }

        # This will test wether the database and the principal exist.
        $isDatabasePrincipal = Test-SqlDscIsDatabasePrincipal @testSqlDscIsDatabasePrincipalParameters

        if (-not $isDatabasePrincipal)
        {
            $missingPrincipalMessage = $this.localizedData.NameIsMissing -f @(
                $this.Name,
                $this.DatabaseName,
                $this.InstanceName
            )

            New-InvalidOperationException -Message $missingPrincipalMessage
        }

        # This holds each state and their permissions to be revoked.
        [DatabasePermission[]] $permissionsToRevoke = @()
        [DatabasePermission[]] $permissionsToGrantOrDeny = @()

        if ($properties.ContainsKey('Permission'))
        {
            $keyProperty = $this | Get-DscProperty -Attribute 'Key'

            $currentState = $this.GetCurrentState($keyProperty)

            <#
                Evaluate if there are any permissions that should be revoked
                from the current state.
            #>
            foreach ($currentDesiredPermissionState in $properties.Permission)
            {
                $currentPermissionsForState = $currentState.Permission |
                    Where-Object -FilterScript {
                        $_.State -eq $currentDesiredPermissionState.State
                    }

                foreach ($permissionName in $currentPermissionsForState.Permission)
                {
                    if ($permissionName -notin $currentDesiredPermissionState.Permission)
                    {
                        # Look for an existing object in the array.
                        $updatePermissionToRevoke = $permissionsToRevoke |
                            Where-Object -FilterScript {
                                $_.State -eq $currentDesiredPermissionState.State
                            }

                        # Update the existing object in the array, or create a new object
                        if ($updatePermissionToRevoke)
                        {
                            $updatePermissionToRevoke.Permission += $permissionName
                        }
                        else
                        {
                            [DatabasePermission[]] $permissionsToRevoke += [DatabasePermission] @{
                                State      = $currentPermissionsForState.State
                                Permission = $permissionName
                            }
                        }
                    }
                }
            }

            <#
                At least one permission were missing or should have not be present
                in the current state. Grant or Deny all permission assigned to the
                property Permission regardless if they were already present or not.
            #>
            [DatabasePermission[]] $permissionsToGrantOrDeny = $properties.Permission
        }

        if ($properties.ContainsKey('PermissionToExclude'))
        {
            <#
                At least one permission were present in the current state. Revoke
                all permission assigned to the property PermissionToExclude
                regardless if they were already revoked or not.
            #>
            [DatabasePermission[]] $permissionsToRevoke = $properties.PermissionToExclude
        }

        if ($properties.ContainsKey('PermissionToInclude'))
        {
            <#
                At least one permission were missing or should have not be present
                in the current state. Grant or Deny all permission assigned to the
                property Permission regardless if they were already present or not.
            #>
            [DatabasePermission[]] $permissionsToGrantOrDeny = $properties.PermissionToInclude
        }

        # Revoke all the permissions set in $permissionsToRevoke
        if ($permissionsToRevoke)
        {
            foreach ($currentStateToRevoke in $permissionsToRevoke)
            {
                $revokePermissionSet = $currentStateToRevoke | ConvertFrom-SqlDscDatabasePermission

                $setSqlDscDatabasePermissionParameters = @{
                    ServerObject = $serverObject
                    DatabaseName = $this.DatabaseName
                    Name         = $this.Name
                    Permission   = $revokePermissionSet
                    State        = 'Revoke'
                    Force        = $true
                }

                if ($currentStateToRevoke.State -eq 'GrantWithGrant')
                {
                    $setSqlDscDatabasePermissionParameters.WithGrant = $true
                }

                try
                {
                    Set-SqlDscDatabasePermission @setSqlDscDatabasePermissionParameters
                }
                catch
                {
                    $errorMessage = $this.localizedData.FailedToRevokePermissionFromCurrentState -f @(
                        $this.Name,
                        $this.DatabaseName
                    )

                    New-InvalidOperationException -Message $errorMessage -ErrorRecord $_
                }
            }
        }

        if ($permissionsToGrantOrDeny)
        {
            foreach ($currentDesiredPermissionState in $permissionsToGrantOrDeny)
            {
                # If there is not an empty array, change permissions.
                if (-not [System.String]::IsNullOrEmpty($currentDesiredPermissionState.Permission))
                {
                    $permissionSet = $currentDesiredPermissionState | ConvertFrom-SqlDscDatabasePermission

                    $setSqlDscDatabasePermissionParameters = @{
                        ServerObject = $serverObject
                        DatabaseName = $this.DatabaseName
                        Name         = $this.Name
                        Permission   = $permissionSet
                        Force        = $true
                    }

                    try
                    {
                        switch ($currentDesiredPermissionState.State)
                        {
                            'GrantWithGrant'
                            {
                                Set-SqlDscDatabasePermission @setSqlDscDatabasePermissionParameters -State 'Grant' -WithGrant
                            }

                            default
                            {
                                Set-SqlDscDatabasePermission @setSqlDscDatabasePermissionParameters -State $currentDesiredPermissionState.State
                            }
                        }
                    }
                    catch
                    {
                        $errorMessage = $this.localizedData.FailedToSetPermission -f @(
                            $this.Name,
                            $this.DatabaseName
                        )

                        New-InvalidOperationException -Message $errorMessage -ErrorRecord $_
                    }
                }
            }
        }
    }

    <#
        Base method Assert() call this method with the properties that was assigned
        a value.
    #>
    hidden [void] AssertProperties([System.Collections.Hashtable] $properties)
    {
        # PermissionToInclude and PermissionToExclude should be mutually exclusive from Permission
        $assertBoundParameterParameters = @{
            BoundParameterList     = $properties
            MutuallyExclusiveList1 = @(
                'Permission'
            )
            MutuallyExclusiveList2 = @(
                'PermissionToInclude'
                'PermissionToExclude'
            )
        }

        Assert-BoundParameter @assertBoundParameterParameters

        # Get all assigned permission properties.
        $assignedPermissionProperty = $properties.Keys.Where({
                $_ -in @(
                    'Permission',
                    'PermissionToInclude',
                    'PermissionToExclude'
                )
            })

        # Must include either of the permission properties.
        if ([System.String]::IsNullOrEmpty($assignedPermissionProperty))
        {
            $errorMessage = $this.localizedData.MustAssignOnePermissionProperty

            New-InvalidArgumentException -ArgumentName 'Permission, PermissionToInclude, PermissionToExclude' -Message $errorMessage
        }

        foreach ($currentAssignedPermissionProperty in $assignedPermissionProperty)
        {
            # One State cannot exist several times in the same resource instance.
            $permissionStateGroupCount = @(
                $properties.$currentAssignedPermissionProperty |
                    Group-Object -NoElement -Property 'State' -CaseSensitive:$false |
                    Select-Object -ExpandProperty 'Count'
            )

            if ($permissionStateGroupCount -gt 1)
            {
                $errorMessage = $this.localizedData.DuplicatePermissionState

                New-InvalidArgumentException -ArgumentName $currentAssignedPermissionProperty -Message $errorMessage
            }

            # A specific permission must only exist in one permission state.
            $permissionGroupCount = $properties.$currentAssignedPermissionProperty.Permission |
                Group-Object -NoElement -CaseSensitive:$false |
                Select-Object -ExpandProperty 'Count'

            if ($permissionGroupCount -gt 1)
            {
                $errorMessage = $this.localizedData.DuplicatePermissionBetweenState

                New-InvalidArgumentException -ArgumentName $currentAssignedPermissionProperty -Message $errorMessage
            }
        }

        if ($properties.Keys -contains 'Permission')
        {
            # Each State must exist once.
            $missingPermissionState = (
                $properties.Permission.State -notcontains 'Grant' -or
                $properties.Permission.State -notcontains 'GrantWithGrant' -or
                $properties.Permission.State -notcontains 'Deny'
            )

            if ($missingPermissionState)
            {
                $errorMessage = $this.localizedData.MissingPermissionState

                New-InvalidArgumentException -ArgumentName 'Permission' -Message $errorMessage
            }
        }

        <#
            Each permission state in the properties PermissionToInclude and PermissionToExclude
            must have specified at minimum one permission.
        #>
        foreach ($currentAssignedPermissionProperty in @('PermissionToInclude', 'PermissionToExclude'))
        {
            if ($properties.Keys -contains $currentAssignedPermissionProperty)
            {
                foreach ($currentDatabasePermission in $properties.$currentAssignedPermissionProperty)
                {
                    if ($currentDatabasePermission.Permission.Count -eq 0)
                    {
                        $errorMessage = $this.localizedData.MustHaveMinimumOnePermissionInState -f $currentAssignedPermissionProperty

                        New-InvalidArgumentException -ArgumentName $currentAssignedPermissionProperty -Message $errorMessage
                    }
                }
            }
        }
    }
}
#EndRegion '.\Classes\020.SqlDatabasePermission.ps1' 647
#Region '.\Classes\020.SqlPermission.ps1' -1

<#
    .SYNOPSIS
        The `SqlPermission` DSC resource is used to grant, deny or revoke
        server permissions for a login.

    .DESCRIPTION
        The `SqlPermission` DSC resource is used to grant, deny or revoke
        Server permissions for a login. For more information about permissions,
        please read the article [Permissions (Database Engine)](https://docs.microsoft.com/en-us/sql/relational-databases/security/permissions-database-engine).

        > [!CAUTION]
        > When revoking permission with PermissionState 'GrantWithGrant', both the
        > grantee and _all the other users the grantee has granted the same permission_
        > _to_, will also get their permission revoked.

        ## Requirements

        * Target machine must be running Windows Server 2012 or later.
        * Target machine must be running SQL Server Database Engine 2012 or later.
        * Target machine must have access to the SQLPS PowerShell module or the SqlServer
          PowerShell module.

        ## Known issues

        All issues are not listed here, see [here for all open issues](https://github.com/dsccommunity/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlPermission).

        ### `PSDscRunAsCredential` not supported

        The built-in property `PSDscRunAsCredential` does not work with class-based
        resources that using advanced type like the parameters `Permission` and
        `Reasons` has. Use the parameter `Credential` instead of `PSDscRunAsCredential`.

        ### Using `Credential` property.

        SQL Authentication and Group Managed Service Accounts is not supported as
        impersonation credentials. Currently only Windows Integrated Security is
        supported to use as credentials.

        For Windows Authentication the username must either be provided with the User
        Principal Name (UPN), e.g. 'username@domain.local' or if using non-domain
        (for example a local Windows Server account) account the username must be
        provided without the NetBIOS name, e.g. 'username'. The format 'DOMAIN\username'
        will not work.

        See more information in [Credential Overview](https://github.com/dsccommunity/SqlServerDsc/wiki/CredentialOverview).

        ### Invalid values during compilation

        The parameter Permission is of type `[ServerPermission]`. If a property
        in the type is set to an invalid value an error will occur, correct the
        values in the properties to valid values.
        This happens when the values are validated against the `[ValidateSet()]`
        of the resource. When there is an invalid value the following error will
        be thrown when the configuration is run (it will not show during compilation):

        ```plaintext
        Failed to create an object of PowerShell class SqlPermission.
            + CategoryInfo          : InvalidOperation: (root/Microsoft/...ConfigurationManager:String) [], CimException
            + FullyQualifiedErrorId : InstantiatePSClassObjectFailed
            + PSComputerName        : localhost
        ```

    .PARAMETER Name
        The name of the user that should be granted or denied the permission.

    .PARAMETER Permission
        An array of server permissions to enforce. Any permission that is not
        part of the desired state will be revoked.

        Must provide all permission states (`Grant`, `Deny`, `GrantWithGrant`) with
        at least an empty string array for the advanced type `ServerPermission`'s
        property `Permission`.

        Valid permission names can be found in the article [ServerPermissionSet Class properties](https://docs.microsoft.com/en-us/dotnet/api/microsoft.sqlserver.management.smo.serverpermissionset#properties).

        This is an array of CIM instances of advanced type `ServerPermission` from
        the namespace `root/Microsoft/Windows/DesiredStateConfiguration`.

    .PARAMETER PermissionToInclude
        An array of server permissions to include to the current state. The
        current state will not be affected unless the current state contradict the
        desired state. For example if the desired state specifies a deny permissions
        but in the current state that permission is granted, that permission will
        be changed to be denied.

        Valid permission names can be found in the article [ServerPermissionSet Class properties](https://docs.microsoft.com/en-us/dotnet/api/microsoft.sqlserver.management.smo.serverpermissionset#properties).

        This is an array of CIM instances of advanced type `ServerPermission` from
        the namespace `root/Microsoft/Windows/DesiredStateConfiguration`.

    .PARAMETER PermissionToExclude
        An array of server permissions to exclude (revoke) from the current state.

        Valid permission names can be found in the article [ServerPermissionSet Class properties](https://docs.microsoft.com/en-us/dotnet/api/microsoft.sqlserver.management.smo.serverpermissionset#properties).

        This is an array of CIM instances of advanced type `ServerPermission` from
        the namespace `root/Microsoft/Windows/DesiredStateConfiguration`.

    .EXAMPLE
        Invoke-DscResource -ModuleName SqlServerDsc -Name SqlPermission -Method Get -Property @{
            ServerName           = 'localhost'
            InstanceName         = 'SQL2017'
            Credential           = (Get-Credential -UserName 'myuser@company.local' -Message 'Password:')
            Name                 = 'INSTANCE\SqlUser'
            Permission           = [Microsoft.Management.Infrastructure.CimInstance[]] @(
                (
                    New-CimInstance -ClientOnly -Namespace root/Microsoft/Windows/DesiredStateConfiguration -ClassName ServerPermission -Property @{
                            State = 'Grant'
                            Permission = @('select')
                    }
                )
                (
                    New-CimInstance -ClientOnly -Namespace root/Microsoft/Windows/DesiredStateConfiguration -ClassName ServerPermission -Property @{
                        State = 'GrantWithGrant'
                        Permission = [System.String[]] @()
                    }
                )
                (
                    New-CimInstance -ClientOnly -Namespace root/Microsoft/Windows/DesiredStateConfiguration -ClassName ServerPermission -Property @{
                        State = 'Deny'
                        Permission = [System.String[]] @()
                    }
                )
            )
        }

        This example shows how to call the resource using Invoke-DscResource.

    .NOTES
        The built-in property `PsDscRunAsCredential` is not supported on this DSC
        resource as it uses a complex type (another class as the type for a DSC
        property). If the property `PsDscRunAsCredential` would be used, then the
        complex type will not return any values from Get(). This is most likely an
        issue (bug) with _PowerShell DSC_. Instead (as a workaround) the property
        `Credential` must be used to specify how to connect to the SQL Server
        instance.
#>

[DscResource(RunAsCredential = 'NotSupported')]
class SqlPermission : SqlResourceBase
{
    [DscProperty(Key)]
    [System.String]
    $Name

    [DscProperty()]
    [ServerPermission[]]
    $Permission

    [DscProperty()]
    [ServerPermission[]]
    $PermissionToInclude

    [DscProperty()]
    [ServerPermission[]]
    $PermissionToExclude

    SqlPermission() : base ()
    {
        # These properties will not be enforced.
        $this.ExcludeDscProperties = @(
            'ServerName'
            'InstanceName'
            'Name'
            'Credential'
        )
    }

    [SqlPermission] Get()
    {
        # Call the base method to return the properties.
        return ([ResourceBase] $this).Get()
    }

    [System.Boolean] Test()
    {
        # Call the base method to test all of the properties that should be enforced.
        return ([ResourceBase] $this).Test()
    }

    [void] Set()
    {
        # Call the base method to enforce the properties.
        ([ResourceBase] $this).Set()
    }

    <#
        Base method Get() call this method to get the current state as a hashtable.
        The parameter properties will contain the key properties.
    #>
    hidden [System.Collections.Hashtable] GetCurrentState([System.Collections.Hashtable] $properties)
    {
        $currentStateCredential = $null

        if ($this.Credential)
        {
            <#
                This does not work, even if username is set, the method Get() will
                return an empty PSCredential-object. Kept it here so it at least
                return a Credential object.
            #>
            $currentStateCredential = [PSCredential]::new(
                $this.Credential.UserName,
                [SecureString]::new()
            )
        }

        $currentState = @{
            Credential = $currentStateCredential
            Permission = [ServerPermission[]] @()
        }

        Write-Verbose -Message (
            $this.localizedData.EvaluateServerPermissionForPrincipal -f @(
                $properties.Name,
                $properties.InstanceName
            )
        )

        $serverObject = $this.GetServerObject()

        $serverPermissionInfo = $serverObject |
            Get-SqlDscServerPermission -Name $this.Name -ErrorAction 'SilentlyContinue'

        # If permissions was returned, build the current permission array of [ServerPermission].
        if ($serverPermissionInfo)
        {
            [ServerPermission[]] $currentState.Permission = $serverPermissionInfo | ConvertTo-SqlDscServerPermission
        }

        # Always return all State; 'Grant', 'GrantWithGrant', and 'Deny'.
        foreach ($currentPermissionState in @('Grant', 'GrantWithGrant', 'Deny'))
        {
            if ($currentState.Permission.State -notcontains $currentPermissionState)
            {
                [ServerPermission[]] $currentState.Permission += [ServerPermission] @{
                    State      = $currentPermissionState
                    Permission = @()
                }
            }
        }

        $isPropertyPermissionToIncludeAssigned = $this | Test-DscProperty -Name 'PermissionToInclude' -HasValue

        if ($isPropertyPermissionToIncludeAssigned)
        {
            $currentState.PermissionToInclude = [ServerPermission[]] @()

            # Evaluate so that the desired state is present in the current state.
            foreach ($desiredIncludePermission in $this.PermissionToInclude)
            {
                <#
                    Current state will always have all possible states, so this
                    will always return one item.
                #>
                $currentStatePermissionForState = $currentState.Permission |
                    Where-Object -FilterScript {
                        $_.State -eq $desiredIncludePermission.State
                    }

                $currentStatePermissionToInclude = [ServerPermission] @{
                    State      = $desiredIncludePermission.State
                    Permission = @()
                }

                foreach ($desiredIncludePermissionName in $desiredIncludePermission.Permission)
                {
                    if ($currentStatePermissionForState.Permission -contains $desiredIncludePermissionName)
                    {
                        <#
                            If the permission exist in the current state, add the
                            permission to $currentState.PermissionToInclude so that
                            the base class's method Compare() sees the property as
                            being in desired state (when the property PermissionToInclude
                            in the current state and desired state are equal).
                        #>
                        $currentStatePermissionToInclude.Permission += $desiredIncludePermissionName
                    }
                    else
                    {
                        Write-Verbose -Message (
                            $this.localizedData.DesiredPermissionAreAbsent -f @(
                                $desiredIncludePermissionName
                            )
                        )
                    }
                }

                [ServerPermission[]] $currentState.PermissionToInclude += $currentStatePermissionToInclude
            }
        }

        $isPropertyPermissionToExcludeAssigned = $this | Test-DscProperty -Name 'PermissionToExclude' -HasValue

        if ($isPropertyPermissionToExcludeAssigned)
        {
            $currentState.PermissionToExclude = [ServerPermission[]] @()

            # Evaluate so that the desired state is missing from the current state.
            foreach ($desiredExcludePermission in $this.PermissionToExclude)
            {
                <#
                    Current state will always have all possible states, so this
                    will always return one item.
                #>
                $currentStatePermissionForState = $currentState.Permission |
                    Where-Object -FilterScript {
                        $_.State -eq $desiredExcludePermission.State
                    }

                $currentStatePermissionToExclude = [ServerPermission] @{
                    State      = $desiredExcludePermission.State
                    Permission = @()
                }

                foreach ($desiredExcludedPermissionName in $desiredExcludePermission.Permission)
                {
                    if ($currentStatePermissionForState.Permission -contains $desiredExcludedPermissionName)
                    {
                        Write-Verbose -Message (
                            $this.localizedData.DesiredAbsentPermissionArePresent -f @(
                                $desiredExcludedPermissionName
                            )
                        )
                    }
                    else
                    {
                        <#
                            If the permission does _not_ exist in the current state, add
                            the permission to $currentState.PermissionToExclude so that
                            the base class's method Compare() sees the property as being
                            in desired state (when the property PermissionToExclude in
                            the current state and desired state are equal).
                        #>
                        $currentStatePermissionToExclude.Permission += $desiredExcludedPermissionName
                    }
                }

                [ServerPermission[]] $currentState.PermissionToExclude += $currentStatePermissionToExclude
            }
        }

        return $currentState
    }

    <#
        Base method Set() call this method with the properties that should be
        enforced are not in desired state. It is not called if all properties
        are in desired state. The variable $properties contain the properties
        that are not in desired state.
    #>
    hidden [void] Modify([System.Collections.Hashtable] $properties)
    {
        $serverObject = $this.GetServerObject()

        $testSqlDscIsLoginParameters = @{
            ServerObject = $serverObject
            Name         = $this.Name
        }

        # This will test wether the principal exist.
        $isLogin = Test-SqlDscIsLogin @testSqlDscIsLoginParameters

        if (-not $isLogin)
        {
            $missingPrincipalMessage = $this.localizedData.NameIsMissing -f @(
                $this.Name,
                $this.InstanceName
            )

            New-InvalidOperationException -Message $missingPrincipalMessage
        }

        # This holds each state and their permissions to be revoked.
        [ServerPermission[]] $permissionsToRevoke = @()
        [ServerPermission[]] $permissionsToGrantOrDeny = @()

        if ($properties.ContainsKey('Permission'))
        {
            $keyProperty = $this | Get-DscProperty -Attribute 'Key'

            $currentState = $this.GetCurrentState($keyProperty)

            <#
                Evaluate if there are any permissions that should be revoked
                from the current state.
            #>
            foreach ($currentDesiredPermissionState in $properties.Permission)
            {
                $currentPermissionsForState = $currentState.Permission |
                    Where-Object -FilterScript {
                        $_.State -eq $currentDesiredPermissionState.State
                    }

                foreach ($permissionName in $currentPermissionsForState.Permission)
                {
                    if ($permissionName -notin $currentDesiredPermissionState.Permission)
                    {
                        # Look for an existing object in the array.
                        $updatePermissionToRevoke = $permissionsToRevoke |
                            Where-Object -FilterScript {
                                $_.State -eq $currentDesiredPermissionState.State
                            }

                        # Update the existing object in the array, or create a new object
                        if ($updatePermissionToRevoke)
                        {
                            $updatePermissionToRevoke.Permission += $permissionName
                        }
                        else
                        {
                            [ServerPermission[]] $permissionsToRevoke += [ServerPermission] @{
                                State      = $currentPermissionsForState.State
                                Permission = $permissionName
                            }
                        }
                    }
                }
            }

            <#
                At least one permission were missing or should have not be present
                in the current state. Grant or Deny all permission assigned to the
                property Permission regardless if they were already present or not.
            #>
            [ServerPermission[]] $permissionsToGrantOrDeny = $properties.Permission
        }

        if ($properties.ContainsKey('PermissionToExclude'))
        {
            <#
                At least one permission were present in the current state. Revoke
                all permission assigned to the property PermissionToExclude
                regardless if they were already revoked or not.
            #>
            [ServerPermission[]] $permissionsToRevoke = $properties.PermissionToExclude
        }

        if ($properties.ContainsKey('PermissionToInclude'))
        {
            <#
                At least one permission were missing or should have not be present
                in the current state. Grant or Deny all permission assigned to the
                property Permission regardless if they were already present or not.
            #>
            [ServerPermission[]] $permissionsToGrantOrDeny = $properties.PermissionToInclude
        }

        # Revoke all the permissions set in $permissionsToRevoke
        if ($permissionsToRevoke)
        {
            <#
                TODO: Could verify with $sqlServerObject.EnumServerPermissions($Principal, $desiredPermissionSet)
                      which permissions are not already revoked.
            #>
            foreach ($currentStateToRevoke in $permissionsToRevoke)
            {
                $revokePermissionSet = $currentStateToRevoke | ConvertFrom-SqlDscServerPermission

                $setSqlDscServerPermissionParameters = @{
                    ServerObject = $serverObject
                    Name         = $this.Name
                    Permission   = $revokePermissionSet
                    State        = 'Revoke'
                    Force        = $true
                }

                if ($currentStateToRevoke.State -eq 'GrantWithGrant')
                {
                    $setSqlDscServerPermissionParameters.WithGrant = $true
                }

                try
                {
                    Set-SqlDscServerPermission @setSqlDscServerPermissionParameters
                }
                catch
                {
                    $errorMessage = $this.localizedData.FailedToRevokePermissionFromCurrentState -f @(
                        $this.Name
                    )

                    New-InvalidOperationException -Message $errorMessage -ErrorRecord $_
                }
            }
        }

        if ($permissionsToGrantOrDeny)
        {
            <#
                TODO: Could verify with $sqlServerObject.EnumServerPermissions($Principal, $desiredPermissionSet)
                      which permissions are not already set.
            #>
            foreach ($currentDesiredPermissionState in $permissionsToGrantOrDeny)
            {
                # If there is not an empty array, change permissions.
                if (-not [System.String]::IsNullOrEmpty($currentDesiredPermissionState.Permission))
                {
                    $permissionSet = $currentDesiredPermissionState | ConvertFrom-SqlDscServerPermission

                    $setSqlDscServerPermissionParameters = @{
                        ServerObject = $serverObject
                        Name         = $this.Name
                        Permission   = $permissionSet
                        Force        = $true
                    }

                    try
                    {
                        switch ($currentDesiredPermissionState.State)
                        {
                            'GrantWithGrant'
                            {
                                Set-SqlDscServerPermission @setSqlDscServerPermissionParameters -State 'Grant' -WithGrant
                            }

                            default
                            {
                                Set-SqlDscServerPermission @setSqlDscServerPermissionParameters -State $currentDesiredPermissionState.State
                            }
                        }
                    }
                    catch
                    {
                        $errorMessage = $this.localizedData.FailedToSetPermission -f @(
                            $this.Name
                        )

                        New-InvalidOperationException -Message $errorMessage -ErrorRecord $_
                    }
                }
            }
        }
    }

    <#
        Base method Assert() call this method with the properties that was assigned
        a value.
    #>
    hidden [void] AssertProperties([System.Collections.Hashtable] $properties)
    {
        # PermissionToInclude and PermissionToExclude should be mutually exclusive from Permission
        $assertBoundParameterParameters = @{
            BoundParameterList     = $properties
            MutuallyExclusiveList1 = @(
                'Permission'
            )
            MutuallyExclusiveList2 = @(
                'PermissionToInclude'
                'PermissionToExclude'
            )
        }

        Assert-BoundParameter @assertBoundParameterParameters

        # Get all assigned permission properties.
        $assignedPermissionProperty = $properties.Keys.Where({
                $_ -in @(
                    'Permission',
                    'PermissionToInclude',
                    'PermissionToExclude'
                )
            })

        # Must include either of the permission properties.
        if ([System.String]::IsNullOrEmpty($assignedPermissionProperty))
        {
            $errorMessage = $this.localizedData.MustAssignOnePermissionProperty

            New-InvalidArgumentException -ArgumentName 'Permission, PermissionToInclude, PermissionToExclude' -Message $errorMessage
        }

        foreach ($currentAssignedPermissionProperty in $assignedPermissionProperty)
        {
            # One State cannot exist several times in the same resource instance.
            $permissionStateGroupCount = @(
                $properties.$currentAssignedPermissionProperty |
                    Group-Object -NoElement -Property 'State' -CaseSensitive:$false |
                    Select-Object -ExpandProperty 'Count'
            )

            if ($permissionStateGroupCount -gt 1)
            {
                $errorMessage = $this.localizedData.DuplicatePermissionState

                New-InvalidArgumentException -ArgumentName $currentAssignedPermissionProperty -Message $errorMessage
            }

            # A specific permission must only exist in one permission state.
            $permissionGroupCount = $properties.$currentAssignedPermissionProperty.Permission |
                Group-Object -NoElement -CaseSensitive:$false |
                Select-Object -ExpandProperty 'Count'

            if ($permissionGroupCount -gt 1)
            {
                $errorMessage = $this.localizedData.DuplicatePermissionBetweenState

                New-InvalidArgumentException -ArgumentName $currentAssignedPermissionProperty -Message $errorMessage
            }
        }

        if ($properties.Keys -contains 'Permission')
        {
            # Each State must exist once.
            $missingPermissionState = (
                $properties.Permission.State -notcontains 'Grant' -or
                $properties.Permission.State -notcontains 'GrantWithGrant' -or
                $properties.Permission.State -notcontains 'Deny'
            )

            if ($missingPermissionState)
            {
                $errorMessage = $this.localizedData.MissingPermissionState

                New-InvalidArgumentException -ArgumentName 'Permission' -Message $errorMessage
            }
        }

        <#
            Each permission state in the properties PermissionToInclude and PermissionToExclude
            must have specified at minimum one permission.
        #>
        foreach ($currentAssignedPermissionProperty in @('PermissionToInclude', 'PermissionToExclude'))
        {
            if ($properties.Keys -contains $currentAssignedPermissionProperty)
            {
                foreach ($currentServerPermission in $properties.$currentAssignedPermissionProperty)
                {
                    if ($currentServerPermission.Permission.Count -eq 0)
                    {
                        $errorMessage = $this.localizedData.MustHaveMinimumOnePermissionInState -f $currentAssignedPermissionProperty

                        New-InvalidArgumentException -ArgumentName $currentAssignedPermissionProperty -Message $errorMessage
                    }
                }
            }
        }
    }
}
#EndRegion '.\Classes\020.SqlPermission.ps1' 640
#Region '.\Classes\020.SqlRSSetup.ps1' -1

<#
    .SYNOPSIS
        The `SqlRSSetup` DSC resource is used to install, repair, or uninstall
        SQL Server Reporting Services (SSRS) or Power BI Report Server (PBIRS).

    .DESCRIPTION
        The `SqlRSSetup` DSC resource is used to install, repair, or uninstall
        SQL Server Reporting Services (SSRS) or Power BI Report Server (PBIRS).

        The built-in parameter **PSDscRunAsCredential** can be used to run the resource
        as another user. The resource will then install as that user, otherwise
        install as SYSTEM.

        >[!TIP]
        >To install Microsoft SQL Server Reporting Services 2016 (or older),
        >please use the resource SqlSetup instead.

        > [!IMPORTANT]
        > When using the action 'Uninstall' and the target node to begin with
        > requires a restart, on the first run the Microsoft SQL Server Reporting
        > Services instance will not be uninstalled, but instead exits with code
        > 3010 and the node will be, by default, restarted. On the second run after
        > restart, the Microsoft SQL Server Reporting Services instance will be
        > uninstalled. If the parameter SuppressRestart is used, then the node must
        > be restarted manually before the Microsoft SQL Server Reporting Services
        > instance will be successfully uninstalled.
        >
        > The Microsoft SQL Server Reporting Services log will indicate that a
        > restart is required by outputting; "*No action was taken as a system
        > reboot is required (0x8007015E)*". The log is default located in the
        > SSRS folder in `%TEMP%`, e.g. `C:\Users\<user>\AppData\Local\Temp\SSRS`.


        ## Requirements

        * Target machine must be running Windows Server 2012 or later.
        * Target machine must have access to the SQL Server Reporting Services or
          Power BI Report Server installation media.
        * SYSTEM account or the users passed in the credentials for the `PsDscRunAsCredential`
          common parameter must have permissions to connect to the location
          where the _Microsoft SQL Server Reporting Services_ or _Microsoft Power_
          _BI Report Server_ media is placed.
        * The parameter `AcceptLicensingTerms` must be set to `$true`.
        * The parameter `InstanceName` can only be set to `SSRS` or `PBIRS` since there
          is no way to change the instance name.

        ## Known issues

        * When using action 'Uninstall', the same version of the executable as the
          version of the installed product must be used. If not, sometimes the uninstall
          is successful (because the executable returns exit code 0) but the instance
          was not actually removed.

        All issues are not listed here, see [here for all open issues](https://github.com/dsccommunity/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlRSSetup).

    .PARAMETER InstanceName
        Specifies the instance name for the Reporting Services instance. This
        must be either `'SSRS'` for SQL Server Reporting Services or `'PBIRS'` for
        Power BI Report Server.

    .PARAMETER Action
        Specifies the action to take for the Reporting Services instance.
        This can be 'Install', 'Repair', or 'Uninstall'.

    .PARAMETER AcceptLicensingTerms
        Required parameter for Install and Repair actions to be able to run unattended.
        By specifying this parameter you acknowledge the acceptance of all license terms
        and notices for the specified features, the terms and notices that the setup
        executable normally asks for.

    .PARAMETER MediaPath
        Specifies the path where to find the SQL Server installation media. On this
        path the SQL Server setup executable must be found.

    .PARAMETER ProductKey
        Specifies the product key to use for the installation or repair, e.g.
        '12345-12345-12345-12345-12345'. This parameter is mutually exclusive with
        the parameter Edition.

    .PARAMETER EditionUpgrade
        Upgrades the edition of the installed product. Requires that either the
        ProductKey or the Edition parameter is also assigned. By default no edition
        upgrade is performed.

    .PARAMETER Edition
        Specifies a free custom edition to use for the installation or repair. This
        parameter is mutually exclusive with the parameter ProductKey.

    .PARAMETER LogPath
        Specifies the file path where to write the log files, e.g. 'C:\Logs\Install.log'.
        By default log files are created under %TEMP%.

    .PARAMETER InstallFolder
        Specifies the folder where to install the product, e.g. 'C:\Program Files\SSRS'.
        By default the product is installed under the default installation folder.

        Reporting Services: %ProgramFiles%\Microsoft SQL Server Reporting Services
        Power BI Report Server: %ProgramFiles%\Microsoft Power BI Report Server

    .PARAMETER SuppressRestart
        Suppresses the restart of the computer after the installation, repair, or
        uninstallation is finished. By default the computer is restarted after the
        operation is finished.

    .PARAMETER ForceRestart
        Forces a restart of the computer after the installation, repair, or
        uninstallation is finished, regardless of the operation's outcome. This
        parameter overrides SuppressRestart.

    .PARAMETER VersionUpgrade
        Specifies whether to upgrade the version of the installed product. By default,
        no version upgrade is performed.

        If this parameter is specified the installed product version will be compared
        against the product version of the setup executable. If the installed product
        version is lower than the product version of the setup executable, the setup
        will perform an upgrade. If the installed product version is equal to or higher
        than the product version of the setup executable, no upgrade will be performed.

    .PARAMETER Timeout
        Specifies how long to wait for the setup process to finish. Default value
        is `7200` seconds (2 hours). If the setup process does not finish before
        this time, an exception will be thrown.

    .NOTES
        The property InstanceName is the key property for this resource. It does
        not use a ValidateSet or Enum due to a limitation. A ValidateSet() or Enum
        would not allow a `$null` value to be set for the property. Setting
        a `$null` value is needed to be able to determine if the instance is
        installed or not. Due to this limitation the property is evaluated in
        the AssertProperties() method to have one of the valid values.

        Known issues:
        - Using `VersionUpgrade` with Microsoft SQL Server 2017 Reporting Services
          does not work because that version does not set a product version in the
          registry. So there is nothing to compare against the setup executable
          product version. It does set a current version, but that does not correlate
          to the product version. This apparently by design with Microsoft SQL Server
          2017 Reporting Services.

    .EXAMPLE
        Configuration Example
        {
            Import-DscResource -ModuleName SqlServerDsc

            Node localhost
            {
                SqlRSSetup 'InstallSSRS'
                {
                    InstanceName        = 'SSRS'
                    Action              = 'Install'
                    AcceptLicensingTerms = $true
                    MediaPath           = 'E:\SQLServerReportingServices.exe'
                    InstallFolder       = 'C:\Program Files\Microsoft SQL Server Reporting Services'
                    SuppressRestart     = $true
                }
            }
        }

        This example shows how to install SQL Server Reporting Services.
#>
[DscResource(RunAsCredential = 'Optional')]
class SqlRSSetup : ResourceBase
{
    [DscProperty(Key)]
    [System.String]
    $InstanceName

    [DscProperty(Mandatory)]
    [InstallAction]
    $Action

    [DscProperty(Mandatory)]
    [System.Boolean]
    $AcceptLicensingTerms

    [DscProperty(Mandatory)]
    [System.String]
    $MediaPath

    [DscProperty()]
    [System.String]
    $ProductKey

    [DscProperty()]
    [Nullable[System.Boolean]]
    $EditionUpgrade

    [DscProperty()]
    [ValidateSet('Developer', 'Evaluation', 'ExpressAdvanced')]
    [System.String]
    $Edition

    [DscProperty()]
    [System.String]
    $LogPath

    [DscProperty()]
    [System.String]
    $InstallFolder

    [DscProperty()]
    [Nullable[System.Boolean]]
    $SuppressRestart

    [DscProperty()]
    [Nullable[System.Boolean]]
    $ForceRestart

    [DscProperty()]
    [Nullable[System.Boolean]]
    $VersionUpgrade

    [DscProperty()]
    [ValidateRange(0, 2147483647)]
    [Nullable[System.UInt32]]
    $Timeout = 7200

    SqlRSSetup () : base ($PSScriptRoot)
    {
        # These properties will not be enforced.
        $this.ExcludeDscProperties = @(
            'Action'
            'AcceptLicensingTerms'
            'MediaPath'
            'ProductKey'
            'EditionUpgrade'
            'Edition'
            'LogPath'
            'InstallFolder'
            'SuppressRestart'
            'Timeout'
            'ForceRestart'
            'VersionUpgrade'
        )
    }

    [SqlRSSetup] Get()
    {
        # Call the base method to return the properties.
        return ([ResourceBase] $this).Get()
    }

    [System.Boolean] Test()
    {
        # Call the base method to test all of the properties that should be enforced.
        $baseTestResult = ([ResourceBase] $this).Test()

        # If $baseTestResult -eq $true, then the InstanceName exists.
        # If $baseTestResult -eq $false, then the InstanceName does not exist.

        $actionStateResult = $baseTestResult

        if ($this.Action -eq 'Repair' -and -not $baseTestResult)
        {
            # Instance is not installed, so it is not possible to perform a repair.
            $actionStateResult = $true
        }

        if ($this.Action -in @('Uninstall', 'Repair'))
        {
            if ($baseTestResult)
            {
                # Instance is installed, it should be uninstalled or repaired.
                $actionStateResult = $false
            }
            else
            {
                <#
                    Instance is not installed, or it is not possible to perform a
                    repair since the instance is uninstalled.
                #>
                $actionStateResult = $true
            }
        }

        $inDesiredState = $true

        <#
            The product version is evaluated if action is Install, instance is
            installed and VersionUpgrade is set to $true.
        #>
        if ($this.Action -eq 'Install' -and $baseTestResult)
        {
            if ($this.EditionUpgrade)
            {
                $currentState = Get-SqlDscRSSetupConfiguration -InstanceName $this.InstanceName

                if ([System.String]::IsNullOrEmpty($currentState.EditionId))
                {
                    New-InvalidResultException -Message (
                        $this.localizedData.CannotDetermineEdition -f $this.InstanceName
                    )
                }

                $currentEdition = ConvertTo-SqlDscEditionName -Id $currentState.EditionId

                if ($currentEdition.Edition -ne $this.Edition)
                {
                    $inDesiredState = $false

                    Write-Verbose -Message (
                        $this.localizedData.NotDesiredEdition -f @(
                            $currentEdition.Edition,
                            $this.InstanceName,
                            $this.Edition
                        )
                    )
                }
            }

            if ($this.VersionUpgrade)
            {
                $fileVersion = Get-FileProductVersion -Path $this.MediaPath -ErrorAction 'Stop'

                if ($fileVersion)
                {
                    $currentState = Get-SqlDscRSSetupConfiguration -InstanceName $this.InstanceName

                    if ([System.String]::IsNullOrEmpty($currentState.ProductVersion))
                    {
                        New-InvalidResultException -Message (
                            $this.localizedData.CannotDetermineProductVersion -f $this.InstanceName
                        )
                    }

                    $installedVersion = [System.Version] $currentState.ProductVersion

                    if ($installedVersion -lt $fileVersion)
                    {
                        $inDesiredState = $false

                        Write-Verbose -Message (
                            $this.localizedData.NotDesiredProductVersion -f @(
                                $fileVersion.ToString(),
                                $this.InstanceName,
                                $installedVersion.ToString()
                            )
                        )
                    }
                }
            }
        }

        return ($actionStateResult -and $inDesiredState)
    }

    [void] Set()
    {
        # Call the base method to enforce the properties.
        ([ResourceBase] $this).Set()
    }

    <#
        Base method Get() call this method to get the current state as a hashtable.
        The parameter properties will contain the key properties.
    #>
    hidden [System.Collections.Hashtable] GetCurrentState([System.Collections.Hashtable] $properties)
    {
        Write-Verbose -Message (
            $this.localizedData.Getting_Information_Instance -f @(
                $properties.InstanceName
            )
        )

        $currentState = @{
            # This must be set to the correct valid value for base method Get() to work.
            InstanceName  = $null
            InstallFolder = $null
        }

        # Get the configuration if installed
        $rsConfiguration = Get-SqlDscRSSetupConfiguration -InstanceName $properties.InstanceName

        if ($rsConfiguration)
        {
            # Instance is installed
            Write-Verbose -Message (
                $this.localizedData.Instance_Installed -f $properties.InstanceName
            )

            $currentState.InstanceName = $rsConfiguration.InstanceName
            $currentState.InstallFolder = $rsConfiguration.InstallFolder
        }
        else
        {
            # Instance is not installed
            Write-Verbose -Message (
                $this.localizedData.Instance_NotInstalled -f $properties.InstanceName
            )
        }

        return $currentState
    }

    <#
        Base method Set() call this method with the properties that are not in
        desired state and should be enforced. It is not called if all properties
        are in desired state. The variable $properties contains only the properties
        that are not in desired state.
    #>
    hidden [void] Modify([System.Collections.Hashtable] $properties)
    {
        $getDscPropertyParameters = @{
            HasValue    = $true
            Attribute   = @(
                'Optional'
                'Mandatory'
            )
            ExcludeName = @(
                # Remove mandatory property that is not a command parameter.
                'Action'

                # Remove optional property that is not a command parameter.
                'VersionUpgrade'
            )
        }

        # The command parameters are the same for all actions.
        if ($this.Action -eq 'Uninstall')
        {
            # Only retrieve properties that are needed for Uninstall
            $getDscPropertyParameters.Name = @(
                'MediaPath'
                'LogPath'
                'SuppressRestart'
                'Timeout'
            )
        }

        $commandParameters = $this |
            Get-DscProperty @getDscPropertyParameters

        $exitCode = $null

        # Switch based on the action to perform
        if ($this.InstanceName -eq 'SSRS')
        {
            switch ($this.Action)
            {
                'Install'
                {
                    Write-Verbose -Message $this.localizedData.Installing_ReportingServices

                    $exitCode = Install-SqlDscReportingService @commandParameters -PassThru -Force -ErrorAction 'Stop'

                    break
                }

                'Repair'
                {
                    Write-Verbose -Message $this.localizedData.Repairing_ReportingServices

                    $exitCode = Repair-SqlDscReportingService @commandParameters -PassThru -Force -ErrorAction 'Stop'

                    break
                }

                'Uninstall'
                {
                    Write-Verbose -Message $this.localizedData.Uninstalling_ReportingServices

                    $exitCode = Uninstall-SqlDscReportingService @commandParameters -PassThru -Force -ErrorAction 'Stop'

                    break
                }
            }
        }
        elseif ($this.InstanceName -eq 'PBIRS')
        {
            switch ($this.Action)
            {
                'Install'
                {
                    Write-Verbose -Message $this.localizedData.Installing_PowerBIReportServer

                    $exitCode = Install-SqlDscBIReportServer @commandParameters -PassThru -Force -ErrorAction 'Stop'

                    break
                }

                'Repair'
                {
                    Write-Verbose -Message $this.localizedData.Repairing_PowerBIReportServer

                    $exitCode = Repair-SqlDscBIReportServer @commandParameters -PassThru -Force -ErrorAction 'Stop'

                    break
                }

                'Uninstall'
                {
                    Write-Verbose -Message $this.localizedData.Uninstalling_PowerBIReportServer

                    $exitCode = Uninstall-SqlDscBIReportServer @commandParameters -PassThru -Force -ErrorAction 'Stop'

                    break
                }
            }
        }

        <#
            If ForceRestart is set it will always restart, and override SuppressRestart.
            If the exit code is 3010, then a restart is required.
        #>
        if ($this.ForceRestart -or ($exitCode -eq 3010 -and -not $this.SuppressRestart))
        {
            Set-DscMachineRebootRequired
        }
    }

    <#
        Base method Assert() call this method with the properties that was assigned
        a value.
    #>
    hidden [void] AssertProperties([System.Collections.Hashtable] $properties)
    {
        # TODO: Most or all of these checks are done in the Install, Uninstall or Repair-commands. We should remove them here if possible.

        # Verify that the instance name is valid.
        if ($properties.InstanceName -notin @('SSRS', 'PBIRS'))
        {
            New-ArgumentException -ArgumentName 'InstanceName' -Message ($this.localizedData.InstanceName_Invalid -f $properties.InstanceName)
        }

        # Verify that AcceptLicensingTerms is specified for Install and Repair actions.
        if ($properties.Action -in @('Install', 'Repair') -and -not $properties.AcceptLicensingTerms)
        {
            New-ArgumentException -ArgumentName 'AcceptLicensingTerms' -Message $this.localizedData.AcceptLicensingTerms_Required
        }

        # ProductKey and Edition are mutually exclusive.
        $assertBoundParameterParameters = @{
            BoundParameterList     = $properties
            MutuallyExclusiveList1 = @('ProductKey')
            MutuallyExclusiveList2 = @('Edition')
        }

        Assert-BoundParameter @assertBoundParameterParameters

        # Verify that MediaPath is valid.
        if (-not (Test-Path -Path $properties.MediaPath))
        {
            New-ArgumentException -ArgumentName 'MediaPath' -Message (
                $this.localizedData.MediaPath_Invalid -f $properties.MediaPath
            )
        }

        if ((Test-Path -Path $properties.MediaPath) -and (Get-Item -Path $properties.MediaPath).Extension -ne '.exe')
        {
            New-ArgumentException -ArgumentName 'MediaPath' -Message (
                $this.localizedData.MediaPath_DoesNotHaveRequiredExtension -f $properties.MediaPath
            )
        }

        # Must have specified either ProductKey or Edition.
        if ($properties.Action -eq 'Install' -and $properties.Keys -notcontains 'Edition' -and $properties.Keys -notcontains 'ProductKey')
        {
            New-ArgumentException -ArgumentName 'Edition, ProductKey' -Message $this.localizedData.EditionOrProductKeyMissing
        }

        # EditionUpgrade requires either ProductKey or Edition for Install and Repair actions.
        if ($properties.Action -in @('Repair') -and $properties.EditionUpgrade -and -not ($properties.ProductKey -or $properties.Edition))
        {
            New-ArgumentException -ArgumentName 'EditionUpgrade' -Message $this.localizedData.EditionUpgrade_RequiresKeyOrEdition
        }

        # LogPath validation if specified.
        if ($properties.Keys -contains 'LogPath')
        {
            # Verify that the log path parent directory exists.
            $logDirectory = Split-Path -Path $properties.LogPath -Parent

            if (-not (Test-Path -Path $logDirectory))
            {
                New-ArgumentException -ArgumentName 'LogPath' -Message (
                    $this.localizedData.LogPath_ParentMissing -f $logDirectory
                )
            }
        }

        # InstallFolder validation if specified for Install action.
        if ($properties.Action -eq 'Install' -and $properties.Keys -contains 'InstallFolder')
        {
            # Verify that the install folder parent directory exists.
            $installDirectory = Split-Path -Path $properties.InstallFolder -Parent

            if (-not (Test-Path -Path $installDirectory))
            {
                New-ArgumentException -ArgumentName 'InstallFolder' -Message (
                    $this.localizedData.InstallFolder_ParentMissing -f $installDirectory
                )
            }
        }
    }

    <#
        Base method Normalize() call this method with the properties that was assigned
        a value.
    #>
    hidden [void] NormalizeProperties([System.Collections.Hashtable] $properties)
    {
        $this.InstanceName = $properties.InstanceName.ToUpper()

        # Use array intersection for more efficient filtering
        $pathProperties = @(
            'MediaPath'
            'InstallFolder'
            'LogPath'
        ) |
            Where-Object {
                $properties.ContainsKey($_)
            }

        foreach ($property in $pathProperties)
        {
            $formatPathParameters = @{
                Path                         = $properties.$property
                EnsureDriveLetterRoot        = $true
                NoTrailingDirectorySeparator = $true
                ErrorAction                  = 'Stop'
            }

            # Normalize the property to lower case.
            $this.$property = Format-Path @formatPathParameters
        }
    }
}
#EndRegion '.\Classes\020.SqlRSSetup.ps1' 629
#Region '.\Private\Assert-Feature.ps1' -1

<#
    .SYNOPSIS
        Assert that a feature is supported by a Microsoft SQL Server major version.

    .DESCRIPTION
        Assert that a feature is supported by a Microsoft SQL Server major version.

    .PARAMETER Feature
       Specifies the feature to evaluate.

    .PARAMETER ProductVersion
       Specifies the product version of the Microsoft SQL Server. At minimum the
       major version must be provided.

    .EXAMPLE
        Assert-Feature -Feature 'RS' -ProductVersion '14'

        Throws an exception if the feature is not supported.

    .OUTPUTS
        None.
#>
function Assert-Feature
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.String[]]
        $Feature,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ProductVersion
    )

    process
    {
        foreach ($currentFeature in $Feature)
        {
            if (-not ($currentFeature | Test-SqlDscIsSupportedFeature -ProductVersion $ProductVersion))
            {
                $PSCmdlet.ThrowTerminatingError(
                    [System.Management.Automation.ErrorRecord]::new(
                        ($script:localizedData.Feature_Assert_NotSupportedFeature -f $currentFeature, $ProductVersion),
                        'AF0001', # cSpell: disable-line
                        [System.Management.Automation.ErrorCategory]::InvalidOperation,
                        $currentFeature
                    )
                )
            }
        }
    }
}
#EndRegion '.\Private\Assert-Feature.ps1' 55
#Region '.\Private\Assert-ManagedServiceType.ps1' -1

<#
    .SYNOPSIS
        Assert that a computer managed service is of a certain type.

    .DESCRIPTION
        Assert that a computer managed service is of a certain type. If it is the
        wrong type an exception is thrown.

    .PARAMETER ServiceObject
        Specifies the Service object to evaluate.

    .PARAMETER ServiceType
        Specifies the normalized service type to evaluate.

    .EXAMPLE
        $serviceObject = Get-SqlDscManagedComputerService -ServiceType 'DatabaseEngine'
        Assert-ManagedServiceType -ServiceObject $serviceObject -ServiceType 'DatabaseEngine'

        Asserts that the computer managed service object is of the type Database Engine.

    .EXAMPLE
        $serviceObject = Get-SqlDscManagedComputerService -ServiceType 'DatabaseEngine'
        $serviceObject | Assert-ManagedServiceType -ServiceType 'DatabaseEngine'

        Asserts that the computer managed service object is of the type Database Engine.

    .OUTPUTS
        None.
#>
function Assert-ManagedServiceType
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseSyntacticallyCorrectExamples', '', Justification = 'Because the rule does not yet support parsing the code when a parameter type is not available. The ScriptAnalyzer rule UseSyntacticallyCorrectExamples will always error in the editor due to https://github.com/indented-automation/Indented.ScriptAnalyzerRules/issues/8.')]
    [OutputType()]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Microsoft.SqlServer.Management.Smo.Wmi.Service]
        $ServiceObject,

        [Parameter(Mandatory = $true)]
        [ValidateSet('DatabaseEngine', 'SqlServerAgent', 'Search', 'IntegrationServices', 'AnalysisServices', 'ReportingServices', 'SQLServerBrowser', 'NotificationServices')]
        [System.String]
        $ServiceType
    )

    process
    {
        $normalizedServiceType = ConvertFrom-ManagedServiceType -ServiceType $ServiceObject.Type

        if ($normalizedServiceType -ne $ServiceType)
        {
            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new(
                    ($script:localizedData.ManagedServiceType_Assert_WrongServiceType -f $ServiceType, $normalizedServiceType),
                    'AMST0001', # cSpell: disable-line
                    [System.Management.Automation.ErrorCategory]::InvalidOperation,
                    $ServiceObject
                )
            )
        }
    }
}
#EndRegion '.\Private\Assert-ManagedServiceType.ps1' 64
#Region '.\Private\Assert-SetupActionProperties.ps1' -1

<#
    .SYNOPSIS
        Assert that the bound parameters are set as required

    .DESCRIPTION
        Assert that required parameters has been specified, and throws an exception if not.

    .PARAMETER Property
       A hashtable containing the parameters to evaluate. Normally this is set to
       $PSBoundParameters.

    .PARAMETER SetupAction
       A string value representing the setup action that is gonna be executed.

    .EXAMPLE
        Assert-SetupActionProperties -Property $PSBoundParameters -SetupAction 'Install'

        Throws an exception if the bound parameters are not in the correct state.

    .OUTPUTS
        None.

    .NOTES
        This function is used by the command Invoke-SetupAction to verify that
        the bound parameters are in the required state.
#>
function Assert-SetupActionProperties
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'The command uses plural noun to describe that it contain a collection of asserts.')]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $Property,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SetupAction
    )

    if ($Property.ContainsKey('Features'))
    {
        $setupExecutableFileVersion = $Property.MediaPath |
            Join-Path -ChildPath 'setup.exe' |
            Get-FileVersionInformation

        $Property.Features |
            Assert-Feature -ProductVersion $setupExecutableFileVersion.ProductVersion
    }

    # If one of the properties PBStartPortRange and PBEndPortRange are specified, then both must be specified.
    $assertParameters = @('PBStartPortRange', 'PBEndPortRange')

    $assertRequiredCommandParameterParameters = @{
        BoundParameterList = $Property
        RequiredParameter  = $assertParameters
        IfParameterPresent = $assertParameters
    }

    Assert-BoundParameter @assertRequiredCommandParameterParameters

    # The parameter UseSqlRecommendedMemoryLimits is mutually exclusive to SqlMinMemory and SqlMaxMemory.
    Assert-BoundParameter -BoundParameterList $Property -MutuallyExclusiveList1 @(
        'UseSqlRecommendedMemoryLimits'
    ) -MutuallyExclusiveList2 @(
        'SqlMinMemory'
        'SqlMaxMemory'
    )

    # If Role is set to SPI_AS_NewFarm then the specific parameters are required.
    if ($Property.ContainsKey('Role') -and $Property.Role -eq 'SPI_AS_NewFarm')
    {
        Assert-BoundParameter -BoundParameterList $Property -RequiredParameter @(
            'FarmAccount'
            'FarmPassword'
            'Passphrase'
            'FarmAdminiPort' # cspell: disable-line
        )
    }

    # If the parameter SecurityMode is set to 'SQL' then the parameter SAPwd is required.
    if ($Property.ContainsKey('SecurityMode') -and $Property.SecurityMode -eq 'SQL')
    {
        Assert-BoundParameter -BoundParameterList $Property -RequiredParameter @('SAPwd')
    }

    # If the parameter FileStreamLevel is set and is greater or equal to 2 then the parameter FileStreamShareName is required.
    if ($Property.ContainsKey('FileStreamLevel') -and $Property.FileStreamLevel -ge 2)
    {
        Assert-BoundParameter -BoundParameterList $Property -RequiredParameter @('FileStreamShareName')
    }

    # If a *SvcAccount is specified then the accompanying *SvcPassword must be set unless it is a (global) managed service account, virtual account, or a built-in account.
    $accountProperty = @(
        'PBEngSvcAccount'
        'PBDMSSvcAccount' # cSpell: disable-line
        'AgtSvcAccount'
        'ASSvcAccount'
        'FarmAccount'
        'SqlSvcAccount'
        'ISSvcAccount'
        'RSSvcAccount'
    )

    foreach ($currentAccountProperty in $accountProperty)
    {
        if ($currentAccountProperty -in $Property.Keys)
        {
            # If not (global) managed service account, virtual account, or a built-in account.
            if ((Test-AccountRequirePassword -Name $Property.$currentAccountProperty))
            {
                $assertPropertyName = $currentAccountProperty -replace 'Account', 'Password'

                Assert-BoundParameter -BoundParameterList $Property -RequiredParameter $assertPropertyName
            }
        }
    }

    # If feature AzureExtension is specified then the all the Azure* parameters must be set (except AzureArcProxy).
    if ($Property.ContainsKey('Features') -and $Property.Features -contains 'AZUREEXTENSION') # cSpell: disable-line
    {
        Assert-BoundParameter -BoundParameterList $Property -RequiredParameter @(
            'AzureSubscriptionId'
            'AzureResourceGroup'
            'AzureRegion'
            'AzureTenantId'
            'AzureServicePrincipal'
            'AzureServicePrincipalSecret'
            'ProductCoveredBySA'
        )
    }

    # If feature is SQLENGINE, then for specified setup actions the parameter AgtSvcAccount is mandatory.
    if ($SetupAction -in ('CompleteImage', 'InstallFailoverCluster', 'PrepareFailoverCluster', 'AddNode'))
    {
        if ($Property.ContainsKey('Features') -and $Property.Features -contains 'SQLENGINE')
        {
            Assert-BoundParameter -BoundParameterList $Property -RequiredParameter @('AgtSvcAccount')
        }
    }

    if ($SetupAction -in ('InstallFailoverCluster', 'PrepareFailoverCluster', 'AddNode'))
    {
        # The parameter ASSvcAccount is mandatory if feature AS is installed and setup action is InstallFailoverCluster, PrepareFailoverCluster, or AddNode.
        if ($Property.ContainsKey('Features') -and $Property.Features -contains 'AS')
        {
            Assert-BoundParameter -BoundParameterList $Property -RequiredParameter @('ASSvcAccount')
        }

        # The parameter SqlSvcAccount is mandatory if feature SQLENGINE is installed and setup action is InstallFailoverCluster, PrepareFailoverCluster, or AddNode.
        if ($Property.ContainsKey('Features') -and $Property.Features -contains 'SQLENGINE')
        {
            Assert-BoundParameter -BoundParameterList $Property -RequiredParameter @('SqlSvcAccount')
        }

        # The parameter ISSvcAccount is mandatory if feature IS is installed and setup action is InstallFailoverCluster, PrepareFailoverCluster, or AddNode.
        if ($Property.ContainsKey('Features') -and $Property.Features -contains 'IS')
        {
            Assert-BoundParameter -BoundParameterList $Property -RequiredParameter @('ISSvcAccount')
        }

        if ($Property.ContainsKey('Features') -and $Property.Features -contains 'RS')
        {
            Assert-BoundParameter -BoundParameterList $Property -RequiredParameter @('RSSvcAccount')
        }
    }

    # The ASServerMode value PowerPivot is not allowed when parameter set is InstallFailoverCluster or CompleteFailoverCluster.
    if ($SetupAction -in ('InstallFailoverCluster', 'CompleteFailoverCluster'))
    {
        if ($Property.ContainsKey('ASServerMode') -and $Property.ASServerMode -eq 'PowerPivot')
        {
            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new(
                    ($script:localizedData.InstallSqlServerProperties_ASServerModeInvalidValue -f $SetupAction),
                    'ASAP0001', # cSpell: disable-line
                    [System.Management.Automation.ErrorCategory]::InvalidOperation,
                    'Command parameters'
                )
            )
        }
    }

    # The ASServerMode value PowerPivot is not allowed when parameter set is InstallFailoverCluster or CompleteFailoverCluster.
    if ($SetupAction -in ('AddNode'))
    {
        if ($Property.ContainsKey('RsInstallMode') -and $Property.RsInstallMode -ne 'FilesOnlyMode')
        {
            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new(
                    ($script:localizedData.InstallSqlServerProperties_RsInstallModeInvalidValue -f $SetupAction),
                    'ASAP0002', # cSpell: disable-line
                    [System.Management.Automation.ErrorCategory]::InvalidOperation,
                    'Command parameters'
                )
            )
        }
    }

    if ($SetupAction -in ('Install'))
    {
        if ($Property.ContainsKey('Features') -and $Property.Features -contains 'SQLENGINE')
        {
            Assert-BoundParameter -BoundParameterList $Property -RequiredParameter @(
                'SqlSysAdminAccounts'
            )
        }

        if ($Property.ContainsKey('Features') -and $Property.Features -contains 'AS')
        {
            Assert-BoundParameter -BoundParameterList $Property -RequiredParameter @(
                'ASSysAdminAccounts'
            )
        }
    }
}
#EndRegion '.\Private\Assert-SetupActionProperties.ps1' 218
#Region '.\Private\ConvertFrom-ManagedServiceType.ps1' -1

<#
    .SYNOPSIS
        Converts a managed service type name to a normalized service type name.

    .DESCRIPTION
        Converts a managed service type name to its normalized service type name
        equivalent.

    .PARAMETER ServiceType
        Specifies the managed service type to convert to the correct normalized
        service type name.

    .EXAMPLE
        ConvertFrom-ManagedServiceType -ServiceType 'SqlServer'

        Returns the normalized service type name 'DatabaseEngine' .
#>
function ConvertFrom-ManagedServiceType
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseSyntacticallyCorrectExamples', '', Justification = 'Because the rule does not yet support parsing the code when a parameter type is not available. The ScriptAnalyzer rule UseSyntacticallyCorrectExamples will always error in the editor due to https://github.com/indented-automation/Indented.ScriptAnalyzerRules/issues/8.')]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Microsoft.SqlServer.Management.Smo.Wmi.ManagedServiceType]
        $ServiceType
    )

    process
    {
        # Map the normalized service type to a valid value from the managed service type.
        switch ($ServiceType)
        {
            'SqlServer'
            {
                $serviceTypeValue = 'DatabaseEngine'

                break
            }

            'SqlAgent'
            {
                $serviceTypeValue = 'SqlServerAgent'

                break
            }

            'Search'
            {
                $serviceTypeValue = 'Search'

                break
            }

            'SqlServerIntegrationService'
            {
                $serviceTypeValue = 'IntegrationServices'

                break
            }

            'AnalysisServer'
            {
                $serviceTypeValue = 'AnalysisServices'

                break
            }

            'ReportServer'
            {
                $serviceTypeValue = 'ReportingServices'

                break
            }

            'SqlBrowser'
            {
                $serviceTypeValue = 'SQLServerBrowser'

                break
            }

            'NotificationServer'
            {
                $serviceTypeValue = 'NotificationServices'

                break
            }

            default
            {
                <#
                    This catches any future values in the enum ManagedServiceType
                    that are not yet supported.
                #>
                $writeErrorParameters = @{
                    Message      = $script:localizedData.ManagedServiceType_ConvertFrom_UnknownServiceType -f $ServiceType
                    Category     = 'InvalidOperation'
                    ErrorId      = 'CFMST0001' # CSpell: disable-line
                    TargetObject = $ServiceType
                }

                Write-Error @writeErrorParameters

                break
            }
        }

        return $serviceTypeValue
    }
}
#EndRegion '.\Private\ConvertFrom-ManagedServiceType.ps1' 112
#Region '.\Private\ConvertTo-ManagedServiceType.ps1' -1

<#
    .SYNOPSIS
        Converts a normalized service type name to a managed service type name.

    .DESCRIPTION
        Converts a normalized service type name to its managed service type name
        equivalent.

    .PARAMETER ServiceType
        Specifies the normalized service type to convert to the correct manged
        service type.

    .EXAMPLE
        ConvertTo-ManagedServiceType -ServiceType 'DatabaseEngine'

        Returns the manged service type name for the normalized service type 'DatabaseEngine'.
#>
function ConvertTo-ManagedServiceType
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateSet('DatabaseEngine', 'SqlServerAgent', 'Search', 'IntegrationServices', 'AnalysisServices', 'ReportingServices', 'SQLServerBrowser', 'NotificationServices')]
        [System.String]
        $ServiceType
    )

    process
    {
        # Map the normalized service type to a valid value from the managed service type.
        switch ($ServiceType)
        {
            'DatabaseEngine'
            {
                $serviceTypeValue = 'SqlServer'

                break
            }

            'SqlServerAgent'
            {
                $serviceTypeValue = 'SqlAgent'

                break
            }

            'Search'
            {
                $serviceTypeValue = 'Search'

                break
            }

            'IntegrationServices'
            {
                $serviceTypeValue = 'SqlServerIntegrationService'

                break
            }

            'AnalysisServices'
            {
                $serviceTypeValue = 'AnalysisServer'

                break
            }

            'ReportingServices'
            {
                $serviceTypeValue = 'ReportServer'

                break
            }

            'SQLServerBrowser'
            {
                $serviceTypeValue = 'SqlBrowser'

                break
            }

            'NotificationServices'
            {
                $serviceTypeValue = 'NotificationServer'

                break
            }
        }

        return $serviceTypeValue -as [Microsoft.SqlServer.Management.Smo.Wmi.ManagedServiceType]
    }
}
#EndRegion '.\Private\ConvertTo-ManagedServiceType.ps1' 94
#Region '.\Private\ConvertTo-RedactedText.ps1' -1

<#
    .SYNOPSIS
        Redacts a text from one or more specified phrases.

    .DESCRIPTION
        Redacts a text using best effort from one or more specified phrases. For
        it to work the sensitiv phrases must be known and passed into the parameter
        RedactText. If any single character in a phrase is wrong the sensitiv
        information will not be redacted. The redaction is case-insensitive.

    .PARAMETER Text
        Specifies the text that will be redacted.

    .PARAMETER RedactPhrase
        Specifies one or more phrases to redact from the text. Text strings will
        be escaped so they will not be interpreted as regular expressions (RegEx).

    .PARAMETER RedactWith
        Specifies a phrase that will be used as redaction.

    .EXAMPLE
        ConvertTo-RedactedText -Text 'My secret phrase: secret123' -RedactPhrase 'secret123'

        Returns the text with the phrases redacted with the default redaction phrase.

    .EXAMPLE
        ConvertTo-RedactedText -Text 'My secret phrase: secret123' -RedactPhrase 'secret123' -RedactWith '----'

        Returns the text with the phrases redacted to '----'.
#>
function ConvertTo-RedactedText
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.String]
        $Text,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $RedactPhrase,

        [Parameter()]
        [System.String]
        $RedactWith = '*******'
    )

    process
    {
        $redactedText = $Text

        foreach ($redactString in $RedactPhrase)
        {
            <#
                Escaping the string to handle strings which could look like
                regular expressions, like passwords.
            #>
            $escapedRedactedString = [System.Text.RegularExpressions.Regex]::Escape($redactString)

            $redactedText = $redactedText -ireplace $escapedRedactedString, $RedactWith # cSpell: ignore ireplace
        }

        return $redactedText
    }
}
#EndRegion '.\Private\ConvertTo-RedactedText.ps1' 67
#Region '.\Private\Get-FileVersionInformation.ps1' -1

<#
    .SYNOPSIS
        Returns the version information for a file.

    .DESCRIPTION
        Returns the version information for a file.

    .PARAMETER FilePath
        Specifies the file for which to return the version information.

    .EXAMPLE
        Get-FileVersionInformation -FilePath 'E:\setup.exe'

        Returns the version information for the file setup.exe.

    .EXAMPLE
        Get-FileVersionInformation -FilePath (Get-Item -Path 'E:\setup.exe')

        Returns the version information for the file setup.exe.

    .OUTPUTS
        [System.String]
#>
function Get-FileVersionInformation
{
    [OutputType([System.Diagnostics.FileVersionInfo])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.IO.FileInfo]
        $FilePath
    )

    process
    {
        $file = Get-Item -Path $FilePath -ErrorAction 'Stop'

        if ($file.PSIsContainer)
        {
            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new(
                    $script:localizedData.FileVersionInformation_Get_FilePathIsNotFile,
                    'GFPVI0001', # cSpell: disable-line
                    [System.Management.Automation.ErrorCategory]::InvalidArgument,
                    $file.FullName
                )
            )
        }

        return $file.VersionInfo
    }
}
#EndRegion '.\Private\Get-FileVersionInformation.ps1' 54
#Region '.\Private\Get-SMOModuleCalculatedVersion.ps1' -1

<#
    .SYNOPSIS
        Returns the calculated version of an SMO PowerShell module.

    .DESCRIPTION
        Returns the calculated version of an SMO PowerShell module.

        For SQLServer, the version is calculated using the System.Version
        field with '-preview' appended for pre-release versions . For
        example: 21.1.1 or 22.0.49-preview

        For SQLPS, the version is calculated using the path of the module. For
        example:
        C:\Program Files (x86)\Microsoft SQL Server\130\Tools\PowerShell\Modules
        returns 130

    .PARAMETER PSModuleInfo
        Specifies the PSModuleInfo object for which to return the calculated version.

    .EXAMPLE
        Get-SMOModuleCalculatedVersion -PSModuleInfo (Get-Module -Name 'sqlps')

        Returns the calculated version as a string.

    .OUTPUTS
        [System.String]
#>
function Get-SMOModuleCalculatedVersion
{
    [OutputType([System.String])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Management.Automation.PSModuleInfo]
        $PSModuleInfo
    )

    process
    {
        $version = $null

        if ($PSModuleInfo.Name -eq 'SQLPS')
        {
            <#
                Parse the build version number '120', '130' from the Path.
                Older version of SQLPS did not have correct versioning.
            #>
            $version = $PSModuleInfo.Path -replace '.*\\(\d{2})(\d)\\.*', '$1.$2'
        }
        else
        {
            $version = $PSModuleInfo.Version.ToString()

            if ($PSModuleInfo.PrivateData.PSData.Prerelease)
            {
                $version = '{0}-{1}' -f $PSModuleInfo.Version, $PSModuleInfo.PrivateData.PSData.Prerelease
            }
        }

        return $version
    }
}
#EndRegion '.\Private\Get-SMOModuleCalculatedVersion.ps1' 64
#Region '.\Private\Invoke-ReportServerSetupAction.ps1' -1

<#
    .SYNOPSIS
        Executes setup using the provided setup executable.

    .DESCRIPTION
        Executes Reporting Services or BI Report Server setup using the provided setup executable.

        See the link in the commands help for information on each parameter.

    .PARAMETER Install
        Specifies that a new installation should be performed.

    .PARAMETER Uninstall
        Specifies that an uninstallation should be performed.

    .PARAMETER Repair
        Specifies that a repair should be performed on an existing installation.

    .PARAMETER AcceptLicensingTerms
        Required parameter to be able to run unattended install. By specifying this
        parameter you acknowledge the acceptance of all license terms and notices for
        the specified features, the terms and notices that the setup executable
        normally asks for.

    .PARAMETER MediaPath
        Specifies the path where to find the SQL Server installation media. On this
        path the SQL Server setup executable must be found.

    .PARAMETER ProductKey
        Specifies the product key to use for the installation, e.g. '12345-12345-12345-12345-12345'.
        This parameter is mutually exclusive with the parameter Edition.

    .PARAMETER EditionUpgrade
        Upgrades the edition of the installed product. Requires that either the
        ProductKey or the Edition parameter is also assigned. By default no edition
        upgrade is performed.

    .PARAMETER Edition
        Specifies a free custom edition to use for the installation. This parameter
        is mutually exclusive with the parameter ProductKey.

    .PARAMETER LogPath
        Specifies the file path where to write the log files, e.g. 'C:\Logs\Install.log'.
        By default log files are created under %TEMP%.

    .PARAMETER InstallFolder
        Specifies the folder where to install the product, e.g. 'C:\Program Files\SSRS'.
        By default the product is installed under the default installation folder.

        Reporting Services: %ProgramFiles%\Microsoft SQL Server Reporting Services
        PI Report Server: %ProgramFiles%\Microsoft Power BI Report Server

    .PARAMETER SuppressRestart
        Suppresses the restart of the computer after the installation is finished.
        By default the computer is restarted after the installation is finished.

    .PARAMETER Timeout
        Specifies how long to wait for the setup process to finish. Default value
        is `7200` seconds (2 hours). If the setup process does not finish before
        this time, an exception will be thrown.

    .PARAMETER Force
        If specified the command will not ask for confirmation. Same as if Confirm:$false
        is used.

    .PARAMETER PassThru
        If specified the command will return the setup process exit code.

    .LINK
        https://learn.microsoft.com/en-us/power-bi/report-server/install-report-server
        https://learn.microsoft.com/en-us/sql/reporting-services/install-windows/install-reporting-services

    .OUTPUTS
        When PassThru is specified the function will return the setup process exit
        code as System.Int32. Otherwise, the function does not generate any output.

    .EXAMPLE
        Invoke-ReportServerSetupAction -Install -AcceptLicensingTerms -MediaPath 'E:\SQLServerReportingServices.exe'

        Installs SQL Server Reporting Services with default settings.

    .EXAMPLE
        Invoke-ReportServerSetupAction -Install -AcceptLicensingTerms -MediaPath 'E:\SQLServerReportingServices.exe' -ProductKey '12345-12345-12345-12345-12345'

        Installs SQL Server Reporting Services using a product key.

    .EXAMPLE
        Invoke-ReportServerSetupAction -Install -AcceptLicensingTerms -MediaPath 'E:\PowerBIReportServer.exe' -Edition 'Evaluation' -InstallFolder 'C:\Program Files\Power BI Report Server'

        Installs Power BI Report Server in evaluation edition to a custom folder.

    .EXAMPLE
        Invoke-ReportServerSetupAction -Install -AcceptLicensingTerms -MediaPath 'E:\SQLServerReportingServices.exe' -ProductKey '12345-12345-12345-12345-12345' -EditionUpgrade -LogPath 'C:\Logs\SSRS_Install.log'

        Installs SQL Server Reporting Services and upgrades the edition using a product key. Also specifies a custom log path.

    .EXAMPLE
        Invoke-ReportServerSetupAction -Repair -AcceptLicensingTerms -MediaPath 'E:\SQLServerReportingServices.exe'

        Repairs an existing installation of SQL Server Reporting Services.

    .EXAMPLE
        Invoke-ReportServerSetupAction -Uninstall -MediaPath 'E:\SQLServerReportingServices.exe' -Force

        Uninstalls SQL Server Reporting Services without prompting for confirmation.

    .EXAMPLE
        $exitCode = Invoke-ReportServerSetupAction -Install -AcceptLicensingTerms -MediaPath 'E:\SQLServerReportingServices.exe' -PassThru

        Installs SQL Server Reporting Services and returns the setup process exit code.
#>
function Invoke-ReportServerSetupAction
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([System.Int32])]
    param
    (
        [Parameter(ParameterSetName = 'Install', Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $Install,

        [Parameter(ParameterSetName = 'Uninstall', Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $Uninstall,

        [Parameter(ParameterSetName = 'Repair', Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $Repair,

        [Parameter(ParameterSetName = 'Install', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Repair', Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $AcceptLicensingTerms,

        [Parameter(Mandatory = $true)]
        [ValidateScript({
                if (-not (Test-Path -Path $_ -PathType 'Leaf'))
                {
                    throw $script:localizedData.ReportServerSetupAction_ReportServerExecutableNotFound
                }

                return $true
            })]
        [System.String]
        $MediaPath,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'Repair')]
        [System.String]
        $ProductKey,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'Repair')]
        [System.Management.Automation.SwitchParameter]
        $EditionUpgrade,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'Repair')]
        [ValidateSet('Developer', 'Evaluation', 'ExpressAdvanced')]
        [System.String]
        $Edition,

        [Parameter()]
        [System.String]
        $LogPath,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'Repair')]
        [ValidateScript({
                $parentInstallFolder = Split-Path -Path $_ -Parent

                if (-not (Test-Path -Path $parentInstallFolder))
                {
                    throw $script:localizedData.ReportServerSetupAction_InstallFolderNotFound
                }

                return $true
            })]
        [System.String]
        $InstallFolder,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $SuppressRestart,

        [Parameter()]
        [System.UInt32]
        $Timeout = 7200,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $PassThru
    )

    if ($Force.IsPresent -and -not $Confirm)
    {
        $ConfirmPreference = 'None'
    }

    Assert-ElevatedUser -ErrorAction 'Stop'

    $assertBoundParameters = @{
        BoundParameterList     = $PSBoundParameters
        MutuallyExclusiveList1 = @(
            'Edition'
        )
        MutuallyExclusiveList2 = @(
            'ProductKey'
        )
    }

    # Either ProductKey or Edition must be specified, never both.
    Assert-BoundParameter @assertBoundParameters

    # If EditionUpgrade is specified then the parameter ProductKey or Edition must be specified.
    $assertBoundParameters = @{
        BoundParameterList = $PSBoundParameters
        IfParameterPresent = @('EditionUpgrade')
        RequiredParameter  = ('ProductKey', 'Edition')
        RequiredBehavior   = 'Any'
    }

    Assert-BoundParameter @assertBoundParameters

    # Sensitive values.
    $sensitiveValue = @()

    # Default action is install or upgrade.
    $setupArgument = '/quiet /IAcceptLicenseTerms'

    if ($Uninstall.IsPresent)
    {
        $setupArgument += ' /uninstall'
    }
    elseif ($Repair.IsPresent)
    {
        $setupArgument += ' /repair'
    }

    if ($ProductKey)
    {
        $setupArgument += ' /PID={0}' -f $ProductKey

        $sensitiveValue += @(
            $ProductKey
        )
    }

    if ($EditionUpgrade.IsPresent)
    {
        $setupArgument += ' /EditionUpgrade'
    }

    if ($Edition)
    {
        $editionMap = @{
            Developer       = 'Dev'
            Evaluation      = 'Eval'
            ExpressAdvanced = 'ExprAdv'
        }

        $setupArgument += ' /Edition={0}' -f $editionMap.$Edition
    }

    if ($LogPath)
    {
        $setupArgument += ' /log "{0}"' -f $LogPath
    }

    if ($InstallFolder)
    {
        $setupArgument += ' /InstallFolder="{0}"' -f $InstallFolder
    }

    if ($SuppressRestart.IsPresent)
    {
        $setupArgument += ' /norestart'
    }

    $verboseSetupArgument = $setupArgument

    # Obfuscate sensitive values.
    foreach ($currentSensitiveValue in $sensitiveValue)
    {
        $escapedRegExString = [System.Text.RegularExpressions.Regex]::Escape($currentSensitiveValue)

        $verboseSetupArgument = $verboseSetupArgument -replace $escapedRegExString, '********'
    }

    # Clear sensitive values.
    $sensitiveValue = $null

    Write-Verbose -Message ($script:localizedData.ReportServerSetupAction_SetupArguments -f $verboseSetupArgument)

    $verboseDescriptionMessage = $script:localizedData.ReportServerSetupAction_ShouldProcessVerboseDescription -f $PSCmdlet.ParameterSetName
    $verboseWarningMessage = $script:localizedData.ReportServerSetupAction_ShouldProcessVerboseWarning -f $PSCmdlet.ParameterSetName
    $captionMessage = $script:localizedData.ReportServerSetupAction_ShouldProcessCaption

    if ($PSCmdlet.ShouldProcess($verboseDescriptionMessage, $verboseWarningMessage, $captionMessage))
    {
        $expandedMediaPath = [System.Environment]::ExpandEnvironmentVariables($MediaPath)

        $startProcessParameters = @{
            FilePath     = $expandedMediaPath
            ArgumentList = $setupArgument
            Timeout      = $Timeout
        }

        # Clear setupArgument to remove any sensitive values.
        $setupArgument = $null

        # Run setup executable.
        $processExitCode = Start-SqlSetupProcess @startProcessParameters

        $setupExitMessage = ($script:localizedData.SetupAction_SetupExitMessage -f $processExitCode)

        if ($processExitCode -eq 3010)
        {
            Write-Warning -Message (
                '{0} {1}' -f $setupExitMessage, $script:localizedData.SetupAction_SetupSuccessfulRebootRequired
            )
        }
        elseif ($processExitCode -ne 0)
        {
            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new(
                    $setupExitMessage,
                    'IRS0001', # cspell: disable-line
                    [System.Management.Automation.ErrorCategory]::InvalidOperation,
                    $PSCmdlet.ParameterSetName
                )
            )
        }
        else
        {
            Write-Verbose -Message (
                '{0} {1}' -f $setupExitMessage, ($script:localizedData.SetupAction_SetupSuccessful)
            )
        }

        if ($PassThru.IsPresent)
        {
            return $processExitCode
        }
    }
}
#EndRegion '.\Private\Invoke-ReportServerSetupAction.ps1' 351
#Region '.\Private\Invoke-SetupAction.ps1' -1

<#
    .SYNOPSIS
        Executes an setup action using Microsoft SQL Server setup executable.

    .DESCRIPTION
        Executes an setup action using Microsoft SQL Server setup executable.

        See the link in the commands help for information on each parameter. The
        link points to SQL Server command line setup documentation.

    .PARAMETER Install
        Specifies the setup action Install.

    .PARAMETER Uninstall
        Specifies the setup action Uninstall.

    .PARAMETER PrepareImage
        Specifies the setup action PrepareImage.

    .PARAMETER CompleteImage
        Specifies the setup action CompleteImage.

    .PARAMETER Upgrade
        Specifies the setup action Upgrade.

    .PARAMETER EditionUpgrade
        Specifies the setup action EditionUpgrade.

    .PARAMETER Repair
        Specifies the setup action Repair.

    .PARAMETER RebuildDatabase
        Specifies the setup action RebuildDatabase.

    .PARAMETER InstallFailoverCluster
        Specifies the setup action InstallFailoverCluster.

    .PARAMETER PrepareFailoverCluster
        Specifies the setup action PrepareFailoverCluster.

    .PARAMETER CompleteFailoverCluster
        Specifies the setup action CompleteFailoverCluster.

    .PARAMETER AddNode
        Specifies the setup action AddNode.

    .PARAMETER RemoveNode
        Specifies the setup action RemoveNode.

    .PARAMETER ConfigurationFile
        Specifies an configuration file to use during SQL Server setup. This
        parameter cannot be used together with any of the setup actions, but instead
        it is expected that the configuration file specifies what setup action to
        run.

    .PARAMETER AcceptLicensingTerms
        Required parameter to be able to run unattended install. By specifying this
        parameter you acknowledge the acceptance of all license terms and notices for
        the specified features, the terms and notices that the Microsoft SQL Server
        setup executable normally asks for.

    .PARAMETER MediaPath
        Specifies the path where to find the SQL Server installation media. On this
        path the SQL Server setup executable must be found.

    .PARAMETER Timeout
        Specifies how long to wait for the setup process to finish. Default value
        is `7200` seconds (2 hours). If the setup process does not finish before
        this time, an exception will be thrown.

    .PARAMETER Force
        If specified the command will not ask for confirmation. Same as if Confirm:$false
        is used.

    .PARAMETER SuppressPrivacyStatementNotice
        See the notes section for more information.

    .PARAMETER IAcknowledgeEntCalLimits
        See the notes section for more information.

    .PARAMETER InstanceName
        See the notes section for more information.

    .PARAMETER Enu
        See the notes section for more information.

    .PARAMETER UpdateEnabled
        See the notes section for more information.

    .PARAMETER UpdateSource
        See the notes section for more information.

    .PARAMETER Features
        See the notes section for more information.

    .PARAMETER Role
        See the notes section for more information.

    .PARAMETER InstallSharedDir
        See the notes section for more information.

    .PARAMETER InstallSharedWowDir
        See the notes section for more information.

    .PARAMETER InstanceDir
        See the notes section for more information.

    .PARAMETER InstanceId
        See the notes section for more information.

    .PARAMETER PBEngSvcAccount
        See the notes section for more information.

    .PARAMETER PBEngSvcPassword
        See the notes section for more information.

    .PARAMETER PBEngSvcStartupType
        See the notes section for more information.

    .PARAMETER PBDMSSvcAccount
        See the notes section for more information.

    .PARAMETER PBDMSSvcPassword
        See the notes section for more information.

    .PARAMETER PBDMSSvcStartupType
        See the notes section for more information.

    .PARAMETER PBStartPortRange
        See the notes section for more information.

    .PARAMETER PBEndPortRange
        See the notes section for more information.

    .PARAMETER PBScaleOut
        See the notes section for more information.

    .PARAMETER ProductKey
        See the notes section for more information.

    .PARAMETER AgtSvcAccount
        See the notes section for more information.

    .PARAMETER AgtSvcPassword
        See the notes section for more information.

    .PARAMETER AgtSvcStartupType
        See the notes section for more information.

    .PARAMETER ASBackupDir
        See the notes section for more information.

    .PARAMETER ASCollation
        See the notes section for more information.

    .PARAMETER ASConfigDir
        See the notes section for more information.

    .PARAMETER ASDataDir
        See the notes section for more information.

    .PARAMETER ASLogDir
        See the notes section for more information.

    .PARAMETER ASTempDir
        See the notes section for more information.

    .PARAMETER ASServerMode
        See the notes section for more information.

    .PARAMETER ASSvcAccount
        See the notes section for more information.

    .PARAMETER ASSvcPassword
        See the notes section for more information.

    .PARAMETER ASSvcStartupType
        See the notes section for more information.

    .PARAMETER ASSysAdminAccounts
        See the notes section for more information.

    .PARAMETER ASProviderMSOLAP
        See the notes section for more information.

    .PARAMETER FarmAccount
        See the notes section for more information.

    .PARAMETER FarmPassword
        See the notes section for more information.

    .PARAMETER Passphrase
        See the notes section for more information.

    .PARAMETER FarmAdminiPort
        See the notes section for more information.

    .PARAMETER BrowserSvcStartupType
        See the notes section for more information.

    .PARAMETER FTUpgradeOption
        See the notes section for more information.

    .PARAMETER EnableRanU
        See the notes section for more information.

    .PARAMETER InstallSqlDataDir
        See the notes section for more information.

    .PARAMETER SqlBackupDir
        See the notes section for more information.

    .PARAMETER SecurityMode
        See the notes section for more information.

    .PARAMETER SAPwd
        See the notes section for more information.

    .PARAMETER SqlCollation
        See the notes section for more information.

    .PARAMETER AddCurrentUserAsSqlAdmin
        See the notes section for more information.

    .PARAMETER SqlSvcAccount
        See the notes section for more information.

    .PARAMETER SqlSvcPassword
        See the notes section for more information.

    .PARAMETER SqlSvcStartupType
        See the notes section for more information.

    .PARAMETER SqlSysAdminAccounts
        See the notes section for more information.

    .PARAMETER SqlTempDbDir
        See the notes section for more information.

    .PARAMETER SqlTempDbLogDir
        See the notes section for more information.

    .PARAMETER SqlTempDbFileCount
        See the notes section for more information.

    .PARAMETER SqlTempDbFileSize
        See the notes section for more information.

    .PARAMETER SqlTempDbFileGrowth
        See the notes section for more information.

    .PARAMETER SqlTempDbLogFileSize
        See the notes section for more information.

    .PARAMETER SqlTempDbLogFileGrowth
        See the notes section for more information.

    .PARAMETER SqlUserDbDir
        See the notes section for more information.

    .PARAMETER SqlSvcInstantFileInit
        See the notes section for more information.

    .PARAMETER SqlUserDbLogDir
        See the notes section for more information.

    .PARAMETER SqlMaxDop
        See the notes section for more information.

    .PARAMETER UseSqlRecommendedMemoryLimits
        See the notes section for more information.

    .PARAMETER SqlMinMemory
        See the notes section for more information.

    .PARAMETER SqlMaxMemory
        See the notes section for more information.

    .PARAMETER FileStreamLevel
        See the notes section for more information.

    .PARAMETER FileStreamShareName
        See the notes section for more information.

    .PARAMETER ISSvcAccount
        See the notes section for more information.

    .PARAMETER ISSvcPassword
        See the notes section for more information.

    .PARAMETER ISSvcStartupType
        See the notes section for more information.

    .PARAMETER AllowUpgradeForSSRSSharePointMode
        See the notes section for more information.

    .PARAMETER NpEnabled
        See the notes section for more information.

    .PARAMETER TcpEnabled
        See the notes section for more information.

    .PARAMETER RsInstallMode
        See the notes section for more information.

    .PARAMETER RSSvcAccount
        See the notes section for more information.

    .PARAMETER RSSvcPassword
        See the notes section for more information.

    .PARAMETER RSSvcStartupType
        See the notes section for more information.

    .PARAMETER MPYCacheDirectory
        See the notes section for more information.

    .PARAMETER MRCacheDirectory
        See the notes section for more information.

    .PARAMETER SqlInstJava
        See the notes section for more information.

    .PARAMETER SqlJavaDir
        See the notes section for more information.

    .PARAMETER FailoverClusterGroup
        See the notes section for more information.

    .PARAMETER FailoverClusterDisks
        See the notes section for more information.

    .PARAMETER FailoverClusterNetworkName
        See the notes section for more information.

    .PARAMETER FailoverClusterIPAddresses
        See the notes section for more information.

    .PARAMETER ConfirmIPDependencyChange
        See the notes section for more information.

    .PARAMETER FailoverClusterRollOwnership
        See the notes section for more information.

    .PARAMETER AzureSubscriptionId
        See the notes section for more information.

    .PARAMETER AzureResourceGroup
        See the notes section for more information.

    .PARAMETER AzureRegion
        See the notes section for more information.

    .PARAMETER AzureTenantId
        See the notes section for more information.

    .PARAMETER AzureServicePrincipal
        See the notes section for more information.

    .PARAMETER AzureServicePrincipalSecret
        See the notes section for more information.

    .PARAMETER AzureArcProxy
        See the notes section for more information.

    .PARAMETER SkipRules
        See the notes section for more information.

    .PARAMETER ProductCoveredBySA
        See the notes section for more information.

    .LINK
        https://docs.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server-from-the-command-prompt

    .OUTPUTS
        None.

    .EXAMPLE
        Invoke-SetupAction -Install -AcceptLicensingTerms -InstanceName 'MyInstance' -Features 'SQLENGINE' -SqlSysAdminAccounts @('MyAdminAccount') -MediaPath 'E:\'

        Installs the database engine for the named instance MyInstance.

    .EXAMPLE
        Invoke-SetupAction -Install -AcceptLicensingTerms -InstanceName 'MyInstance' -Features 'SQLENGINE','ARC' -SqlSysAdminAccounts @('MyAdminAccount') -MediaPath 'E:\' -AzureSubscriptionId 'MySubscriptionId' -AzureResourceGroup 'MyRG' -AzureRegion 'West-US' -AzureTenantId 'MyTenantId' -AzureServicePrincipal 'MyPrincipalName' -AzureServicePrincipalSecret ('MySecret' | ConvertTo-SecureString -AsPlainText -Force)

        Installs the database engine for the named instance MyInstance and onboard the server to Azure Arc.

    .EXAMPLE
        Invoke-SetupAction -Install -AcceptLicensingTerms -MediaPath 'E:\' -AzureSubscriptionId 'MySubscriptionId' -AzureResourceGroup 'MyRG' -AzureRegion 'West-US' -AzureTenantId 'MyTenantId' -AzureServicePrincipal 'MyPrincipalName' -AzureServicePrincipalSecret ('MySecret' | ConvertTo-SecureString -AsPlainText -Force)

        Installs the Azure Arc Agent on the server.

    .EXAMPLE
        Invoke-SetupAction -ConfigurationFile 'MySqlConfig.ini' -MediaPath 'E:\'

        Installs SQL Server using the configuration file 'MySqlConfig.ini'.

    .EXAMPLE
        Invoke-SetupAction -Uninstall -InstanceName 'MyInstance' -Features 'SQLENGINE' -MediaPath 'E:\'

        Uninstalls the database engine from the named instance MyInstance.

    .EXAMPLE
        Invoke-SetupAction -PrepareImage -AcceptLicensingTerms -Features 'SQLENGINE' -InstanceId 'MyInstance' -MediaPath 'E:\'

        Prepares the server for using the database engine for an instance named 'MyInstance'.

    .EXAMPLE
        Invoke-SetupAction -CompleteImage -AcceptLicensingTerms -MediaPath 'E:\'

        Completes install on a server that was previously prepared (by using prepare image).

    .EXAMPLE
        Invoke-SetupAction -Upgrade -AcceptLicensingTerms -InstanceName 'MyInstance' -MediaPath 'E:\'

        Upgrades the instance 'MyInstance' with the SQL Server version that is provided by the media path.

    .EXAMPLE
        Invoke-SetupAction -EditionUpgrade -AcceptLicensingTerms -ProductKey 'NewEditionProductKey' -InstanceName 'MyInstance' -MediaPath 'E:\'

        Upgrades the instance 'MyInstance' with the SQL Server edition that is provided by the media path.

    .EXAMPLE
        Invoke-SetupAction -Repair -InstanceName 'MyInstance' -Features 'SQLENGINE' -MediaPath 'E:\'

        Repairs the database engine of the instance 'MyInstance'.

    .EXAMPLE
        Invoke-SetupAction -RebuildDatabase -InstanceName 'MyInstance' -SqlSysAdminAccounts @('MyAdminAccount') -MediaPath 'E:\'

        Rebuilds the database of the instance 'MyInstance'.

    .EXAMPLE
        Invoke-SetupAction -InstallFailoverCluster -AcceptLicensingTerms -InstanceName 'MyInstance' -Features 'SQLENGINE' -InstallSqlDataDir 'D:\MSSQL\Data' -SqlSysAdminAccounts @('MyAdminAccount') -FailoverClusterNetworkName 'TestCluster01A' -FailoverClusterIPAddresses 'IPv4;192.168.0.46;ClusterNetwork1;255.255.255.0' -MediaPath 'E:\'

        Installs the database engine in a failover cluster with the instance name 'MyInstance'.

    .EXAMPLE
        Invoke-SetupAction -PrepareFailoverCluster -AcceptLicensingTerms -InstanceName 'MyInstance' -Features 'SQLENGINE' -MediaPath 'E:\'

        Prepares to installs the database engine in a failover cluster with the instance name 'MyInstance'.

    .EXAMPLE
        Invoke-SetupAction -CompleteFailoverCluster -InstanceName 'MyInstance' -InstallSqlDataDir 'D:\MSSQL\Data' -SqlSysAdminAccounts @('MyAdminAccount') -FailoverClusterNetworkName 'TestCluster01A' -FailoverClusterIPAddresses 'IPv4;192.168.0.46;ClusterNetwork1;255.255.255.0' -MediaPath 'E:\'

        Completes the install of the database engine in the failover cluster with the instance name 'MyInstance'.

    .EXAMPLE
        Invoke-SetupAction -AddNode -AcceptLicensingTerms -InstanceName 'MyInstance' -FailoverClusterIPAddresses 'IPv4;192.168.0.46;ClusterNetwork1;255.255.255.0' -MediaPath 'E:\'

        Adds the node to the failover cluster for the instance 'MyInstance'.

    .EXAMPLE
        Invoke-SetupAction -RemoveNode -InstanceName 'MyInstance' -MediaPath 'E:\'

        Removes the node from the failover cluster of the instance 'MyInstance'.

    .NOTES
        The parameters are intentionally not described since it would take a lot
        of effort to keep them up to date. Instead there is a link that points to
        the SQL Server command line setup documentation which will stay relevant.

        For RebuildDatabase the parameter SAPwd must be set if the instance was
        installed with SecurityMode = 'SQL'.
#>
function Invoke-SetupAction
{
    # cSpell: ignore PBDMS Admini AZUREEXTENSION BSTR
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType()]
    param
    (
        [Parameter(ParameterSetName = 'Install', Mandatory = $true)]
        [Parameter(ParameterSetName = 'InstallRole', Mandatory = $true)]
        [Parameter(ParameterSetName = 'InstallAzureArcAgent', Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $Install,

        [Parameter(ParameterSetName = 'Uninstall', Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $Uninstall,

        [Parameter(ParameterSetName = 'PrepareImage', Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $PrepareImage,

        [Parameter(ParameterSetName = 'CompleteImage', Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $CompleteImage,

        [Parameter(ParameterSetName = 'Upgrade', Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $Upgrade,

        [Parameter(ParameterSetName = 'EditionUpgrade', Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $EditionUpgrade,

        [Parameter(ParameterSetName = 'Repair', Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $Repair,

        [Parameter(ParameterSetName = 'RebuildDatabase', Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $RebuildDatabase,

        [Parameter(ParameterSetName = 'InstallFailoverCluster', Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $InstallFailoverCluster,

        [Parameter(ParameterSetName = 'PrepareFailoverCluster', Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $PrepareFailoverCluster,

        [Parameter(ParameterSetName = 'CompleteFailoverCluster', Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $CompleteFailoverCluster,

        [Parameter(ParameterSetName = 'AddNode', Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $AddNode,

        [Parameter(ParameterSetName = 'RemoveNode', Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $RemoveNode,

        [Parameter(ParameterSetName = 'UsingConfigurationFile', Mandatory = $true)]
        [ValidateScript({
                if (-not (Test-Path -Path $_))
                {
                    throw $script:localizedData.Invoke_SetupAction_ConfigurationFileNotFound
                }

                return $true
            })]
        [System.String]
        $ConfigurationFile,

        [Parameter(ParameterSetName = 'Install', Mandatory = $true)]
        [Parameter(ParameterSetName = 'InstallRole', Mandatory = $true)]
        [Parameter(ParameterSetName = 'InstallAzureArcAgent', Mandatory = $true)]
        [Parameter(ParameterSetName = 'PrepareImage', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Upgrade', Mandatory = $true)]
        [Parameter(ParameterSetName = 'EditionUpgrade', Mandatory = $true)]
        [Parameter(ParameterSetName = 'InstallFailoverCluster', Mandatory = $true)]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster', Mandatory = $true)]
        [Parameter(ParameterSetName = 'AddNode', Mandatory = $true)]
        [Parameter(ParameterSetName = 'CompleteImage', Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $AcceptLicensingTerms,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [System.Management.Automation.SwitchParameter]
        $SuppressPrivacyStatementNotice,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'PrepareImage')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [Parameter(ParameterSetName = 'AddNode')]
        [System.Management.Automation.SwitchParameter]
        $IAcknowledgeEntCalLimits,

        [Parameter(Mandatory = $true)]
        [ValidateScript({
                if (-not (Test-Path -Path (Join-Path -Path $_ -ChildPath 'setup.exe')))
                {
                    throw $script:localizedData.Invoke_SetupAction_MediaPathNotFound
                }

                return $true
            })]
        [System.String]
        $MediaPath,

        [Parameter(ParameterSetName = 'Install', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Uninstall', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Upgrade', Mandatory = $true)]
        [Parameter(ParameterSetName = 'EditionUpgrade', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Repair', Mandatory = $true)]
        [Parameter(ParameterSetName = 'RebuildDatabase', Mandatory = $true)]
        [Parameter(ParameterSetName = 'InstallFailoverCluster', Mandatory = $true)]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster', Mandatory = $true)]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster', Mandatory = $true)]
        [Parameter(ParameterSetName = 'AddNode', Mandatory = $true)]
        [Parameter(ParameterSetName = 'RemoveNode', Mandatory = $true)]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [System.String]
        $InstanceName,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'PrepareImage')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'Upgrade')]
        [Parameter(ParameterSetName = 'Repair')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster')]
        [Parameter(ParameterSetName = 'AddNode')]
        [System.Management.Automation.SwitchParameter]
        $Enu,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'PrepareImage')]
        [Parameter(ParameterSetName = 'Upgrade')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [Parameter(ParameterSetName = 'AddNode')]
        [System.Management.Automation.SwitchParameter]
        $UpdateEnabled,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'PrepareImage')]
        [Parameter(ParameterSetName = 'Upgrade')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [Parameter(ParameterSetName = 'AddNode')]
        [System.String]
        $UpdateSource,

        [Parameter(ParameterSetName = 'Install', Mandatory = $true)]
        [Parameter(ParameterSetName = 'PrepareImage', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Repair', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Uninstall', Mandatory = $true)]
        [Parameter(ParameterSetName = 'InstallFailoverCluster', Mandatory = $true)]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster', Mandatory = $true)]
        [Parameter(ParameterSetName = 'InstallRole')]
        [ValidateSet(
            'SQL',
            'SQLEngine', # Part of parent feature SQL
            'Replication', # Part of parent feature SQL
            'FullText', # Part of parent feature SQL
            'DQ', # Part of parent feature SQL
            'PolyBase', # Part of parent feature SQL
            'PolyBaseCore', # Part of parent feature SQL
            'PolyBaseJava', # Part of parent feature SQL
            'AdvancedAnalytics', # Part of parent feature SQL
            'SQL_INST_MR', # Part of parent feature SQL
            'SQL_INST_MPY', # Part of parent feature SQL
            'SQL_INST_JAVA', # Part of parent feature SQL
            'AS',
            'RS',
            'RS_SHP',
            'RS_SHPWFE', # cspell: disable-line
            'DQC',
            'IS',
            'IS_Master', # Part of parent feature IS
            'IS_Worker', # Part of parent feature IS
            'MDS',
            'SQL_SHARED_MPY',
            'SQL_SHARED_MR',
            'Tools',
            'BC', # Part of parent feature Tools
            'Conn', # Part of parent feature Tools
            'DREPLAY_CTLR', # Part of parent feature Tools (cspell: disable-line)
            'DREPLAY_CLT', # Part of parent feature Tools (cspell: disable-line)
            'SNAC_SDK', # Part of parent feature Tools (cspell: disable-line)
            'SDK', # Part of parent feature Tools
            'LocalDB', # Part of parent feature Tools
            'AZUREEXTENSION'
        )]
        [System.String[]]
        $Features,

        [Parameter(ParameterSetName = 'InstallRole', Mandatory = $true)]
        [ValidateSet(
            'ALLFeatures_WithDefaults',
            'SPI_AS_NewFarm',
            'SPI_AS_ExistingFarm'
        )]
        [System.String]
        $Role,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'PrepareImage')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [System.String]
        $InstallSharedDir,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [System.String]
        $InstallSharedWowDir,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'PrepareImage')]
        [Parameter(ParameterSetName = 'Upgrade')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [System.String]
        $InstanceDir,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'PrepareImage', Mandatory = $true)]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'Upgrade')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [System.String]
        $InstanceId,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'PrepareImage')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'Repair')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [Parameter(ParameterSetName = 'AddNode')]
        [System.String]
        $PBEngSvcAccount,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'PrepareImage')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'Repair')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [Parameter(ParameterSetName = 'AddNode')]
        [System.Security.SecureString]
        $PBEngSvcPassword,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'PrepareImage')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'Repair')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [Parameter(ParameterSetName = 'AddNode')]
        [ValidateSet('Automatic', 'Disabled', 'Manual')]
        [System.String]
        $PBEngSvcStartupType,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [System.String]
        $PBDMSSvcAccount, # cspell: disable-line

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [System.Security.SecureString]
        $PBDMSSvcPassword, # cspell: disable-line

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [ValidateSet('Automatic', 'Disabled', 'Manual')]
        [System.String]
        $PBDMSSvcStartupType, # cspell: disable-line

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'PrepareImage')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'Repair')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [Parameter(ParameterSetName = 'AddNode')]
        [System.UInt16]
        $PBStartPortRange,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'PrepareImage')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'Repair')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [Parameter(ParameterSetName = 'AddNode')]
        [System.UInt16]
        $PBEndPortRange,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'PrepareImage')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'Repair')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [Parameter(ParameterSetName = 'AddNode')]
        [System.Management.Automation.SwitchParameter]
        $PBScaleOut,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'Upgrade')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster')]
        [Parameter(ParameterSetName = 'AddNode')]
        [Parameter(ParameterSetName = 'EditionUpgrade', Mandatory = $true)]
        [System.String]
        $ProductKey, # This is argument PID but $PID is reserved variable.

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [Parameter(ParameterSetName = 'AddNode')]
        [System.String]
        $AgtSvcAccount,

        [Parameter(ParameterSetName = 'UsingConfigurationFile')]
        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [Parameter(ParameterSetName = 'AddNode')]
        [System.Security.SecureString]
        $AgtSvcPassword,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [ValidateSet('Automatic', 'Disabled', 'Manual')]
        [System.String]
        $AgtSvcStartupType,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster')]
        [System.String]
        $ASBackupDir,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster')]
        [System.String]
        $ASCollation,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster')]
        [System.String]
        $ASConfigDir,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster')]
        [System.String]
        $ASDataDir,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster')]
        [System.String]
        $ASLogDir,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster')]
        [System.String]
        $ASTempDir,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster')]
        [ValidateSet('Multidimensional', 'PowerPivot', 'Tabular')]
        [System.String]
        $ASServerMode,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [Parameter(ParameterSetName = 'AddNode')]
        [System.String]
        $ASSvcAccount,

        [Parameter(ParameterSetName = 'UsingConfigurationFile')]
        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [Parameter(ParameterSetName = 'AddNode')]
        [System.Security.SecureString]
        $ASSvcPassword,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [ValidateSet('Automatic', 'Disabled', 'Manual')]
        [System.String]
        $ASSvcStartupType,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster')]
        [System.String[]]
        $ASSysAdminAccounts,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster')]
        [System.Management.Automation.SwitchParameter]
        $ASProviderMSOLAP,

        [Parameter(ParameterSetName = 'InstallRole')]
        [System.String]
        $FarmAccount,

        [Parameter(ParameterSetName = 'InstallRole')]
        [System.Security.SecureString]
        $FarmPassword,

        [Parameter(ParameterSetName = 'InstallRole')]
        [System.Security.SecureString]
        $Passphrase,

        [Parameter(ParameterSetName = 'InstallRole')]
        [ValidateRange(0, 65536)]
        [System.UInt16]
        $FarmAdminiPort, # cspell: disable-line

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'Upgrade')]
        [ValidateSet('Automatic', 'Disabled', 'Manual')]
        [System.String]
        $BrowserSvcStartupType,

        [Parameter(ParameterSetName = 'Upgrade')]
        [ValidateSet('Rebuild', 'Reset', 'Import')]
        [System.String]
        $FTUpgradeOption,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [System.Management.Automation.SwitchParameter]
        $EnableRanU,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster', Mandatory = $true)]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster', Mandatory = $true)]
        [System.String]
        $InstallSqlDataDir,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster')]
        [System.String]
        $SqlBackupDir,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster')]
        [ValidateSet('SQL')]
        [System.String]
        $SecurityMode,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'RebuildDatabase')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster')]
        [System.Security.SecureString]
        $SAPwd,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'RebuildDatabase')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster')]
        [System.String]
        $SqlCollation,

        [Parameter(ParameterSetName = 'InstallRole')]
        [System.Management.Automation.SwitchParameter]
        $AddCurrentUserAsSqlAdmin,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [Parameter(ParameterSetName = 'AddNode')]
        [System.String]
        $SqlSvcAccount,

        [Parameter(ParameterSetName = 'UsingConfigurationFile')]
        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [Parameter(ParameterSetName = 'AddNode')]
        [System.Security.SecureString]
        $SqlSvcPassword,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [ValidateSet('Automatic', 'Disabled', 'Manual')]
        [System.String]
        $SqlSvcStartupType,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'RebuildDatabase', Mandatory = $true)]
        [Parameter(ParameterSetName = 'InstallFailoverCluster', Mandatory = $true)]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster', Mandatory = $true)]
        [Parameter(ParameterSetName = 'InstallRole')]
        [System.String[]]
        $SqlSysAdminAccounts,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'RebuildDatabase')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster')]
        [System.String]
        $SqlTempDbDir,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'RebuildDatabase')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster')]
        [System.String]
        $SqlTempDbLogDir,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'RebuildDatabase')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster')]
        [System.UInt16]
        $SqlTempDbFileCount,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'RebuildDatabase')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster')]
        [ValidateRange(4, 262144)]
        [System.UInt16]
        $SqlTempDbFileSize,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'RebuildDatabase')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster')]
        [ValidateRange(0, 1024)]
        [System.UInt16]
        $SqlTempDbFileGrowth,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'RebuildDatabase')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster')]
        [ValidateRange(4, 262144)]
        [System.UInt16]
        $SqlTempDbLogFileSize,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'RebuildDatabase')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster')]
        [ValidateRange(0, 1024)]
        [System.UInt16]
        $SqlTempDbLogFileGrowth,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster')]
        [System.String]
        $SqlUserDbDir,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [System.Management.Automation.SwitchParameter]
        $SqlSvcInstantFileInit,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster')]
        [System.String]
        $SqlUserDbLogDir,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [ValidateRange(0, 32767)]
        [System.UInt16]
        $SqlMaxDop,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [System.Management.Automation.SwitchParameter]
        $UseSqlRecommendedMemoryLimits,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [ValidateRange(0, 2147483647)]
        [System.UInt32]
        $SqlMinMemory,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [ValidateRange(0, 2147483647)]
        [System.UInt32]
        $SqlMaxMemory,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [ValidateRange(0, 3)]
        [System.UInt16]
        $FileStreamLevel,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [System.String]
        $FileStreamShareName,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'Upgrade')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [Parameter(ParameterSetName = 'AddNode')]
        [System.String]
        $ISSvcAccount,

        [Parameter(ParameterSetName = 'UsingConfigurationFile')]
        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'Upgrade')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [Parameter(ParameterSetName = 'AddNode')]
        [System.Security.SecureString]
        $ISSvcPassword,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'Upgrade')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [ValidateSet('Automatic', 'Disabled', 'Manual')]
        [System.String]
        $ISSvcStartupType,

        [Parameter(ParameterSetName = 'Upgrade')]
        [System.Management.Automation.SwitchParameter]
        $AllowUpgradeForSSRSSharePointMode,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [System.Management.Automation.SwitchParameter]
        $NpEnabled,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [System.Management.Automation.SwitchParameter]
        $TcpEnabled,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster')]
        [Parameter(ParameterSetName = 'AddNode')]
        [ValidateSet('SharePointFilesOnlyMode', 'DefaultNativeMode', 'FilesOnlyMode')]
        [System.String]
        $RsInstallMode,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [Parameter(ParameterSetName = 'AddNode')]
        [System.String]
        $RSSvcAccount,

        [Parameter(ParameterSetName = 'UsingConfigurationFile')]
        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [Parameter(ParameterSetName = 'AddNode')]
        [System.Security.SecureString]
        $RSSvcPassword,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [ValidateSet('Automatic', 'Disabled', 'Manual')]
        [System.String]
        $RSSvcStartupType,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [System.String]
        $MPYCacheDirectory,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [System.String]
        $MRCacheDirectory,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [System.Management.Automation.SwitchParameter]
        $SqlInstJava,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [System.String]
        $SqlJavaDir,

        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster')]
        [System.String]
        $FailoverClusterGroup,

        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster')]
        [System.String[]]
        $FailoverClusterDisks,

        [Parameter(ParameterSetName = 'InstallFailoverCluster', Mandatory = $true)]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster', Mandatory = $true)]
        [System.String]
        $FailoverClusterNetworkName,

        [Parameter(ParameterSetName = 'InstallFailoverCluster', Mandatory = $true)]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster', Mandatory = $true)]
        [Parameter(ParameterSetName = 'AddNode', Mandatory = $true)]
        [System.String[]]
        $FailoverClusterIPAddresses,

        [Parameter(ParameterSetName = 'CompleteFailoverCluster')]
        [Parameter(ParameterSetName = 'AddNode')]
        [Parameter(ParameterSetName = 'RemoveNode')]
        [System.Management.Automation.SwitchParameter]
        $ConfirmIPDependencyChange,

        [Parameter(ParameterSetName = 'Upgrade')]
        [ValidateRange(0, 2)]
        [System.UInt16]
        $FailoverClusterRollOwnership,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallAzureArcAgent', Mandatory = $true)]
        [System.String]
        $AzureSubscriptionId,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallAzureArcAgent', Mandatory = $true)]
        [System.String]
        $AzureResourceGroup,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallAzureArcAgent', Mandatory = $true)]
        [System.String]
        $AzureRegion,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallAzureArcAgent', Mandatory = $true)]
        [System.String]
        $AzureTenantId,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallAzureArcAgent', Mandatory = $true)]
        [System.String]
        $AzureServicePrincipal,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallAzureArcAgent', Mandatory = $true)]
        [System.Security.SecureString]
        $AzureServicePrincipalSecret,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallAzureArcAgent')]
        [System.String]
        $AzureArcProxy,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'EditionUpgrade')]
        [System.String[]]
        $SkipRules,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'CompleteImage')]
        [Parameter(ParameterSetName = 'Upgrade')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [Parameter(ParameterSetName = 'CompleteFailoverCluster')]
        [Parameter(ParameterSetName = 'AddNode')]
        [Parameter(ParameterSetName = 'EditionUpgrade')]
        [System.Management.Automation.SwitchParameter]
        $ProductCoveredBySA,

        [Parameter()]
        [System.UInt32]
        $Timeout = 7200,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    if ($Force.IsPresent -and -not $Confirm)
    {
        $ConfirmPreference = 'None'
    }

    Assert-ElevatedUser -ErrorAction 'Stop'

    switch ($PSCmdlet.ParameterSetName)
    {
        'InstallRole'
        {
            $setupAction = 'Install'

            break
        }

        'InstallAzureArcAgent'
        {
            $setupAction = 'Install'

            <#
                For this setup action the parameter Features is not part of the
                parameter set, so this can be safely set.
            #>
            $PSBoundParameters.Features = @('AZUREEXTENSION')

            break
        }

        default
        {
            $setupAction = $PSCmdlet.ParameterSetName

            break
        }
    }

    Assert-SetupActionProperties -Property $PSBoundParameters -SetupAction $setupAction -ErrorAction 'Stop'

    $setupArgument = '/QUIET /ACTION={0}' -f $setupAction

    if ($DebugPreference -in @('Continue', 'Inquire'))
    {
        $setupArgument += ' /INDICATEPROGRESS' # cspell: disable-line
    }

    if ($AcceptLicensingTerms.IsPresent)
    {
        $setupArgument += ' /IACCEPTSQLSERVERLICENSETERMS' # cspell: disable-line

        if ($PSBoundParameters.ContainsKey('Features'))
        {
            if ($PSBoundParameters.Features -contains 'SQL_SHARED_MR' )
            {
                $setupArgument += ' /IACCEPTROPENLICENSETERMS' # cspell: disable-line
            }

            if ($PSBoundParameters.Features -contains 'SQL_SHARED_MPY' )
            {
                $setupArgument += ' /IACCEPTPYTHONLICENSETERMS' # cspell: disable-line
            }
        }
    }

    $ignoreParameters = @(
        $PSCmdlet.ParameterSetName
        'Install' # Must add this exclusively because of parameter set InstallAzureArcAgent
        'AcceptLicensingTerms'
        'MediaPath'
        'Timeout'
        'Force'
    )

    $ignoreParameters += [System.Management.Automation.PSCmdlet]::CommonParameters
    $ignoreParameters += [System.Management.Automation.PSCmdlet]::OptionalCommonParameters

    $boundParameterName = $PSBoundParameters.Keys.Where({ $_ -notin $ignoreParameters })

    $sensitiveValue = @()

    $pathParameter = @(
        'InstallSharedDir'
        'InstallSharedWowDir'
        'InstanceDir'
        'ASBackupDir'
        'ASConfigDir'
        'ASDataDir'
        'ASLogDir'
        'ASTempDir'
        'InstallSqlDataDir'
        'SqlBackupDir'
        'SqlTempDbDir'
        'SqlTempDbLogDir'
        'SqlUserDbDir'
        'SqlUserDbLogDir'
        'MPYCacheDirectory'
        'MRCacheDirectory'
        'SqlJavaDir'
    )

    <#
        Remove trialing backslash from paths so they are not interpreted as
        escape-characters for a double-quote.
        See issue https://github.com/dsccommunity/SqlServerDsc/issues/1254.
    #>
    $boundParameterName.Where( { $_ -in $pathParameter } ).ForEach({
            # Must not change paths that reference a root directory (they are handle differently later)
            if ($PSBoundParameters.$_ -notmatch '^[a-zA-Z]:\\$')
            {
                $PSBoundParameters.$_ = $PSBoundParameters.$_.TrimEnd('\')
            }
        })

    # Loop through all bound parameters and build arguments for the setup executable.
    foreach ($parameterName in $boundParameterName)
    {
        # Make sure parameter is upper-case.
        $parameterName = $parameterName.ToUpper()

        $setupArgument += ' /{0}' -f $parameterName

        switch ($parameterName)
        {
            <#
                Must be handled differently because it is an array and have a comma
                separating the values, and the value shall be upper-case.
            #>
            { $_ -in @('FEATURES', 'ROLE') }
            {
                $setupArgument += '={0}' -f ($PSBoundParameters.$parameterName.ToUpper() -join ',')

                break
            }

            # Must be handled differently because the value MUST be upper-case.
            'ASSERVERMODE' # cspell: disable-line
            {
                $setupArgument += '={0}' -f $PSBoundParameters.$parameterName.ToUpper()

                break
            }

            # Must be handled differently because the parameter name could not be $PID.
            'PRODUCTKEY' # cspell: disable-line
            {
                # Remove the argument that was added above.
                $setupArgument = $setupArgument -replace ' \/{0}' -f $parameterName

                $sensitiveValue += $PSBoundParameters.$parameterName

                $setupArgument += ' /PID="{0}"' -f $PSBoundParameters.$parameterName

                break
            }

            # Must be handled differently because the argument name shall have an underscore in the argument.
            'SQLINSTJAVA' # cspell: disable-line
            {
                # Remove the argument that was added above.
                $setupArgument = $setupArgument -replace ' \/{0}' -f $parameterName

                $setupArgument += ' /SQL_INST_JAVA'

                break
            }

            # Must be handled differently because each value shall be separated by a semi-colon.
            'FAILOVERCLUSTERDISKS' # cspell: disable-line
            {
                $setupArgument += '="{0}"' -f ($PSBoundParameters.$parameterName -join ';')

                break
            }

            # Must be handled differently because two parameters shall become one argument.
            { $_ -in ('PBSTARTPORTRANGE', 'PBENDPORTRANGE') } # cspell: disable-line
            {
                # Remove the argument that was added above.
                $setupArgument = $setupArgument -replace ' \/{0}' -f $parameterName

                # Only set argument if it is not present already.
                if ($setupArgument -notmatch '\/PBPORTRANGE') # cspell: disable-line
                {
                    # cspell: disable-next
                    $setupArgument += ' /PBPORTRANGE={0}-{1}' -f $PSBoundParameters.PBStartPortRange, $PSBoundParameters.PBEndPortRange
                }

                break
            }

            { $PSBoundParameters.$parameterName -is [System.Management.Automation.SwitchParameter] }
            {
                <#
                    If a switch parameter is not included below then those arguments
                    shall not have any value after argument name, e.g. '/ENU'.
                #>
                switch ($parameterName)
                {
                    # Arguments that shall have the value set to the boolean numeric representation.
                    { $parameterName -in ('ASPROVIDERMSOLAP', 'NPENABLED', 'TCPENABLED', 'CONFIRMIPDEPENDENCYCHANGE') } # cspell: disable-line
                    {
                        $setupArgument += '={0}' -f [System.Byte] $PSBoundParameters.$parameterName.ToBool()

                        break
                    }

                    <#
                        Arguments that shall have the value set to the boolean string representation.
                        Excluding parameter names that shall be handled differently, those arguments
                        shall not have any value after argument name, e.g. '/ENU'.
                    #>
                    { $parameterName -in @('UPDATEENABLED', 'PBSCALEOUT', 'SQLSVCINSTANTFILEINIT', 'ALLOWUPGRADEFORSSRSSHAREPOINTMODE', 'ADDCURRENTUSERASSQLADMIN', 'IACKNOWLEDGEENTCALLIMITS') } # cspell: disable-line
                    {
                        $setupArgument += '={0}' -f $PSBoundParameters.$parameterName.ToString()

                        break
                    }
                }

                break
            }

            <#
                Must be handled differently because it is an numeric value and does not need to
                be surrounded by double-quote.
            #>
            { $PSBoundParameters.$parameterName | Test-IsNumericType }
            {
                $setupArgument += '={0}' -f ($PSBoundParameters.$parameterName -join '" "')

                break
            }

            <#
                Must be handled differently because it is an array and have a space
                separating the values, and each value is surrounded by double-quote.
            #>
            { $PSBoundParameters.$parameterName -is [System.Array] }
            {
                $setupArgument += '="{0}"' -f ($PSBoundParameters.$parameterName -join '" "')

                break
            }

            { $PSBoundParameters.$parameterName -is [System.Security.SecureString] }
            {
                $secureString = $PSBoundParameters.$parameterName

                if ($PSVersionTable.PSVersion -ge '6.0')
                {
                    $passwordClearText = $secureString | ConvertFrom-SecureString -AsPlainText
                }
                else
                {
                    # Workaround to convert SecureString to plain text in Windows PowerShell.
                    $binaryStringPointer = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString)
                    $passwordClearText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($binaryStringPointer)
                }

                $sensitiveValue += $passwordClearText

                $setupArgument += '="{0}"' -f $passwordClearText

                break
            }

            default
            {
                <#
                    When there is backslash followed by a double-quote then the backslash
                    is treated as an escape character for the double-quote. For arguments
                    that holds a path and the value references a root directory, e.g. 'E:\',
                    then the value must not be surrounded by double-quotes. Other paths
                    should be surrounded by double-quotes as they can contain spaces.
                    See issue https://github.com/dsccommunity/SqlServerDsc/issues/1254.
                #>
                if ($PSBoundParameters.$parameterName -match '^[a-zA-Z]:\\$')
                {
                    $setupArgument += '={0}' -f $PSBoundParameters.$parameterName
                }
                else
                {
                    $setupArgument += '="{0}"' -f $PSBoundParameters.$parameterName
                }
                break
            }
        }
    }

    $verboseSetupArgument = $setupArgument

    # Obfuscate sensitive values.
    foreach ($currentSensitiveValue in $sensitiveValue)
    {
        $escapedRegExString = [System.Text.RegularExpressions.Regex]::Escape($currentSensitiveValue)

        $verboseSetupArgument = $verboseSetupArgument -replace $escapedRegExString, '********'
    }

    # Clear sensitive values.
    $sensitiveValue = $null

    Write-Verbose -Message ($script:localizedData.Invoke_SetupAction_SetupArguments -f $verboseSetupArgument)

    $verboseDescriptionMessage = $script:localizedData.Invoke_SetupAction_ShouldProcessVerboseDescription -f $PSCmdlet.ParameterSetName
    $verboseWarningMessage = $script:localizedData.Invoke_SetupAction_ShouldProcessVerboseWarning -f $PSCmdlet.ParameterSetName
    $captionMessage = $script:localizedData.Invoke_SetupAction_ShouldProcessCaption

    if ($PSCmdlet.ShouldProcess($verboseDescriptionMessage, $verboseWarningMessage, $captionMessage))
    {
        $expandedMediaPath = [System.Environment]::ExpandEnvironmentVariables($MediaPath)

        $startProcessParameters = @{
            FilePath     = Join-Path -Path $expandedMediaPath -ChildPath 'setup.exe'
            ArgumentList = $setupArgument
            Timeout      = $Timeout
        }

        # Clear setupArgument to remove any sensitive values.
        $setupArgument = $null

        # Run setup executable.
        $processExitCode = Start-SqlSetupProcess @startProcessParameters

        $setupExitMessage = ($script:localizedData.SetupAction_SetupExitMessage -f $processExitCode)

        if ($processExitCode -eq 3010)
        {
            Write-Warning -Message (
                '{0} {1}' -f $setupExitMessage, $script:localizedData.SetupAction_SetupSuccessfulRebootRequired
            )
        }
        elseif ($processExitCode -ne 0)
        {
            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new(
                    ('{0} {1}' -f $setupExitMessage, $script:localizedData.Invoke_SetupAction_SetupFailed),
                    'ISA0001', # cspell: disable-line
                    [System.Management.Automation.ErrorCategory]::InvalidOperation,
                    $InstanceName
                )
            )
        }
        else
        {
            Write-Verbose -Message (
                '{0} {1}' -f $setupExitMessage, ($script:localizedData.SetupAction_SetupSuccessful)
            )
        }
    }
}
#EndRegion '.\Private\Invoke-SetupAction.ps1' 1726
#Region '.\Public\Add-SqlDscNode.ps1' -1

<#
    .SYNOPSIS
        Add a SQL Server node to an Failover Cluster instance (FCI).

    .DESCRIPTION
        Add a SQL Server node to an Failover Cluster instance (FCI).

        See the link in the commands help for information on each parameter. The
        link points to SQL Server command line setup documentation.

    .PARAMETER AcceptLicensingTerms
        Required parameter to be able to run unattended install. By specifying this
        parameter you acknowledge the acceptance all license terms and notices for
        the specified features, the terms and notices that the Microsoft SQL Server
        setup executable normally ask for.

    .PARAMETER MediaPath
        Specifies the path where to find the SQL Server installation media. On this
        path the SQL Server setup executable must be found.

    .PARAMETER Timeout
        Specifies how long to wait for the setup process to finish. Default value
        is `7200` seconds (2 hours). If the setup process does not finish before
        this time, an exception will be thrown.

    .PARAMETER Force
        If specified the command will not ask for confirmation. Same as if Confirm:$false
        is used.

    .PARAMETER IAcknowledgeEntCalLimits
        See the notes section for more information.

    .PARAMETER InstanceName
        See the notes section for more information.

    .PARAMETER Enu
        See the notes section for more information.

    .PARAMETER UpdateEnabled
        See the notes section for more information.

    .PARAMETER UpdateSource
        See the notes section for more information.

    .PARAMETER PBEngSvcAccount
        See the notes section for more information.

    .PARAMETER PBEngSvcPassword
        See the notes section for more information.

    .PARAMETER PBEngSvcStartupType
        See the notes section for more information.

    .PARAMETER PBStartPortRange
        See the notes section for more information.

    .PARAMETER PBEndPortRange
        See the notes section for more information.

    .PARAMETER PBScaleOut
        See the notes section for more information.

    .PARAMETER ProductKey
        See the notes section for more information.

    .PARAMETER AgtSvcAccount
        See the notes section for more information.

    .PARAMETER AgtSvcPassword
        See the notes section for more information.

    .PARAMETER ASSvcAccount
        See the notes section for more information.

    .PARAMETER ASSvcPassword
        See the notes section for more information.

    .PARAMETER SqlSvcAccount
        See the notes section for more information.

    .PARAMETER SqlSvcPassword
        See the notes section for more information.

    .PARAMETER ISSvcAccount
        See the notes section for more information.

    .PARAMETER ISSvcPassword
        See the notes section for more information.

    .PARAMETER RsInstallMode
        See the notes section for more information.

    .PARAMETER RSSvcAccount
        See the notes section for more information.

    .PARAMETER RSSvcPassword
        See the notes section for more information.

    .PARAMETER FailoverClusterIPAddresses
        See the notes section for more information.

    .PARAMETER ConfirmIPDependencyChange
        See the notes section for more information.

    .PARAMETER ProductCoveredBySA
        See the notes section for more information.

    .LINK
        https://docs.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server-from-the-command-prompt

    .OUTPUTS
        None.

    .EXAMPLE
        Add-SqlDscNode -AcceptLicensingTerms -InstanceName 'MyInstance' -FailoverClusterIPAddresses 'IPv4;192.168.0.46;ClusterNetwork1;255.255.255.0' -MediaPath 'E:\'

        Adds the current node's SQL Server instance 'MyInstance' to the Failover Cluster instance.

    .NOTES
        The parameters are intentionally not described since it would take a lot
        of effort to keep them up to date. Instead there is a link that points to
        the SQL Server command line setup documentation which will stay relevant.
#>
function Add-SqlDscNode
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '', Justification = 'Because ShouldProcess is used in Invoke-SetupAction')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '', Justification = 'Because ShouldProcess is used in Invoke-SetupAction')]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $AcceptLicensingTerms,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $IAcknowledgeEntCalLimits,

        [Parameter(Mandatory = $true)]
        [System.String]
        $MediaPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $InstanceName,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Enu,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $UpdateEnabled,

        [Parameter()]
        [System.String]
        $UpdateSource,

        [Parameter()]
        [System.String]
        $PBEngSvcAccount,

        [Parameter()]
        [System.Security.SecureString]
        $PBEngSvcPassword,

        [Parameter()]
        [ValidateSet('Automatic', 'Disabled', 'Manual')]
        [System.String]
        $PBEngSvcStartupType,

        [Parameter()]
        [System.UInt16]
        $PBStartPortRange,

        [Parameter()]
        [System.UInt16]
        $PBEndPortRange,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $PBScaleOut,

        [Parameter()]
        [System.String]
        $ProductKey, # This is argument PID but $PID is reserved variable.

        [Parameter()]
        [System.String]
        $AgtSvcAccount,

        [Parameter()]
        [System.Security.SecureString]
        $AgtSvcPassword,

        [Parameter()]
        [System.String]
        $ASSvcAccount,

        [Parameter()]
        [System.Security.SecureString]
        $ASSvcPassword,

        [Parameter()]
        [System.String]
        $SqlSvcAccount,

        [Parameter()]
        [System.Security.SecureString]
        $SqlSvcPassword,

        [Parameter()]
        [System.String]
        $ISSvcAccount,

        [Parameter()]
        [System.Security.SecureString]
        $ISSvcPassword,

        [Parameter()]
        [ValidateSet('SharePointFilesOnlyMode', 'DefaultNativeMode', 'FilesOnlyMode')]
        [System.String]
        $RsInstallMode,

        [Parameter()]
        [System.String]
        $RSSvcAccount,

        [Parameter()]
        [System.Security.SecureString]
        $RSSvcPassword,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $FailoverClusterIPAddresses,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $ConfirmIPDependencyChange,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $ProductCoveredBySA,

        [Parameter()]
        [System.UInt32]
        $Timeout = 7200,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    Invoke-SetupAction -AddNode @PSBoundParameters
}
#EndRegion '.\Public\Add-SqlDscNode.ps1' 257
#Region '.\Public\Add-SqlDscTraceFlag.ps1' -1

<#
    .SYNOPSIS
        Add trace flags to a Database Engine instance.

    .DESCRIPTION
        Add trace flags on a Database Engine instance, keeping any trace flags
        currently set.

    .PARAMETER ServiceObject
        Specifies the Service object on which to add the trace flags.

    .PARAMETER ServerName
        Specifies the server name where the instance exist.

    .PARAMETER InstanceName
       Specifies the instance name on which to remove the trace flags.

    .PARAMETER TraceFlag
        Specifies the trace flags to add.

    .PARAMETER Force
        Specifies that the trace flag should be added without any confirmation.

    .EXAMPLE
        Add-SqlDscTraceFlag -TraceFlag 4199

        Adds the trace flag 4199 on the Database Engine default instance
        on the server where the command in run.

    .EXAMPLE
        $serviceObject = Get-SqlDscManagedComputerService -ServiceType 'DatabaseEngine'
        Add-SqlDscTraceFlag -ServiceObject $serviceObject -TraceFlag 4199

        Adds the trace flag 4199 on the Database Engine default instance
        on the server where the command in run.

    .EXAMPLE
        Add-SqlDscTraceFlag -InstanceName 'SQL2022' -TraceFlag 4199,3226

        Adds the trace flags 4199 and 3226 on the Database Engine instance
        'SQL2022' on the server where the command in run.

    .EXAMPLE
        $serviceObject = Get-SqlDscManagedComputerService -ServiceType 'DatabaseEngine' -InstanceName 'SQL2022'
        Add-SqlDscTraceFlag -ServiceObject $serviceObject -TraceFlag 4199,3226

        Adds the trace flags 4199 and 3226 on the Database Engine instance
        'SQL2022' on the server where the command in run.

    .OUTPUTS
        None.
#>
function Add-SqlDscTraceFlag
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseSyntacticallyCorrectExamples', '', Justification = 'Because the rule does not yet support parsing the code when a parameter type is not available. The ScriptAnalyzer rule UseSyntacticallyCorrectExamples will always error in the editor due to https://github.com/indented-automation/Indented.ScriptAnalyzerRules/issues/8.')]
    [OutputType()]
    [CmdletBinding(DefaultParameterSetName = 'ByServerName', SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param
    (
        [Parameter(ParameterSetName = 'ByServiceObject', Mandatory = $true, ValueFromPipeline = $true)]
        [Microsoft.SqlServer.Management.Smo.Wmi.Service]
        $ServiceObject,

        [Parameter(ParameterSetName = 'ByServerName')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ServerName = (Get-ComputerName),

        [Parameter(ParameterSetName = 'ByServerName')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $InstanceName = 'MSSQLSERVER',

        [Parameter(Mandatory = $true)]
        [System.UInt32[]]
        $TraceFlag,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    begin
    {
        if ($Force.IsPresent -and -not $Confirm)
        {
            $ConfirmPreference = 'None'
        }
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq 'ByServiceObject')
        {
            $InstanceName = $ServiceObject.Name -replace '^MSSQL\$'
        }

        # Copy $PSBoundParameters to keep it intact.
        $getSqlDscTraceFlagParameters = @{} + $PSBoundParameters

        $commonParameters = [System.Management.Automation.PSCmdlet]::OptionalCommonParameters

        # Remove parameters that Get-SqlDscTraceFLag does not have/support.
        $commonParameters + @('Force', 'TraceFlag') |
            ForEach-Object -Process {
                $getSqlDscTraceFlagParameters.Remove($_)
            }

        $currentTraceFlags = Get-SqlDscTraceFlag @getSqlDscTraceFlagParameters -ErrorAction 'Stop'

        $desiredTraceFlags = [System.UInt32[]] $currentTraceFlags + @(
            $TraceFlag |
                ForEach-Object -Process {
                    # Add only when it does not already exist.
                    if ($_ -notin $currentTraceFlags)
                    {
                        $_
                    }
                }
        )

        $verboseDescriptionMessage = $script:localizedData.TraceFlag_Add_ShouldProcessVerboseDescription -f $InstanceName, ($TraceFlag -join ', ')
        $verboseWarningMessage = $script:localizedData.TraceFlag_Add_ShouldProcessVerboseWarning -f $InstanceName
        $captionMessage = $script:localizedData.TraceFlag_Add_ShouldProcessCaption

        if ($PSCmdlet.ShouldProcess($verboseDescriptionMessage, $verboseWarningMessage, $captionMessage))
        {
            # Copy $PSBoundParameters to keep it intact.
            $setSqlDscTraceFlagParameters = @{} + $PSBoundParameters

            $setSqlDscTraceFlagParameters.TraceFLag = $desiredTraceFlags

            Set-SqlDscTraceFlag @setSqlDscTraceFlagParameters -ErrorAction 'Stop'
        }
    }
}
#EndRegion '.\Public\Add-SqlDscTraceFlag.ps1' 137
#Region '.\Public\Complete-SqlDscFailoverCluster.ps1' -1

<#
    .SYNOPSIS
        Completes the SQL Server instance installation in the Failover Cluster
        instance.

    .DESCRIPTION
        Completes the SQL Server instance installation in the Failover Cluster
        instance that was prepared using `Install-SqlDscServer` with the parameter
        `-PrepareFailoverCluster`.

        See the link in the commands help for information on each parameter. The
        link points to SQL Server command line setup documentation.

    .PARAMETER MediaPath
        Specifies the path where to find the SQL Server installation media. On this
        path the SQL Server setup executable must be found.

    .PARAMETER Timeout
        Specifies how long to wait for the setup process to finish. Default value
        is `7200` seconds (2 hours). If the setup process does not finish before
        this time, an exception will be thrown.

    .PARAMETER Force
        If specified the command will not ask for confirmation. Same as if Confirm:$false
        is used.

    .PARAMETER InstanceName
        See the notes section for more information.

    .PARAMETER Enu
        See the notes section for more information.

    .PARAMETER ProductKey
        See the notes section for more information.

    .PARAMETER ASBackupDir
        See the notes section for more information.

    .PARAMETER ASCollation
        See the notes section for more information.

    .PARAMETER ASConfigDir
        See the notes section for more information.

    .PARAMETER ASDataDir
        See the notes section for more information.

    .PARAMETER ASLogDir
        See the notes section for more information.

    .PARAMETER ASTempDir
        See the notes section for more information.

    .PARAMETER ASServerMode
        See the notes section for more information.

    .PARAMETER ASSysAdminAccounts
        See the notes section for more information.

    .PARAMETER ASProviderMSOLAP
        See the notes section for more information.

    .PARAMETER InstallSqlDataDir
        See the notes section for more information.

    .PARAMETER SqlBackupDir
        See the notes section for more information.

    .PARAMETER SecurityMode
        See the notes section for more information.

    .PARAMETER SAPwd
        See the notes section for more information.

    .PARAMETER SqlCollation
        See the notes section for more information.

    .PARAMETER SqlSysAdminAccounts
        See the notes section for more information.

    .PARAMETER SqlTempDbDir
        See the notes section for more information.

    .PARAMETER SqlTempDbLogDir
        See the notes section for more information.

    .PARAMETER SqlTempDbFileCount
        See the notes section for more information.

    .PARAMETER SqlTempDbFileSize
        See the notes section for more information.

    .PARAMETER SqlTempDbFileGrowth
        See the notes section for more information.

    .PARAMETER SqlTempDbLogFileSize
        See the notes section for more information.

    .PARAMETER SqlTempDbLogFileGrowth
        See the notes section for more information.

    .PARAMETER SqlUserDbDir
        See the notes section for more information.

    .PARAMETER SqlUserDbLogDir
        See the notes section for more information.

    .PARAMETER RsInstallMode
        See the notes section for more information.

    .PARAMETER FailoverClusterGroup
        See the notes section for more information.

    .PARAMETER FailoverClusterDisks
        See the notes section for more information.

    .PARAMETER FailoverClusterNetworkName
        See the notes section for more information.

    .PARAMETER FailoverClusterIPAddresses
        See the notes section for more information.

    .PARAMETER ConfirmIPDependencyChange
        See the notes section for more information.

    .PARAMETER ProductCoveredBySA
        See the notes section for more information.

    .LINK
        https://docs.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server-from-the-command-prompt

    .OUTPUTS
        None.

    .EXAMPLE
        Complete-SqlDscFailoverCluster -InstanceName 'MyInstance' -InstallSqlDataDir 'D:\MSSQL\Data' -SqlSysAdminAccounts @('MyAdminAccount') -FailoverClusterNetworkName 'TestCluster01A' -FailoverClusterIPAddresses 'IPv4;192.168.0.46;ClusterNetwork1;255.255.255.0' -MediaPath 'E:\'

        Completes the installation of the SQL Server instance 'MyInstance' in the
        Failover Cluster instance.

    .NOTES
        The parameters are intentionally not described since it would take a lot
        of effort to keep them up to date. Instead there is a link that points to
        the SQL Server command line setup documentation which will stay relevant.
#>
function Complete-SqlDscFailoverCluster
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '', Justification = 'Because ShouldProcess is used in Invoke-SetupAction')]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $MediaPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $InstanceName,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Enu,

        [Parameter()]
        [System.String]
        $ProductKey, # This is argument PID but $PID is reserved variable.

        [Parameter()]
        [System.String]
        $ASBackupDir,

        [Parameter()]
        [System.String]
        $ASCollation,

        [Parameter()]
        [System.String]
        $ASConfigDir,

        [Parameter()]
        [System.String]
        $ASDataDir,

        [Parameter()]
        [System.String]
        $ASLogDir,

        [Parameter()]
        [System.String]
        $ASTempDir,

        [Parameter()]
        [ValidateSet('Multidimensional', 'PowerPivot', 'Tabular')]
        [System.String]
        $ASServerMode,

        [Parameter()]
        [System.String[]]
        $ASSysAdminAccounts,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $ASProviderMSOLAP,

        [Parameter(Mandatory = $true)]
        [System.String]
        $InstallSqlDataDir,

        [Parameter()]
        [System.String]
        $SqlBackupDir,

        [Parameter()]
        [ValidateSet('SQL')]
        [System.String]
        $SecurityMode,

        [Parameter()]
        [System.Security.SecureString]
        $SAPwd,

        [Parameter()]
        [System.String]
        $SqlCollation,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $SqlSysAdminAccounts,

        [Parameter()]
        [System.String]
        $SqlTempDbDir,

        [Parameter()]
        [System.String]
        $SqlTempDbLogDir,

        [Parameter()]
        [System.UInt16]
        $SqlTempDbFileCount,

        [Parameter()]
        [ValidateRange(4, 262144)]
        [System.UInt16]
        $SqlTempDbFileSize,

        [Parameter()]
        [ValidateRange(0, 1024)]
        [System.UInt16]
        $SqlTempDbFileGrowth,

        [Parameter()]
        [ValidateRange(4, 262144)]
        [System.UInt16]
        $SqlTempDbLogFileSize,

        [Parameter()]
        [ValidateRange(0, 1024)]
        [System.UInt16]
        $SqlTempDbLogFileGrowth,

        [Parameter()]
        [System.String]
        $SqlUserDbDir,

        [Parameter()]
        [System.String]
        $SqlUserDbLogDir,

        [Parameter()]
        [ValidateSet('SharePointFilesOnlyMode', 'DefaultNativeMode', 'FilesOnlyMode')]
        [System.String]
        $RsInstallMode,

        [Parameter()]
        [System.String]
        $FailoverClusterGroup,

        [Parameter()]
        [System.String[]]
        $FailoverClusterDisks,

        [Parameter(Mandatory = $true)]
        [System.String]
        $FailoverClusterNetworkName,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $FailoverClusterIPAddresses,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $ConfirmIPDependencyChange,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $ProductCoveredBySA,

        [Parameter()]
        [System.UInt32]
        $Timeout = 7200,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    Invoke-SetupAction -CompleteFailoverCluster @PSBoundParameters
}
#EndRegion '.\Public\Complete-SqlDscFailoverCluster.ps1' 311
#Region '.\Public\Complete-SqlDscImage.ps1' -1

<#
    .SYNOPSIS
        Completes the image installation of an SQL Server instance.

    .DESCRIPTION
        Completes the image installation of an SQL Server instance that was prepared
        using `Install-SqlDscServer` with the parameter `-PrepareImage`.

        See the link in the commands help for information on each parameter. The
        link points to SQL Server command line setup documentation.

    .PARAMETER AcceptLicensingTerms
        Required parameter to be able to run unattended install. By specifying this
        parameter you acknowledge the acceptance all license terms and notices for
        the specified features, the terms and notices that the Microsoft SQL Server
        setup executable normally ask for.

    .PARAMETER MediaPath
        Specifies the path where to find the SQL Server installation media. On this
        path the SQL Server setup executable must be found.

    .PARAMETER Timeout
        Specifies how long to wait for the setup process to finish. Default value
        is `7200` seconds (2 hours). If the setup process does not finish before
        this time, an exception will be thrown.

    .PARAMETER Force
        If specified the command will not ask for confirmation. Same as if Confirm:$false
        is used.

    .PARAMETER InstanceName
        See the notes section for more information.

    .PARAMETER Enu
        See the notes section for more information.

    .PARAMETER InstanceId
        See the notes section for more information.

    .PARAMETER PBEngSvcAccount
        See the notes section for more information.

    .PARAMETER PBEngSvcPassword
        See the notes section for more information.

    .PARAMETER PBEngSvcStartupType
        See the notes section for more information.

    .PARAMETER PBStartPortRange
        See the notes section for more information.

    .PARAMETER PBEndPortRange
        See the notes section for more information.

    .PARAMETER PBScaleOut
        See the notes section for more information.

    .PARAMETER ProductKey
        See the notes section for more information.

    .PARAMETER AgtSvcAccount
        See the notes section for more information.

    .PARAMETER AgtSvcPassword
        See the notes section for more information.

    .PARAMETER AgtSvcStartupType
        See the notes section for more information.

    .PARAMETER BrowserSvcStartupType
        See the notes section for more information.

    .PARAMETER EnableRanU
        See the notes section for more information.

    .PARAMETER InstallSqlDataDir
        See the notes section for more information.

    .PARAMETER SqlBackupDir
        See the notes section for more information.

    .PARAMETER SecurityMode
        See the notes section for more information.

    .PARAMETER SAPwd
        See the notes section for more information.

    .PARAMETER SqlCollation
        See the notes section for more information.

    .PARAMETER SqlSvcAccount
        See the notes section for more information.

    .PARAMETER SqlSvcPassword
        See the notes section for more information.

    .PARAMETER SqlSvcStartupType
        See the notes section for more information.

    .PARAMETER SqlSysAdminAccounts
        See the notes section for more information.

    .PARAMETER SqlTempDbDir
        See the notes section for more information.

    .PARAMETER SqlTempDbLogDir
        See the notes section for more information.

    .PARAMETER SqlTempDbFileCount
        See the notes section for more information.

    .PARAMETER SqlTempDbFileSize
        See the notes section for more information.

    .PARAMETER SqlTempDbFileGrowth
        See the notes section for more information.

    .PARAMETER SqlTempDbLogFileSize
        See the notes section for more information.

    .PARAMETER SqlTempDbLogFileGrowth
        See the notes section for more information.

    .PARAMETER SqlUserDbDir
        See the notes section for more information.

    .PARAMETER SqlUserDbLogDir
        See the notes section for more information.

    .PARAMETER FileStreamLevel
        See the notes section for more information.

    .PARAMETER FileStreamShareName
        See the notes section for more information.

    .PARAMETER NpEnabled
        See the notes section for more information.

    .PARAMETER TcpEnabled
        See the notes section for more information.

    .PARAMETER RsInstallMode
        See the notes section for more information.

    .PARAMETER RSSvcAccount
        See the notes section for more information.

    .PARAMETER RSSvcPassword
        See the notes section for more information.

    .PARAMETER RSSvcStartupType
        See the notes section for more information.

    .PARAMETER ProductCoveredBySA
        See the notes section for more information.

    .LINK
        https://docs.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server-from-the-command-prompt

    .OUTPUTS
        None.

    .EXAMPLE
        Complete-SqlDscImage -AcceptLicensingTerms -MediaPath 'E:\'

        Completes the image installation of the SQL Server default instance that
        was prepared using `Install-SqlDscServer` with the parameter `-PrepareImage`.

    .NOTES
        The parameters are intentionally not described since it would take a lot
        of effort to keep them up to date. Instead there is a link that points to
        the SQL Server command line setup documentation which will stay relevant.
#>
function Complete-SqlDscImage
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '', Justification = 'Because ShouldProcess is used in Invoke-SetupAction')]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $AcceptLicensingTerms,

        [Parameter(Mandatory = $true)]
        [System.String]
        $MediaPath,

        [Parameter()]
        [System.String]
        $InstanceName,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Enu,

        [Parameter()]
        [System.String]
        $InstanceId,

        [Parameter()]
        [System.String]
        $PBEngSvcAccount,

        [Parameter()]
        [System.Security.SecureString]
        $PBEngSvcPassword,

        [Parameter()]
        [ValidateSet('Automatic', 'Disabled', 'Manual')]
        [System.String]
        $PBEngSvcStartupType,

        [Parameter()]
        [System.UInt16]
        $PBStartPortRange,

        [Parameter()]
        [System.UInt16]
        $PBEndPortRange,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $PBScaleOut,

        [Parameter()]
        [System.String]
        $ProductKey, # This is argument PID but $PID is reserved variable.

        [Parameter()]
        [System.String]
        $AgtSvcAccount,

        [Parameter()]
        [System.Security.SecureString]
        $AgtSvcPassword,

        [Parameter()]
        [ValidateSet('Automatic', 'Disabled', 'Manual')]
        [System.String]
        $AgtSvcStartupType,

        [Parameter()]
        [ValidateSet('Automatic', 'Disabled', 'Manual')]
        [System.String]
        $BrowserSvcStartupType,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $EnableRanU,

        [Parameter()]
        [System.String]
        $InstallSqlDataDir,

        [Parameter()]
        [System.String]
        $SqlBackupDir,

        [Parameter()]
        [ValidateSet('SQL')]
        [System.String]
        $SecurityMode,

        [Parameter()]
        [System.Security.SecureString]
        $SAPwd,

        [Parameter()]
        [System.String]
        $SqlCollation,

        [Parameter()]
        [System.String]
        $SqlSvcAccount,

        [Parameter()]
        [System.Security.SecureString]
        $SqlSvcPassword,

        [Parameter()]
        [ValidateSet('Automatic', 'Disabled', 'Manual')]
        [System.String]
        $SqlSvcStartupType,

        [Parameter()]
        [System.String[]]
        $SqlSysAdminAccounts,

        [Parameter()]
        [System.String]
        $SqlTempDbDir,

        [Parameter()]
        [System.String]
        $SqlTempDbLogDir,

        [Parameter()]
        [System.UInt16]
        $SqlTempDbFileCount,

        [Parameter()]
        [ValidateRange(4, 262144)]
        [System.UInt16]
        $SqlTempDbFileSize,

        [Parameter()]
        [ValidateRange(0, 1024)]
        [System.UInt16]
        $SqlTempDbFileGrowth,

        [Parameter()]
        [ValidateRange(4, 262144)]
        [System.UInt16]
        $SqlTempDbLogFileSize,

        [Parameter()]
        [ValidateRange(0, 1024)]
        [System.UInt16]
        $SqlTempDbLogFileGrowth,

        [Parameter()]
        [System.String]
        $SqlUserDbDir,

        [Parameter()]
        [System.String]
        $SqlUserDbLogDir,

        [Parameter()]
        [ValidateRange(0, 3)]
        [System.UInt16]
        $FileStreamLevel,

        [Parameter()]
        [System.String]
        $FileStreamShareName,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $NpEnabled,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $TcpEnabled,

        [Parameter()]
        [ValidateSet('SharePointFilesOnlyMode', 'DefaultNativeMode', 'FilesOnlyMode')]
        [System.String]
        $RsInstallMode,

        [Parameter()]
        [System.String]
        $RSSvcAccount,

        [Parameter()]
        [System.Security.SecureString]
        $RSSvcPassword,

        [Parameter()]
        [ValidateSet('Automatic', 'Disabled', 'Manual')]
        [System.String]
        $RSSvcStartupType,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $ProductCoveredBySA,

        [Parameter()]
        [System.UInt32]
        $Timeout = 7200,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    Invoke-SetupAction -CompleteImage @PSBoundParameters
}
#EndRegion '.\Public\Complete-SqlDscImage.ps1' 380
#Region '.\Public\Connect-SqlDscDatabaseEngine.ps1' -1

<#
    .SYNOPSIS
        Connect to a SQL Server Database Engine and return the server object.

    .DESCRIPTION
        This command connects to a  SQL Server Database Engine instance and returns
        the Server object.

    .PARAMETER ServerName
        String containing the host name of the SQL Server to connect to.
        Default value is the current computer name.

    .PARAMETER InstanceName
        String containing the SQL Server Database Engine instance to connect to.
        Default value is 'MSSQLSERVER'.

    .PARAMETER Credential
        The credentials to use to impersonate a user when connecting to the
        SQL Server Database Engine instance. If this parameter is left out, then
        the current user will be used to connect to the SQL Server Database Engine
        instance using Windows Integrated authentication.

    .PARAMETER LoginType
        Specifies which type of logon credential should be used. The valid types
        are 'WindowsUser' or 'SqlLogin'. Default value is 'WindowsUser'
        If set to 'WindowsUser' then the it will impersonate using the Windows
        login specified in the parameter Credential.
        If set to 'SqlLogin' then it will impersonate using the native SQL
        login specified in the parameter Credential.

    .PARAMETER StatementTimeout
        Set the query StatementTimeout in seconds. Default 600 seconds (10 minutes).

    .PARAMETER Encrypt
        Specifies if encryption should be used.

    .EXAMPLE
        Connect-SqlDscDatabaseEngine

        Connects to the default instance on the local server.

    .EXAMPLE
        Connect-SqlDscDatabaseEngine -InstanceName 'MyInstance'

        Connects to the instance 'MyInstance' on the local server.

    .EXAMPLE
        Connect-SqlDscDatabaseEngine -ServerName 'sql.company.local' -InstanceName 'MyInstance'

        Connects to the instance 'MyInstance' on the server 'sql.company.local'.

    .EXAMPLE
        Connect-SqlDscDatabaseEngine -Credential ([System.Management.Automation.PSCredential]::new('DOMAIN\SqlUser', (ConvertTo-SecureString -String 'MyP@ssw0rd1' -AsPlainText -Force)))

        Connects to the default instance on the local server impersonating the Windows user 'DOMAIN\SqlUser'.

    .EXAMPLE
        Connect-SqlDscDatabaseEngine -LoginType 'SqlLogin' -Credential ([System.Management.Automation.PSCredential]::new('sa', (ConvertTo-SecureString -String 'MyP@ssw0rd1' -AsPlainText -Force)))

        Connects to the default instance on the local server using the SQL login 'sa'.

    .OUTPUTS
        `[Microsoft.SqlServer.Management.Smo.Server]`
#>
function Connect-SqlDscDatabaseEngine
{
    [CmdletBinding(DefaultParameterSetName = 'SqlServer')]
    param
    (
        [Parameter(ParameterSetName = 'SqlServer')]
        [Parameter(ParameterSetName = 'SqlServerWithCredential')]
        [ValidateNotNull()]
        [System.String]
        $ServerName = (Get-ComputerName),

        [Parameter(ParameterSetName = 'SqlServer')]
        [Parameter(ParameterSetName = 'SqlServerWithCredential')]
        [ValidateNotNull()]
        [System.String]
        $InstanceName = 'MSSQLSERVER',

        [Parameter(ParameterSetName = 'SqlServerWithCredential', Mandatory = $true)]
        [ValidateNotNull()]
        [Alias('SetupCredential', 'DatabaseCredential')]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter(ParameterSetName = 'SqlServerWithCredential')]
        [ValidateSet('WindowsUser', 'SqlLogin')]
        [System.String]
        $LoginType = 'WindowsUser',

        [Parameter()]
        [ValidateNotNull()]
        [System.Int32]
        $StatementTimeout = 600,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Encrypt
    )

    # Call the private function.
    return (Connect-Sql @PSBoundParameters)
}
#EndRegion '.\Public\Connect-SqlDscDatabaseEngine.ps1' 106
#Region '.\Public\ConvertFrom-SqlDscDatabasePermission.ps1' -1

<#
    .SYNOPSIS
        Converts a DatabasePermission object into an object of the type
        Microsoft.SqlServer.Management.Smo.DatabasePermissionSet.

    .DESCRIPTION
        Converts a DatabasePermission object into an object of the type
        Microsoft.SqlServer.Management.Smo.DatabasePermissionSet.

    .PARAMETER Permission
        Specifies a DatabasePermission object.

    .EXAMPLE
        [DatabasePermission] @{
            State = 'Grant'
            Permission = 'Connect'
        } | ConvertFrom-SqlDscDatabasePermission

        Returns an object of `[Microsoft.SqlServer.Management.Smo.DatabasePermissionSet]`
        with all the permissions set to $true that was part of the `[DatabasePermission]`.

    .OUTPUTS
        [Microsoft.SqlServer.Management.Smo.DatabasePermissionSet]
#>
function ConvertFrom-SqlDscDatabasePermission
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseSyntacticallyCorrectExamples', '', Justification = 'Because the rule does not yet support parsing the code when the output type is not available. The ScriptAnalyzer rule UseSyntacticallyCorrectExamples will always error in the editor due to https://github.com/indented-automation/Indented.ScriptAnalyzerRules/issues/8.')]
    [CmdletBinding()]
    [OutputType([Microsoft.SqlServer.Management.Smo.DatabasePermissionSet])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [DatabasePermission]
        $Permission
    )

    begin
    {
        $permissionSet = New-Object -TypeName 'Microsoft.SqlServer.Management.Smo.DatabasePermissionSet'
    }

    process
    {
        foreach ($permissionName in $Permission.Permission)
        {
            $permissionSet.$permissionName = $true
        }
    }

    end
    {
        return $permissionSet
    }
}
#EndRegion '.\Public\ConvertFrom-SqlDscDatabasePermission.ps1' 55
#Region '.\Public\ConvertFrom-SqlDscServerPermission.ps1' -1

<#
    .SYNOPSIS
        Converts a ServerPermission object into an object of the type
        Microsoft.SqlServer.Management.Smo.ServerPermissionSet.

    .DESCRIPTION
        Converts a ServerPermission object into an object of the type
        Microsoft.SqlServer.Management.Smo.ServerPermissionSet.

    .PARAMETER Permission
        Specifies a ServerPermission object.

    .EXAMPLE
        [ServerPermission] @{
            State = 'Grant'
            Permission = 'Connect'
        } | ConvertFrom-SqlDscServerPermission

        Returns an object of `[Microsoft.SqlServer.Management.Smo.ServerPermissionSet]`
        with all the permissions set to $true that was part of the `[ServerPermission]`.

    .OUTPUTS
        [Microsoft.SqlServer.Management.Smo.ServerPermissionSet]
#>
function ConvertFrom-SqlDscServerPermission
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseSyntacticallyCorrectExamples', '', Justification = 'Because the rule does not yet support parsing the code when the output type is not available. The ScriptAnalyzer rule UseSyntacticallyCorrectExamples will always error in the editor due to https://github.com/indented-automation/Indented.ScriptAnalyzerRules/issues/8.')]
    [CmdletBinding()]
    [OutputType([Microsoft.SqlServer.Management.Smo.ServerPermissionSet])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ServerPermission]
        $Permission
    )

    begin
    {
        $permissionSet = New-Object -TypeName 'Microsoft.SqlServer.Management.Smo.ServerPermissionSet'
    }

    process
    {
        foreach ($permissionName in $Permission.Permission)
        {
            $permissionSet.$permissionName = $true
        }
    }

    end
    {
        return $permissionSet
    }
}
#EndRegion '.\Public\ConvertFrom-SqlDscServerPermission.ps1' 55
#Region '.\Public\ConvertTo-SqlDscDatabasePermission.ps1' -1

<#
    .SYNOPSIS
        Converts a collection of Microsoft.SqlServer.Management.Smo.DatabasePermissionInfo
        objects into an array of DatabasePermission objects.

    .DESCRIPTION
        Converts a collection of Microsoft.SqlServer.Management.Smo.DatabasePermissionInfo
        objects into an array of DatabasePermission objects.

    .PARAMETER DatabasePermissionInfo
        Specifies a collection of Microsoft.SqlServer.Management.Smo.DatabasePermissionInfo
        objects.

    .EXAMPLE
        $serverInstance = Connect-SqlDscDatabaseEngine
        $databasePermissionInfo = Get-SqlDscDatabasePermission -ServerObject $serverInstance -DatabaseName 'MyDatabase' -Name 'MyPrincipal'
        ConvertTo-SqlDscDatabasePermission -DatabasePermissionInfo $databasePermissionInfo

        Get all permissions for the principal 'MyPrincipal' and converts the permissions
        into an array of `[DatabasePermission[]]`.

    .OUTPUTS
        [DatabasePermission[]]
#>
function ConvertTo-SqlDscDatabasePermission
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseSyntacticallyCorrectExamples', '', Justification = 'Because the rule does not yet support parsing the code when the output type is not available. The ScriptAnalyzer rule UseSyntacticallyCorrectExamples will always error in the editor due to https://github.com/indented-automation/Indented.ScriptAnalyzerRules/issues/8.')]
    [CmdletBinding()]
    [OutputType([DatabasePermission[]])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [AllowEmptyCollection()]
        [Microsoft.SqlServer.Management.Smo.DatabasePermissionInfo[]]
        $DatabasePermissionInfo
    )

    begin
    {
        [DatabasePermission[]] $permissions = @()
    }

    process
    {
        $permissionState = foreach ($currentDatabasePermissionInfo in $DatabasePermissionInfo)
        {
            # Convert from the type PermissionState to String.
            [System.String] $currentDatabasePermissionInfo.PermissionState
        }

        $permissionState = $permissionState | Select-Object -Unique

        foreach ($currentPermissionState in $permissionState)
        {
            $filteredDatabasePermission = $DatabasePermissionInfo |
                Where-Object -FilterScript {
                    $_.PermissionState -eq $currentPermissionState
                }

            $databasePermissionStateExist = $permissions.Where({
                    $_.State -contains $currentPermissionState
                }) |
                Select-Object -First 1

            if ($databasePermissionStateExist)
            {
                $databasePermission = $databasePermissionStateExist
            }
            else
            {
                $databasePermission = [DatabasePermission] @{
                    State      = $currentPermissionState
                    Permission = [System.String[]] @()
                }
            }

            foreach ($currentPermission in $filteredDatabasePermission)
            {
                # Get the permission names that is set to $true
                $permissionProperty = $currentPermission.PermissionType |
                    Get-Member -MemberType 'Property' |
                    Select-Object -ExpandProperty 'Name' -Unique |
                    Where-Object -FilterScript {
                        $currentPermission.PermissionType.$_
                    }


                foreach ($currentPermissionProperty in $permissionProperty)
                {
                    $databasePermission.Permission += $currentPermissionProperty
                }
            }

            # Only add the object if it was created.
            if (-not $databasePermissionStateExist)
            {
                $permissions += $databasePermission
            }
        }
    }

    end
    {
        return $permissions
    }
}
#EndRegion '.\Public\ConvertTo-SqlDscDatabasePermission.ps1' 107
#Region '.\Public\ConvertTo-SqlDscEditionName.ps1' -1

<#
    .SYNOPSIS
        Converts a SQL Server Reporting Services or Power BI Report Server edition
        ID to an edition name.

    .DESCRIPTION
        Converts a SQL Server Reporting Services or Power BI Report Server edition
        ID. The command returns a PSCustomObject containing the EditionId, Edition,
        and EditionName based on a predefined mapping table.

    .PARAMETER Id
        Specifies the edition ID that should be converted.

    .EXAMPLE
        ConvertTo-SqlDscEditionName -Id 2176971986

        Returns information about the edition ID 2176971986.

    .EXAMPLE
        ConvertTo-SqlDscEditionName -Id 2017617798

        Returns information about the edition ID 2017617798.

    .NOTES
        Author: SqlServerDsc
#>
function ConvertTo-SqlDscEditionName
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $Id
    )

    Write-Debug -Message ($script:localizedData.ConvertTo_EditionName_ConvertingEditionId -f $Id)

    $resultObject = [PSCustomObject] @{
        EditionId = $Id
        Edition = ''
        EditionName = ''
    }

    switch ($Id)
    {
        2176971986
        {
            $resultObject.Edition = 'Developer'
            $resultObject.EditionName = 'SQL Server Developer'
        }

        2017617798
        {
            $resultObject.Edition = 'Developer'
            $resultObject.EditionName = 'Power BI Report Server - Developer'
        }

        1369084056
        {
            $resultObject.Edition = 'Evaluation'
            $resultObject.EditionName = 'Power BI Report Server - Evaluation'
        }

        default
        {
            Write-Debug -Message ($script:localizedData.ConvertTo_EditionName_UnknownEditionId -f $Id)

            $resultObject.Edition = 'Unknown'
            $resultObject.EditionName = 'Unknown'
        }
    }

    return $resultObject
}
#EndRegion '.\Public\ConvertTo-SqlDscEditionName.ps1' 77
#Region '.\Public\ConvertTo-SqlDscServerPermission.ps1' -1

<#
    .SYNOPSIS
        Converts a collection of Microsoft.SqlServer.Management.Smo.ServerPermissionInfo
        objects into an array of ServerPermission objects.

    .DESCRIPTION
        Converts a collection of Microsoft.SqlServer.Management.Smo.ServerPermissionInfo
        objects into an array of ServerPermission objects.

    .PARAMETER ServerPermissionInfo
        Specifies a collection of Microsoft.SqlServer.Management.Smo.ServerPermissionInfo
        objects.

    .EXAMPLE
        $serverInstance = Connect-SqlDscDatabaseEngine
        $serverPermissionInfo = Get-SqlDscServerPermission -ServerObject $serverInstance -Name 'MyPrincipal'
        ConvertTo-SqlDscServerPermission -ServerPermissionInfo $serverPermissionInfo

        Get all permissions for the principal 'MyPrincipal' and converts the permissions
        into an array of `[ServerPermission[]]`.

    .OUTPUTS
        [ServerPermission[]]
#>
function ConvertTo-SqlDscServerPermission
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseSyntacticallyCorrectExamples', '', Justification = 'Because the rule does not yet support parsing the code when the output type is not available. The ScriptAnalyzer rule UseSyntacticallyCorrectExamples will always error in the editor due to https://github.com/indented-automation/Indented.ScriptAnalyzerRules/issues/8.')]
    [CmdletBinding()]
    [OutputType([ServerPermission[]])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [AllowEmptyCollection()]
        [Microsoft.SqlServer.Management.Smo.ServerPermissionInfo[]]
        $ServerPermissionInfo
    )

    begin
    {
        [ServerPermission[]] $permissions = @()
    }

    process
    {
        $permissionState = foreach ($currentServerPermissionInfo in $ServerPermissionInfo)
        {
            # Convert from the type PermissionState to String.
            [System.String] $currentServerPermissionInfo.PermissionState
        }

        $permissionState = $permissionState | Select-Object -Unique

        foreach ($currentPermissionState in $permissionState)
        {
            $filteredServerPermission = $ServerPermissionInfo |
                Where-Object -FilterScript {
                    $_.PermissionState -eq $currentPermissionState
                }

            $serverPermissionStateExist = $permissions.Where({
                    $_.State -contains $currentPermissionState
                }) |
                Select-Object -First 1

            if ($serverPermissionStateExist)
            {
                $serverPermission = $serverPermissionStateExist
            }
            else
            {
                $serverPermission = [ServerPermission] @{
                    State      = $currentPermissionState
                    Permission = [System.String[]] @()
                }
            }

            foreach ($currentPermission in $filteredServerPermission)
            {
                # Get the permission names that is set to $true
                $permissionProperty = $currentPermission.PermissionType |
                    Get-Member -MemberType 'Property' |
                    Select-Object -ExpandProperty 'Name' -Unique |
                    Where-Object -FilterScript {
                        $currentPermission.PermissionType.$_
                    }


                foreach ($currentPermissionProperty in $permissionProperty)
                {
                    $serverPermission.Permission += $currentPermissionProperty
                }
            }

            # Only add the object if it was created.
            if (-not $serverPermissionStateExist)
            {
                $permissions += $serverPermission
            }
        }
    }

    end
    {
        return $permissions
    }
}
#EndRegion '.\Public\ConvertTo-SqlDscServerPermission.ps1' 107
#Region '.\Public\Disable-SqlDscAudit.ps1' -1

<#
    .SYNOPSIS
        Disables a server audit.

    .DESCRIPTION
        This command disables a server audit in a SQL Server Database Engine instance.

    .PARAMETER ServerObject
        Specifies current server connection object.

    .PARAMETER AuditObject
        Specifies an audit object to disable.

    .PARAMETER Name
        Specifies the name of the server audit to be disabled.

    .PARAMETER Force
        Specifies that the audit should be disabled without any confirmation.

    .PARAMETER Refresh
        Specifies that the **ServerObject**'s audits should be refreshed before
        trying to disable the audit object. This is helpful when audits could have
        been modified outside of the **ServerObject**, for example through T-SQL.
        But on instances with a large amount of audits it might be better to make
        sure the **ServerObject** is recent enough, or pass in **AuditObject**.

    .EXAMPLE
        $serverObject = Connect-SqlDscDatabaseEngine -InstanceName 'MyInstance'
        $auditObject = $sqlServerObject | Get-SqlDscAudit -Name 'MyFileAudit'
        $auditObject | Disable-SqlDscAudit

        Disables the audit named **MyFileAudit**.

    .EXAMPLE
        $serverObject = Connect-SqlDscDatabaseEngine -InstanceName 'MyInstance'
        $sqlServerObject | Disable-SqlDscAudit -Name 'MyFileAudit'

        Disables the audit named **MyFileAudit**.

    .OUTPUTS
        None.
#>
function Disable-SqlDscAudit
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseSyntacticallyCorrectExamples', '', Justification = 'Because the rule does not yet support parsing the code when a parameter type is not available. The ScriptAnalyzer rule UseSyntacticallyCorrectExamples will always error in the editor due to https://github.com/indented-automation/Indented.ScriptAnalyzerRules/issues/8.')]
    [OutputType()]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param
    (
        [Parameter(ParameterSetName = 'ServerObject', Mandatory = $true, ValueFromPipeline = $true)]
        [Microsoft.SqlServer.Management.Smo.Server]
        $ServerObject,

        [Parameter(ParameterSetName = 'AuditObject', Mandatory = $true, ValueFromPipeline = $true)]
        [Microsoft.SqlServer.Management.Smo.Audit]
        $AuditObject,

        [Parameter(ParameterSetName = 'ServerObject', Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force,

        [Parameter(ParameterSetName = 'ServerObject')]
        [System.Management.Automation.SwitchParameter]
        $Refresh
    )

    process
    {
        if ($Force.IsPresent -and -not $Confirm)
        {
            $ConfirmPreference = 'None'
        }

        if ($PSCmdlet.ParameterSetName -eq 'ServerObject')
        {
            $getSqlDscAuditParameters = @{
                ServerObject = $ServerObject
                Name         = $Name
                Refresh      = $Refresh
                ErrorAction  = 'Stop'
            }

            # If this command does not find the audit it will throw an exception.
            $auditObjectArray = Get-SqlDscAudit @getSqlDscAuditParameters

            # Pick the only object in the array.
            $AuditObject = $auditObjectArray | Select-Object -First 1
        }

        $verboseDescriptionMessage = $script:localizedData.Audit_Disable_ShouldProcessVerboseDescription -f $AuditObject.Name, $AuditObject.Parent.InstanceName
        $verboseWarningMessage = $script:localizedData.Audit_Disable_ShouldProcessVerboseWarning -f $AuditObject.Name
        $captionMessage = $script:localizedData.Audit_Disable_ShouldProcessCaption

        if ($PSCmdlet.ShouldProcess($verboseDescriptionMessage, $verboseWarningMessage, $captionMessage))
        {
            $AuditObject.Disable()
        }
    }
}
#EndRegion '.\Public\Disable-SqlDscAudit.ps1' 104
#Region '.\Public\Disconnect-SqlDscDatabaseEngine.ps1' -1

<#
    .SYNOPSIS
        Disconnect from a SQL Server Database Engine instance.

    .DESCRIPTION
        Disconnect from a SQL Server Database Engine instance.

    .PARAMETER ServerObject
        Specifies a current server connection object.

    .PARAMETER Force
        Specifies that there is no confirmation before disconnect.

    .EXAMPLE
        $serverObject = Connect-SqlDscDatabaseEngine
        Disconnect-SqlDscDatabaseEngine -ServerObject $serverObject

        Connects and then disconnects from the default instance on the local server.

    .EXAMPLE
        Connect-SqlDscDatabaseEngine | Disconnect-SqlDscDatabaseEngine

        Connects and then disconnects from the default instance on the local server.

    .OUTPUTS
        None.
#>
function Disconnect-SqlDscDatabaseEngine
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseSyntacticallyCorrectExamples', '', Justification = 'Because the rule does not yet support parsing the code when a parameter type is not available. The ScriptAnalyzer rule UseSyntacticallyCorrectExamples will always error in the editor due to https://github.com/indented-automation/Indented.ScriptAnalyzerRules/issues/8.')]
    [OutputType([System.Data.DataSet])]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Microsoft.SqlServer.Management.Smo.Server]
        $ServerObject,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    begin
    {
        if ($Force.IsPresent -and -not $Confirm)
        {
            $ConfirmPreference = 'None'
        }
    }

    process
    {
        $verboseDescriptionMessage = $script:localizedData.DatabaseEngine_Disconnect_ShouldProcessVerboseDescription -f $ServerObject.InstanceName
        $verboseWarningMessage = $script:localizedData.DatabaseEngine_Disconnect_ShouldProcessVerboseWarning -f $ServerObject.InstanceName
        $captionMessage = $script:localizedData.DatabaseEngine_Disconnect_ShouldProcessCaption

        if ($PSCmdlet.ShouldProcess($verboseDescriptionMessage, $verboseWarningMessage, $captionMessage))
        {
            $ServerObject.ConnectionContext.Disconnect()
        }
    }
}
#EndRegion '.\Public\Disconnect-SqlDscDatabaseEngine.ps1' 64
#Region '.\Public\Enable-SqlDscAudit.ps1' -1

<#
    .SYNOPSIS
        Enables a server audit.

    .DESCRIPTION
        This command enables a server audit in a SQL Server Database Engine instance.

    .PARAMETER ServerObject
        Specifies current server connection object.

    .PARAMETER AuditObject
        Specifies an audit object to enable.

    .PARAMETER Name
        Specifies the name of the server audit to be enabled.

    .PARAMETER Force
        Specifies that the audit should be enabled without any confirmation.

    .PARAMETER Refresh
        Specifies that the **ServerObject**'s audits should be refreshed before
        trying to enable the audit object. This is helpful when audits could have
        been modified outside of the **ServerObject**, for example through T-SQL.
        But on instances with a large amount of audits it might be better to make
        sure the **ServerObject** is recent enough, or pass in **AuditObject**.

    .EXAMPLE
        $serverObject = Connect-SqlDscDatabaseEngine -InstanceName 'MyInstance'
        $auditObject = $sqlServerObject | Get-SqlDscAudit -Name 'MyFileAudit'
        $auditObject | Enable-SqlDscAudit

        Enables the audit named **MyFileAudit**.

    .EXAMPLE
        $serverObject = Connect-SqlDscDatabaseEngine -InstanceName 'MyInstance'
        $sqlServerObject | Enable-SqlDscAudit -Name 'MyFileAudit'

        Enables the audit named **MyFileAudit**.

    .OUTPUTS
        None.
#>
function Enable-SqlDscAudit
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseSyntacticallyCorrectExamples', '', Justification = 'Because the rule does not yet support parsing the code when a parameter type is not available. The ScriptAnalyzer rule UseSyntacticallyCorrectExamples will always error in the editor due to https://github.com/indented-automation/Indented.ScriptAnalyzerRules/issues/8.')]
    [OutputType()]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param
    (
        [Parameter(ParameterSetName = 'ServerObject', Mandatory = $true, ValueFromPipeline = $true)]
        [Microsoft.SqlServer.Management.Smo.Server]
        $ServerObject,

        [Parameter(ParameterSetName = 'AuditObject', Mandatory = $true, ValueFromPipeline = $true)]
        [Microsoft.SqlServer.Management.Smo.Audit]
        $AuditObject,

        [Parameter(ParameterSetName = 'ServerObject', Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force,

        [Parameter(ParameterSetName = 'ServerObject')]
        [System.Management.Automation.SwitchParameter]
        $Refresh
    )

    process
    {
        if ($Force.IsPresent -and -not $Confirm)
        {
            $ConfirmPreference = 'None'
        }

        if ($PSCmdlet.ParameterSetName -eq 'ServerObject')
        {
            $getSqlDscAuditParameters = @{
                ServerObject = $ServerObject
                Name         = $Name
                Refresh      = $Refresh
                ErrorAction  = 'Stop'
            }

            # If this command does not find the audit it will throw an exception.
            $auditObjectArray = Get-SqlDscAudit @getSqlDscAuditParameters

            # Pick the only object in the array.
            $AuditObject = $auditObjectArray | Select-Object -First 1
        }

        $verboseDescriptionMessage = $script:localizedData.Audit_Enable_ShouldProcessVerboseDescription -f $AuditObject.Name, $AuditObject.Parent.InstanceName
        $verboseWarningMessage = $script:localizedData.Audit_Enable_ShouldProcessVerboseWarning -f $AuditObject.Name
        $captionMessage = $script:localizedData.Audit_Enable_ShouldProcessCaption

        if ($PSCmdlet.ShouldProcess($verboseDescriptionMessage, $verboseWarningMessage, $captionMessage))
        {
            $AuditObject.Enable()
        }
    }
}
#EndRegion '.\Public\Enable-SqlDscAudit.ps1' 104
#Region '.\Public\Get-SqlDscAudit.ps1' -1

<#
    .SYNOPSIS
        Get server audit.

    .DESCRIPTION
        This command gets a server audit from a SQL Server Database Engine instance.

    .PARAMETER ServerObject
        Specifies current server connection object.

    .PARAMETER Name
        Specifies the name of the server audit to get.

    .PARAMETER Refresh
        Specifies that the **ServerObject**'s audits should be refreshed before
        trying get the audit object. This is helpful when audits could have been
        modified outside of the **ServerObject**, for example through T-SQL. But
        on instances with a large amount of audits it might be better to make
        sure the **ServerObject** is recent enough, or pass in **AuditObject**.

    .EXAMPLE
        $serverObject = Connect-SqlDscDatabaseEngine -InstanceName 'MyInstance'
        $sqlServerObject | Get-SqlDscAudit -Name 'MyFileAudit'

        Get the audit named **MyFileAudit**.

    .OUTPUTS
        `[Microsoft.SqlServer.Management.Smo.Audit]`
#>
function Get-SqlDscAudit
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseOutputTypeCorrectly', '', Justification = 'Because the rule does not understands that the command returns [System.String[]] when using , (comma) in the return statement')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseSyntacticallyCorrectExamples', '', Justification = 'Because the rule does not yet support parsing the code when a parameter type is not available. The ScriptAnalyzer rule UseSyntacticallyCorrectExamples will always error in the editor due to https://github.com/indented-automation/Indented.ScriptAnalyzerRules/issues/8.')]
    [OutputType([Microsoft.SqlServer.Management.Smo.Audit[]])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Microsoft.SqlServer.Management.Smo.Server]
        $ServerObject,

        [Parameter()]
        [System.String]
        $Name,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Refresh
    )

    process
    {
        if ($Refresh.IsPresent)
        {
            # Make sure the audits are up-to-date to get any newly created audits.
            $ServerObject.Audits.Refresh()
        }

        $auditObject = @()

        if ($PSBoundParameters.ContainsKey('Name'))
        {
            $auditObject = $ServerObject.Audits[$Name]

            if (-not $AuditObject)
            {
                $missingAuditMessage = $script:localizedData.Audit_Missing -f $Name

                $writeErrorParameters = @{
                    Message      = $missingAuditMessage
                    Category     = 'InvalidOperation'
                    ErrorId      = 'GSDA0001' # cspell: disable-line
                    TargetObject = $Name
                }

                Write-Error @writeErrorParameters
            }
        }
        else
        {
            $auditObject = $ServerObject.Audits
        }

        return , [Microsoft.SqlServer.Management.Smo.Audit[]] $auditObject
    }
}
#EndRegion '.\Public\Get-SqlDscAudit.ps1' 87
#Region '.\Public\Get-SqlDscConfigurationOption.ps1' -1

<#
    .SYNOPSIS
        Get server configuration option.

    .DESCRIPTION
        This command gets the available configuration options from a SQL Server Database Engine instance.

    .PARAMETER ServerObject
        Specifies current server connection object.

    .PARAMETER Name
        Specifies the name of the configuration option to get.

    .PARAMETER Refresh
        Specifies that the **ServerObject**'s configuration property should be
        refreshed before trying get the available configuration options. This is
        helpful when run values or configuration values have been modified outside
        of the specified **ServerObject**.

    .EXAMPLE
        $serverObject = Connect-SqlDscDatabaseEngine -InstanceName 'MyInstance'
        $sqlServerObject | Get-SqlDscConfigurationOption

        Get all the available configuration options.

    .EXAMPLE
        $serverObject = Connect-SqlDscDatabaseEngine -InstanceName 'MyInstance'
        $sqlServerObject | Get-SqlDscConfigurationOption -Name '*threshold*'

        Get the configuration options that contains the word **threshold**.

    .OUTPUTS
        `[Microsoft.SqlServer.Management.Smo.ConfigProperty[]]`
#>
function Get-SqlDscConfigurationOption
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseOutputTypeCorrectly', '', Justification = 'Because the rule does not understands that the command returns [System.String[]] when using , (comma) in the return statement')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseSyntacticallyCorrectExamples', '', Justification = 'Because the rule does not yet support parsing the code when a parameter type is not available. The ScriptAnalyzer rule UseSyntacticallyCorrectExamples will always error in the editor due to https://github.com/indented-automation/Indented.ScriptAnalyzerRules/issues/8.')]
    [OutputType([Microsoft.SqlServer.Management.Smo.ConfigProperty[]])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Microsoft.SqlServer.Management.Smo.Server]
        $ServerObject,

        [Parameter()]
        [System.String]
        $Name,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Refresh
    )

    process
    {
        if ($Refresh.IsPresent)
        {
            # Make sure the configuration option values are up-to-date.
            $serverObject.Configuration.Refresh()
        }

        if ($PSBoundParameters.ContainsKey('Name'))
        {
            $configurationOption = $serverObject.Configuration.Properties |
                Where-Object -FilterScript {
                    $_.DisplayName -like $Name
                }

            if (-not $configurationOption)
            {
                $missingConfigurationOptionMessage = $script:localizedData.ConfigurationOption_Get_Missing -f $Name

                $writeErrorParameters = @{
                    Message      = $missingConfigurationOptionMessage
                    Category     = 'InvalidOperation'
                    ErrorId      = 'GSDCO0001' # cspell: disable-line
                    TargetObject = $Name
                }

                Write-Error @writeErrorParameters
            }
        }
        else
        {
            $configurationOption = $serverObject.Configuration.Properties.ForEach({ $_ })
        }

        return , [Microsoft.SqlServer.Management.Smo.ConfigProperty[]] (
            $configurationOption |
                Sort-Object -Property 'DisplayName'
        )
    }
}
#EndRegion '.\Public\Get-SqlDscConfigurationOption.ps1' 96
#Region '.\Public\Get-SqlDscDatabasePermission.ps1' -1

<#
    .SYNOPSIS
        Returns the current permissions for the database principal.

    .DESCRIPTION
        Returns the current permissions for the database principal.

    .PARAMETER ServerObject
        Specifies current server connection object.

    .PARAMETER DatabaseName
        Specifies the database name.

    .PARAMETER Name
        Specifies the name of the database principal for which the permissions are
        returned.

    .OUTPUTS
        [Microsoft.SqlServer.Management.Smo.DatabasePermissionInfo[]]

    .EXAMPLE
        $serverInstance = Connect-SqlDscDatabaseEngine
        Get-SqlDscDatabasePermission -ServerObject $serverInstance -DatabaseName 'MyDatabase' -Name 'MyPrincipal'

        Get the permissions for the principal 'MyPrincipal'.

    .NOTES
        This command excludes fixed roles like _db_datareader_ by default, and will
        always return `$null` if a fixed role is specified as **Name**.

        If specifying `-ErrorAction 'SilentlyContinue'` then the command will silently
        ignore if the database (parameter **DatabaseName**) is not present or the
        database principal is not present. In such case the command will return `$null`.
        If specifying `-ErrorAction 'Stop'` the command will throw an error if the
        database or database principal is missing.
#>
function Get-SqlDscDatabasePermission
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseOutputTypeCorrectly', '', Justification = 'Because the rule does not understands that the command returns [System.String[]] when using , (comma) in the return statement')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseSyntacticallyCorrectExamples', '', Justification = 'Because the rule does not yet support parsing the code when a parameter type is not available. The ScriptAnalyzer rule UseSyntacticallyCorrectExamples will always error in the editor due to https://github.com/indented-automation/Indented.ScriptAnalyzerRules/issues/8.')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('AvoidThrowOutsideOfTry', '', Justification = 'Because the code throws based on an prior expression')]
    [CmdletBinding()]
    [OutputType([Microsoft.SqlServer.Management.Smo.DatabasePermissionInfo[]])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Microsoft.SqlServer.Management.Smo.Server]
        $ServerObject,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DatabaseName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    # cSpell: ignore GSDDP
    process
    {
        $getSqlDscDatabasePermissionResult = $null

        $sqlDatabaseObject = $null

        if ($ServerObject.Databases)
        {
            $sqlDatabaseObject = $ServerObject.Databases[$DatabaseName]
        }

        if ($sqlDatabaseObject)
        {
            $testSqlDscIsDatabasePrincipalParameters = @{
                ServerObject      = $ServerObject
                DatabaseName      = $DatabaseName
                Name              = $Name
                ExcludeFixedRoles = $true
            }

            $isDatabasePrincipal = Test-SqlDscIsDatabasePrincipal @testSqlDscIsDatabasePrincipalParameters

            if ($isDatabasePrincipal)
            {
                $getSqlDscDatabasePermissionResult = $sqlDatabaseObject.EnumDatabasePermissions($Name)
            }
            else
            {
                $missingPrincipalMessage = $script:localizedData.DatabasePermission_MissingPrincipal -f $Name, $DatabaseName

                Write-Error -Message $missingPrincipalMessage -Category 'InvalidOperation' -ErrorId 'GSDDP0001' -TargetObject $Name
            }
        }
        else
        {
            $missingDatabaseMessage = $script:localizedData.DatabasePermission_MissingDatabase -f $DatabaseName

            Write-Error -Message $missingDatabaseMessage -Category 'InvalidOperation' -ErrorId 'GSDDP0002' -TargetObject $DatabaseName
        }

        return , [Microsoft.SqlServer.Management.Smo.DatabasePermissionInfo[]] $getSqlDscDatabasePermissionResult
    }
}
#EndRegion '.\Public\Get-SqlDscDatabasePermission.ps1' 103
#Region '.\Public\Get-SqlDscInstalledInstance.ps1' -1

<#
    .SYNOPSIS
        Returns the installed instances on the current node.

    .DESCRIPTION
        Returns the installed instances on the current node.

    .PARAMETER InstanceName
       Specifies the instance name to return instances for.

    .PARAMETER ServiceType
        Specifies the service type to filter instances by. Valid values are
        'DatabaseEngine', 'AnalysisServices', and 'ReportingServices'.

    .OUTPUTS
        `[System.Object[]]`

    .EXAMPLE
        Get-SqlDscInstalledInstance

        Returns all installed instances.
#>
function Get-SqlDscInstalledInstance
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter()]
        [System.String]
        $InstanceName,

        [Parameter()]
        [ValidateSet('DatabaseEngine', 'AnalysisServices', 'ReportingServices')]
        [System.String[]]
        $ServiceType
    )

    if ($PSBoundParameters.ContainsKey('InstanceName'))
    {
        $InstanceName = $InstanceName.ToUpper()
    }

    $instances = @()

    $installedServiceType = Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names' -ErrorAction 'SilentlyContinue'

    foreach ($currentServiceType in $installedServiceType)
    {
        $serviceTypeName = switch ($currentServiceType.PSChildName)
        {
            'OLAP'
            {
                'AnalysisServices'

                break
            }

            'SQL'
            {
                'DatabaseEngine'

                break
            }

           'RS'
            {
                'ReportingServices'

                break
            }
        }

        if ($PSBoundParameters.ContainsKey('ServiceType') -and $serviceTypeName -notin $ServiceType)
        {
            continue
        }

        $instanceNames = $currentServiceType.GetValueNames()

        foreach ($currentInstanceName in $instanceNames)
        {
            if ($PSBoundParameters.ContainsKey('InstanceName') -and $currentInstanceName -ne $InstanceName)
            {
                continue
            }

            $foundInstance = [PSCustomObject] @{
                ServiceType = $serviceTypeName
                InstanceName = $currentInstanceName
                InstanceId = $currentServiceType.GetValue($currentInstanceName)
            }

            $instances += $foundInstance
        }
    }

    return $instances
}
#EndRegion '.\Public\Get-SqlDscInstalledInstance.ps1' 100
#Region '.\Public\Get-SqlDscManagedComputer.ps1' -1

<#
    .SYNOPSIS
        Returns the managed computer object.

    .DESCRIPTION
        Returns the managed computer object, by default for the node the command
        is run on.

    .PARAMETER ServerName
       Specifies the server name for which to return the managed computer object.

    .EXAMPLE
        Get-SqlDscManagedComputer

        Returns the managed computer object for the current node.

    .EXAMPLE
        Get-SqlDscManagedComputer -ServerName 'MyServer'

        Returns the managed computer object for the server 'MyServer'.

    .OUTPUTS
        `[Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer]`
#>
function Get-SqlDscManagedComputer
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseSyntacticallyCorrectExamples', '', Justification = 'Because the rule does not yet support parsing the code when the output type is not available. The ScriptAnalyzer rule UseSyntacticallyCorrectExamples will always error in the editor due to https://github.com/indented-automation/Indented.ScriptAnalyzerRules/issues/8.')]    [OutputType([Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer])]
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String]
        $ServerName = (Get-ComputerName)
    )

    Write-Verbose -Message (
        $script:localizedData.ManagedComputer_GetState -f $ServerName
    )

    $managedComputerObject = New-Object -TypeName 'Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer' -ArgumentList $ServerName

    return $managedComputerObject
}
#EndRegion '.\Public\Get-SqlDscManagedComputer.ps1' 44
#Region '.\Public\Get-SqlDscManagedComputerService.ps1' -1

<#
    .SYNOPSIS
        Returns one or more managed computer service objects.

    .DESCRIPTION
        Returns one or more managed computer service objects, by default for the
        node the command is run on.

    .PARAMETER ManagedComputerObject
        Specifies the Managed Computer object to return the services from.

    .PARAMETER ServerName
       Specifies the server name to return the services from.

    .PARAMETER InstanceName
       Specifies the instance name to return the services for, this will exclude
       any service that does not have the instance name in the service name.

    .PARAMETER ServiceType
       Specifies one or more service types to return the services for.

    .EXAMPLE
        Get-SqlDscManagedComputer | Get-SqlDscManagedComputerService

        Returns all the managed computer service objects for the current node.

    .EXAMPLE
        Get-SqlDscManagedComputerService

        Returns all the managed computer service objects for the current node.

    .EXAMPLE
        Get-SqlDscManagedComputerService -ServerName 'MyServer'

        Returns all the managed computer service objects for the server 'MyServer'.

    .EXAMPLE
        Get-SqlDscManagedComputerService -ServiceType 'DatabaseEngine','AnalysisServices'

        Returns all the managed computer service objects for service types
        'DatabaseEngine' and 'AnalysisServices'.

    .EXAMPLE
        Get-SqlDscManagedComputerService -InstanceName 'SQL2022'

        Returns all the managed computer service objects for instance SQL2022.

    .OUTPUTS
        `[Microsoft.SqlServer.Management.Smo.Wmi.Service[]]`
#>
function Get-SqlDscManagedComputerService
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseSyntacticallyCorrectExamples', '', Justification = 'Because the rule does not yet support parsing the code when the output type is not available. The ScriptAnalyzer rule UseSyntacticallyCorrectExamples will always error in the editor due to https://github.com/indented-automation/Indented.ScriptAnalyzerRules/issues/8.')]    [OutputType([Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer])]
    [OutputType([Microsoft.SqlServer.Management.Smo.Wmi.Service[]])]
    [CmdletBinding(DefaultParameterSetName = 'ByServerName')]
    param
    (
        [Parameter(ParameterSetName = 'ByServerObject', Mandatory = $true, ValueFromPipeline = $true)]
        [Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer]
        $ManagedComputerObject,

        [Parameter(ParameterSetName = 'ByServerName')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ServerName = (Get-ComputerName),

        [Parameter()]
        [System.String[]]
        $InstanceName,

        [Parameter()]
        [ValidateSet('DatabaseEngine', 'SQLServerAgent', 'Search', 'IntegrationServices', 'AnalysisServices', 'ReportingServices', 'SQLServerBrowser', 'NotificationServices')]
        [System.String[]]
        $ServiceType
    )

    begin
    {
        if ($PSCmdlet.ParameterSetName -eq 'ByServerName')
        {
            $ManagedComputerObject = Get-SqlDscManagedComputer -ServerName $ServerName
        }

        Write-Verbose -Message (
            $script:localizedData.ManagedComputerService_GetState -f $ServerName
        )

        $serviceObject = $null
    }

    process
    {
        if ($ManagedComputerObject)
        {
            if ($serviceObject)
            {
                $serviceObject += $ManagedComputerObject.Services
            }
            else
            {
                $serviceObject = $ManagedComputerObject.Services
            }
        }
    }

    end
    {
        if ($serviceObject)
        {
            if ($PSBoundParameters.ContainsKey('ServiceType'))
            {
                $managedServiceType = $ServiceType |
                    ConvertTo-ManagedServiceType

                $serviceObject = $serviceObject |
                    Where-Object -FilterScript {
                        $_.Type -in $managedServiceType
                    }
            }

            if ($PSBoundParameters.ContainsKey('InstanceName'))
            {
                $serviceObject = $serviceObject |
                    Where-Object -FilterScript {
                        $_.Name -match ('\${0}$' -f $InstanceName)
                    }
            }
        }

        return $serviceObject
    }
}
#EndRegion '.\Public\Get-SqlDscManagedComputerService.ps1' 133
#Region '.\Public\Get-SqlDscPreferredModule.ps1' -1

<#
    .SYNOPSIS
        Get the first available (preferred) module that is installed.

    .DESCRIPTION
        Get the first available (preferred) module that is installed.

        If the environment variable `SMODefaultModuleName` is set to a module name
        that name will be used as the preferred module name instead of the default
        module 'SqlServer'.

        If the envrionment variable `SMODefaultModuleVersion` is set, then that
        specific version of the preferred module will be searched for.

    .PARAMETER Name
        Specifies the list of the (preferred) modules to search for, in order.
        Defaults to 'SqlServer' and then 'SQLPS'.

    .PARAMETER Refresh
        Specifies if the session environment variable PSModulePath should be refreshed
        with the paths from other environment variable targets (Machine and User).

    .EXAMPLE
        Get-SqlDscPreferredModule

        Returns the SqlServer PSModuleInfo object if it is installed, otherwise it
        will return SQLPS PSModuleInfo object if is is installed. If neither is
        installed `$null` is returned.

    .EXAMPLE
        Get-SqlDscPreferredModule -Refresh

        Updates the session environment variable PSModulePath and then returns the
        SqlServer PSModuleInfo object if it is installed, otherwise it will return SQLPS
        PSModuleInfo object if is is installed. If neither is installed `$null` is
        returned.

    .EXAMPLE
        Get-SqlDscPreferredModule -Name @('MyModule', 'SQLPS')

        Returns the MyModule PSModuleInfo object if it is installed, otherwise it will
        return SQLPS PSModuleInfo object if is is installed. If neither is installed
        `$null` is returned.

    .NOTES

#>
function Get-SqlDscPreferredModule
{
    [OutputType([PSModuleInfo])]
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String[]]
        $Name,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Refresh
    )

    if (-not $PSBoundParameters.ContainsKey('Name'))
    {
        if ($env:SMODefaultModuleName)
        {
            $Name = @($env:SMODefaultModuleName, 'SQLPS')
        }
        else
        {
            $Name = @('SqlServer', 'SQLPS')
        }
    }

    if ($Refresh.IsPresent)
    {
        # Only run on Windows that has Machine state.
        if (-not ($IsLinux -or $IsMacOS))
        {
            <#
                After installing SQL Server the current PowerShell session doesn't know
                about the new path that was added for the SQLPS module. This reloads
                PowerShell session environment variable PSModulePath to make sure it
                contains all paths.
            #>

            $modulePath = Get-PSModulePath -FromTarget 'Session', 'User', 'Machine'

            Set-PSModulePath -Path $modulePath
        }
    }

    $availableModule = $null

    $availableModules = Get-Module -Name $Name -ListAvailable |
        ForEach-Object -Process {
            @{
                PSModuleInfo      = $_
                CalculatedVersion = $_ | Get-SMOModuleCalculatedVersion
            }
        }

    foreach ($preferredModuleName in $Name)
    {
        $preferredModules = $availableModules |
            Where-Object -FilterScript { $_.PSModuleInfo.Name -eq $preferredModuleName }

        if ($preferredModules)
        {
            if ($env:SMODefaultModuleVersion)
            {
                # Get the version specified in $env:SMODefaultModuleVersion if available
                $availableModule = $preferredModules |
                    Where-Object -FilterScript { $_.CalculatedVersion -eq $env:SMODefaultModuleVersion } |
                    Select-Object -First 1
            }
            else
            {
                # Get the latest version if available
                $availableModule = $preferredModules |
                    Sort-Object -Property { ($_.CalculatedVersion -replace '-.+$') -as [System.Version] }, { $_.CalculatedVersion } -Descending |
                    Select-Object -First 1
            }

            Write-Verbose -Message ($script:localizedData.PreferredModule_ModuleVersionFound -f $availableModule.PSModuleInfo.Name, $availableModule.CalculatedVersion)

            break
        }
    }

    if (-not $availableModule)
    {
        $errorMessage = $null

        if ($env:SMODefaultModuleVersion)
        {
            $errorMessage = $script:localizedData.PreferredModule_ModuleVersionNotFound -f $env:SMODefaultModuleVersion
        }
        else
        {
            $errorMessage = $script:localizedData.PreferredModule_ModuleNotFound
        }

        # cSpell: disable-next
        Write-Error -Message $errorMessage -Category 'ObjectNotFound' -ErrorId 'GSDPM0001' -TargetObject ($Name -join ', ')
    }

    return $availableModule.PSModuleInfo
}
#EndRegion '.\Public\Get-SqlDscPreferredModule.ps1' 150
#Region '.\Public\Get-SqlDscRSSetupConfiguration.ps1' -1

<#
    .SYNOPSIS
        Gets the SQL Server Reporting Services or Power BI Report Server setup
        configuration from the Registry.

    .DESCRIPTION
        Gets the SQL Server Reporting Services and Power BI Report Server setup
        configuration information from the Registry. This includes information like
        instance name, installation folder, service name, error dump directory,
        customer feedback settings, error reporting settings, virtual root, configuration
        file path, and various version information of the installed Reporting Services
        instance.

        When no InstanceName is specified, it returns configuration information for all
        installed Reporting Services instances.

    .PARAMETER InstanceName
        Specifies the instance name to return configuration information for.
        If not specified, configuration information for all Reporting Services
        and Power BI Report Server instances will be returned.

    .EXAMPLE
        Get-SqlDscRSSetupConfiguration

        Returns configuration information about all SQL Server Reporting Services
        and Power BI Report Server instances.

    .EXAMPLE
        Get-SqlDscRSSetupConfiguration -InstanceName 'SSRS'

        Returns configuration information about the SQL Server Reporting Services
        instance 'SSRS'.

    .EXAMPLE
        Get-SqlDscRSSetupConfiguration -InstanceName 'PBIRS'

        Returns configuration information about the Power BI Report Server
        instance 'PBIRS'.

    .OUTPUTS
        Returns a PSCustomObject with the following properties:
        - InstanceName: The name of the Reporting Services instance.
        - InstallFolder: The installation folder path.
        - ServiceName: The name of the service.
        - ErrorDumpDirectory: The path to the error dump directory.
        - CustomerFeedback: Whether customer feedback is enabled.
        - EnableErrorReporting: Whether error reporting is enabled.
        - ProductVersion: The product version from registry.
        - CurrentVersion: The current version from registry.
        - VirtualRootServer: The virtual root server value.
        - ConfigFilePath: The path to the report server configuration file.
        - EditionID: The edition ID of the Reporting Services instance.
        - EditionName: The edition name of the Reporting Services instance.
        - IsSharePointIntegrated: Whether the instance is SharePoint integrated.
          MSReportServer_Instance.
        - InstanceId: The instance ID of the Reporting Services instance.
#>
function Get-SqlDscRSSetupConfiguration
{
    # cSpell: ignore PBIRS
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param
    (
        [Parameter()]
        [System.String]
        $InstanceName
    )

    $reportingServicesInstances = @()

    # Get all Reporting Services instances or filter by specified instance name
    $getInstalledInstanceParams = @{
        ServiceType = 'ReportingServices'
    }

    if ($PSBoundParameters.ContainsKey('InstanceName'))
    {
        Write-Verbose -Message ($script:localizedData.Get_SqlDscRSSetupConfiguration_GetSpecificInstance -f $InstanceName)

        $getInstalledInstanceParams.InstanceName = $InstanceName
    }
    else
    {
        Write-Verbose -Message $script:localizedData.Get_SqlDscRSSetupConfiguration_GetAllInstances
    }

    $instances = Get-SqlDscInstalledInstance @getInstalledInstanceParams

    foreach ($instance in $instances)
    {
        Write-Verbose -Message ($script:localizedData.Get_SqlDscRSSetupConfiguration_ProcessingInstance -f $instance.InstanceName)

        $returnObject = [PSCustomObject]@{
            InstanceName                  = $instance.InstanceName
            InstallFolder                 = $null
            ServiceName                   = $null
            ErrorDumpDirectory            = $null
            CurrentVersion                = $null
            CustomerFeedback              = $null
            EnableErrorReporting          = $null
            ProductVersion                = $null
            VirtualRootServer             = $null
            ConfigFilePath                = $null
            EditionID                     = $null
            EditionName                   = $null
            IsSharePointIntegrated        = $null
            InstanceId                    = $null
        }

        Write-Verbose -Message ($script:localizedData.Get_SqlDscRSSetupConfiguration_FoundInstance -f $instance.InstanceName)

        $getRegistryPropertyValueParameters = @{
            ErrorAction = 'SilentlyContinue'
        }

        # Get values from SSRS\Setup registry key
        $getRegistryPropertyValueParameters.Path = 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\{0}\Setup' -f $instance.InstanceName

        # InstallRootDirectory
        $getRegistryPropertyValueParameters.Name = 'InstallRootDirectory'
        $returnObject.InstallFolder = Get-RegistryPropertyValue @getRegistryPropertyValueParameters

        # ServiceName
        $getRegistryPropertyValueParameters.Name = 'ServiceName'
        $returnObject.ServiceName = Get-RegistryPropertyValue @getRegistryPropertyValueParameters

        # RSVirtualRootServer
        $getRegistryPropertyValueParameters.Name = 'RSVirtualRootServer'
        $returnObject.VirtualRootServer = Get-RegistryPropertyValue @getRegistryPropertyValueParameters

        # RsConfigFilePath
        $getRegistryPropertyValueParameters.Name = 'RsConfigFilePath'
        $returnObject.ConfigFilePath = Get-RegistryPropertyValue @getRegistryPropertyValueParameters

        # Get values from SSRS\CPE registry key
        $getRegistryPropertyValueParameters.Path = 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\{0}\CPE' -f $instance.InstanceName

        # ErrorDumpDir
        $getRegistryPropertyValueParameters.Name = 'ErrorDumpDir'
        $returnObject.ErrorDumpDirectory = Get-RegistryPropertyValue @getRegistryPropertyValueParameters

        # CustomerFeedback
        $getRegistryPropertyValueParameters.Name = 'CustomerFeedback'
        $returnObject.CustomerFeedback = Get-RegistryPropertyValue @getRegistryPropertyValueParameters

        # EnableErrorReporting
        $getRegistryPropertyValueParameters.Name = 'EnableErrorReporting'
        $returnObject.EnableErrorReporting = Get-RegistryPropertyValue @getRegistryPropertyValueParameters

        # Get values from SSRS\MSSQLServer\CurrentVersion registry key
        $getRegistryPropertyValueParameters.Path = 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\{0}\MSSQLServer\CurrentVersion' -f $instance.InstanceName

        # CurrentVersion from registry
        $getRegistryPropertyValueParameters.Name = 'CurrentVersion'
        $returnObject.CurrentVersion = Get-RegistryPropertyValue @getRegistryPropertyValueParameters

        # ProductVersion
        $getRegistryPropertyValueParameters.Name = 'ProductVersion'
        $returnObject.ProductVersion = Get-RegistryPropertyValue @getRegistryPropertyValueParameters

        if (-not [System.String]::IsNullOrEmpty($returnObject.CurrentVersion))
        {
            $reportServerCurrentVersion = [System.Version] $returnObject.CurrentVersion

            # Get values from MSReportServer_Instance
            $msReportServerInstance = Get-CimInstance -Namespace ('root\Microsoft\SqlServer\ReportServer\RS_{0}\v{1}' -f $instance.InstanceName, $reportServerCurrentVersion.Major) -ClassName 'MSReportServer_Instance' -ErrorAction 'SilentlyContinue'

            if ($msReportServerInstance)
            {
                $returnObject.EditionID = $msReportServerInstance.EditionID
                $returnObject.EditionName = $msReportServerInstance.EditionName
                $returnObject.IsSharePointIntegrated = $msReportServerInstance.IsSharePointIntegrated
                $returnObject.InstanceId = $msReportServerInstance.InstanceId
            }
        }

        $reportingServicesInstances += $returnObject
    }

    if ($reportingServicesInstances.Count -eq 0)
    {
        if ($PSBoundParameters.ContainsKey('InstanceName'))
        {
            Write-Verbose -Message ($script:localizedData.Get_SqlDscRSSetupConfiguration_InstanceNotFound -f $InstanceName)
        }
        else
        {
            Write-Verbose -Message $script:localizedData.Get_SqlDscRSSetupConfiguration_NoInstancesFound
        }
    }

    return $reportingServicesInstances
}
#EndRegion '.\Public\Get-SqlDscRSSetupConfiguration.ps1' 195
#Region '.\Public\Get-SqlDscServerPermission.ps1' -1

<#
    .SYNOPSIS
        Returns the current permissions for the principal.

    .DESCRIPTION
        Returns the current permissions for the principal.

    .PARAMETER ServerObject
        Specifies current server connection object.

    .PARAMETER Name
        Specifies the name of the principal for which the permissions are
        returned.

    .OUTPUTS
        [Microsoft.SqlServer.Management.Smo.ServerPermissionInfo[]]

    .EXAMPLE
        $serverInstance = Connect-SqlDscDatabaseEngine
        Get-SqlDscServerPermission -ServerObject $serverInstance -Name 'MyPrincipal'

        Get the permissions for the principal 'MyPrincipal'.

    .NOTES
        If specifying `-ErrorAction 'SilentlyContinue'` then the command will silently
        ignore if the principal (parameter **Name**) is not present. In such case the
        command will return `$null`. If specifying `-ErrorAction 'Stop'` the command
        will throw an error if the principal is missing.
#>
function Get-SqlDscServerPermission
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseOutputTypeCorrectly', '', Justification = 'Because the rule does not understands that the command returns [System.String[]] when using , (comma) in the return statement')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseSyntacticallyCorrectExamples', '', Justification = 'Because the rule does not yet support parsing the code when a parameter type is not available. The ScriptAnalyzer rule UseSyntacticallyCorrectExamples will always error in the editor due to https://github.com/indented-automation/Indented.ScriptAnalyzerRules/issues/8.')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('AvoidThrowOutsideOfTry', '', Justification = 'Because the code throws based on an prior expression')]
    [CmdletBinding()]
    [OutputType([Microsoft.SqlServer.Management.Smo.ServerPermissionInfo[]])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Microsoft.SqlServer.Management.Smo.Server]
        $ServerObject,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    # cSpell: ignore GSDSP
    process
    {
        $getSqlDscServerPermissionResult = $null

        $testSqlDscIsLoginParameters = @{
            ServerObject = $ServerObject
            Name         = $Name
        }

        $isLogin = Test-SqlDscIsLogin @testSqlDscIsLoginParameters

        if ($isLogin)
        {
            $getSqlDscServerPermissionResult = $ServerObject.EnumServerPermissions($Name)
        }
        else
        {
            $missingPrincipalMessage = $script:localizedData.ServerPermission_MissingPrincipal -f $Name, $ServerObject.InstanceName

            Write-Error -Message $missingPrincipalMessage -Category 'InvalidOperation' -ErrorId 'GSDSP0001' -TargetObject $Name
        }

        return , [Microsoft.SqlServer.Management.Smo.ServerPermissionInfo[]] $getSqlDscServerPermissionResult
    }
}
#EndRegion '.\Public\Get-SqlDscServerPermission.ps1' 74
#Region '.\Public\Get-SqlDscStartupParameter.ps1' -1

<#
    .SYNOPSIS
        Get current startup parameters on a Database Engine instance.

    .DESCRIPTION
        Get current startup parameters on a Database Engine instance.

    .PARAMETER ServiceObject
        Specifies the Service object to return the trace flags from.

    .PARAMETER ServerName
       Specifies the server name to return the trace flags from.

    .PARAMETER InstanceName
       Specifies the instance name to return the trace flags for.

    .EXAMPLE
        Get-SqlDscStartupParameter

        Get the startup parameters from the Database Engine default instance on
        the server where the command in run.

    .EXAMPLE
        $serviceObject = Get-SqlDscManagedComputerService -ServiceType 'DatabaseEngine'
        Get-SqlDscStartupParameter -ServiceObject $serviceObject

        Get the startup parameters from the Database Engine default instance on
        the server where the command in run.

    .EXAMPLE
        Get-SqlDscStartupParameter -InstanceName 'SQL2022'

        Get the startup parameters from the Database Engine instance 'SQL2022' on
        the server where the command in run.

    .EXAMPLE
        $serviceObject = Get-SqlDscManagedComputerService -ServiceType 'DatabaseEngine' -InstanceName 'SQL2022'
        Get-SqlDscStartupParameter -ServiceObject $serviceObject

        Get the startup parameters from the Database Engine instance 'SQL2022' on
        the server where the command in run.

    .OUTPUTS
        `[StartupParameters]`
#>
function Get-SqlDscStartupParameter
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseSyntacticallyCorrectExamples', '', Justification = 'Because the rule does not yet support parsing the code when a parameter type is not available. The ScriptAnalyzer rule UseSyntacticallyCorrectExamples will always error in the editor due to https://github.com/indented-automation/Indented.ScriptAnalyzerRules/issues/8.')]
    [OutputType([StartupParameters])]
    [CmdletBinding(DefaultParameterSetName = 'ByServerName')]
    param
    (
        [Parameter(ParameterSetName = 'ByServiceObject', Mandatory = $true)]
        [Microsoft.SqlServer.Management.Smo.Wmi.Service]
        $ServiceObject,

        [Parameter(ParameterSetName = 'ByServerName')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ServerName = (Get-ComputerName),

        [Parameter(ParameterSetName = 'ByServerName')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $InstanceName = 'MSSQLSERVER'
    )

    Assert-ElevatedUser -ErrorAction 'Stop'

    if ($PSCmdlet.ParameterSetName -eq 'ByServiceObject')
    {
        $ServiceObject | Assert-ManagedServiceType -ServiceType 'DatabaseEngine'
    }

    if ($PSCmdlet.ParameterSetName -eq 'ByServerName')
    {
        $getSqlDscManagedComputerServiceParameters = @{
            ServerName   = $ServerName
            InstanceName = $InstanceName
            ServiceType  = 'DatabaseEngine'
        }

        $ServiceObject = Get-SqlDscManagedComputerService @getSqlDscManagedComputerServiceParameters

        if (-not $ServiceObject)
        {
            $writeErrorParameters = @{
                Message      = $script:localizedData.StartupParameter_Get_FailedToFindServiceObject
                Category     = 'InvalidOperation'
                ErrorId      = 'GSDSP0001' # CSpell: disable-line
                TargetObject = $ServiceObject
            }

            Write-Error @writeErrorParameters
        }
    }

    Write-Verbose -Message (
        $script:localizedData.StartupParameter_Get_ReturnStartupParameters -f $InstanceName, $ServerName
    )

    $startupParameters = $null

    if ($ServiceObject.StartupParameters)
    {
        $startupParameters = [StartupParameters]::Parse($ServiceObject.StartupParameters)
    }
    else
    {
        Write-Debug -Message ($script:localizedData.StartupParameter_Get_FailedToFindStartupParameters -f $MyInvocation.MyCommand)
    }

    return $startupParameters
}
#EndRegion '.\Public\Get-SqlDscStartupParameter.ps1' 115
#Region '.\Public\Get-SqlDscTraceFlag.ps1' -1

<#
    .SYNOPSIS
        Get current trace flags on a Database Engine instance.

    .DESCRIPTION
        Get current trace flags on a Database Engine instance.

    .PARAMETER ServiceObject
        Specifies the Service object to return the trace flags from.

    .PARAMETER ServerName
       Specifies the server name to return the trace flags from.

    .PARAMETER InstanceName
       Specifies the instance name to return the trace flags for.

    .EXAMPLE
        Get-SqlDscTraceFlag

        Get all the trace flags from the Database Engine default instance on the
        server where the command in run.

    .EXAMPLE
        $serviceObject = Get-SqlDscManagedComputerService -ServiceType 'DatabaseEngine'
        Get-SqlDscTraceFlag -ServiceObject $serviceObject

        Get all the trace flags from the Database Engine default instance on the
        server where the command in run.

    .EXAMPLE
        Get-SqlDscTraceFlag -InstanceName 'SQL2022'

        Get all the trace flags from the Database Engine instance 'SQL2022' on the
        server where the command in run.

    .EXAMPLE
        $serviceObject = Get-SqlDscManagedComputerService -ServiceType 'DatabaseEngine' -InstanceName 'SQL2022'
        Get-SqlDscTraceFlag -ServiceObject $serviceObject

        Get all the trace flags from the Database Engine instance 'SQL2022' on the
        server where the command in run.

    .OUTPUTS
        `[System.UInt32[]]`
#>
function Get-SqlDscTraceFlag
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseOutputTypeCorrectly', '', Justification = 'Because the rule does not understands that the command returns [System.UInt32[]] when using , (comma) in the return statement')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseSyntacticallyCorrectExamples', '', Justification = 'Because the rule does not yet support parsing the code when a parameter type is not available. The ScriptAnalyzer rule UseSyntacticallyCorrectExamples will always error in the editor due to https://github.com/indented-automation/Indented.ScriptAnalyzerRules/issues/8.')]
    [OutputType([System.UInt32[]])]
    [CmdletBinding(DefaultParameterSetName = 'ByServerName')]
    param
    (
        [Parameter(ParameterSetName = 'ByServiceObject', Mandatory = $true)]
        [Microsoft.SqlServer.Management.Smo.Wmi.Service]
        $ServiceObject,

        [Parameter(ParameterSetName = 'ByServerName')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ServerName = (Get-ComputerName),

        [Parameter(ParameterSetName = 'ByServerName')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $InstanceName = 'MSSQLSERVER'
    )

    Write-Verbose -Message (
        $script:localizedData.TraceFlag_Get_ReturnTraceFlags -f $InstanceName, $ServerName
    )

    $startupParameter = Get-SqlDscStartupParameter @PSBoundParameters

    $traceFlags = [System.UInt32[]] @()

    if ($startupParameter)
    {
        $traceFlags = $startupParameter.TraceFlag
    }

    Write-Debug -Message (
        $script:localizedData.TraceFlag_Get_DebugReturningTraceFlags -f $MyInvocation.MyCommand, ($traceFlags -join ', ')
    )

    return , [System.UInt32[]] $traceFlags
}
#EndRegion '.\Public\Get-SqlDscTraceFlag.ps1' 88
#Region '.\Public\Import-SqlDscPreferredModule.ps1' -1

<#
    .SYNOPSIS
        Imports a (preferred) module in a standardized way.

    .DESCRIPTION
        Imports a (preferred) module in a standardized way. If the parameter `Name`
        is not specified the command will imports the default module SqlServer
        if it exist, otherwise SQLPS.

        If the environment variable `SMODefaultModuleName` is set to a module name
        that name will be used as the preferred module name instead of the default
        module 'SqlServer'.

        The module is always imported globally.

    .PARAMETER Name
        Specifies the name of a preferred module.

    .PARAMETER Force
        Forces the removal of the previous module, to load the same or newer version
        fresh. This is meant to make sure the newest version is used, with the latest
        assemblies.

    .EXAMPLE
        Import-SqlDscPreferredModule

        Imports the default preferred module (SqlServer) if it exist, otherwise
        it will try to import the module SQLPS.

    .EXAMPLE
        Import-SqlDscPreferredModule -Force

        Will forcibly import the default preferred module if it exist, otherwise
        it will try to import the module SQLPS. Prior to importing it will remove
        an already loaded module.

    .EXAMPLE
        Import-SqlDscPreferredModule -Name 'OtherSqlModule'

        Imports the specified preferred module OtherSqlModule if it exist, otherwise
        it will try to import the module SQLPS.
#>
function Import-SqlDscPreferredModule
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Alias('PreferredModule')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    $getSqlDscPreferredModuleParameters = @{
        Refresh = $true
    }

    if ($PSBoundParameters.ContainsKey('Name'))
    {
        $getSqlDscPreferredModuleParameters.Name = @($Name, 'SQLPS')
    }

    if ($PSBoundParameters.ContainsKey('Force'))
    {
        $getSqlDscPreferredModuleParameters.Refresh = $true
    }

    $availableModule = $null

    try
    {
        $availableModule = Get-SqlDscPreferredModule @getSqlDscPreferredModuleParameters -ErrorAction 'Stop'
    }
    catch
    {
        $PSCmdlet.ThrowTerminatingError(
            [System.Management.Automation.ErrorRecord]::new(
                ($script:localizedData.PreferredModule_FailedFinding),
                'ISDPM0001', # cspell: disable-line
                [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                'PreferredModule'
            )
        )
    }

    if ($Force.IsPresent -and -not $Confirm)
    {
        Write-Verbose -Message $script:localizedData.PreferredModule_ForceRemoval

        $removeModule = @()

        if ($PSBoundParameters.ContainsKey('Name'))
        {
            $removeModule += Get-Module -Name $Name
        }

        # Available module could be
        if ($availableModule)
        {
            $removeModule += $availableModule
        }

        if ($removeModule -contains 'SQLPS')
        {
            $removeModule += Get-Module -Name 'SQLASCmdlets' # cSpell: disable-line
        }

        Remove-Module -ModuleInfo $removeModule -Force -ErrorAction 'SilentlyContinue'
    }
    else
    {
        <#
            Check if the preferred module is already loaded into the session.
        #>
        $loadedModule = Get-Module -Name $availableModule.Name | Select-Object -First 1

        if ($loadedModule)
        {
            Write-Verbose -Message ($script:localizedData.PreferredModule_AlreadyImported -f $loadedModule.Name)

            return
        }
    }

    try
    {
        Write-Debug -Message ($script:localizedData.PreferredModule_PushingLocation)

        Push-Location

        <#
            SQLPS has unapproved verbs, disable checking to ignore Warnings.
            Suppressing verbose so all cmdlet is not listed.
        #>
        $importedModule = Import-Module -ModuleInfo $availableModule -DisableNameChecking -Verbose:$false -Force:$Force -Global -PassThru -ErrorAction 'Stop'

        <#
            SQLPS returns two entries, one with module type 'Script' and another with module type 'Manifest'.
            Only return the object with module type 'Manifest'.
            SqlServer only returns one object (of module type 'Script'), so no need to do anything for SqlServer module.
        #>
        if ($availableModule.Name -eq 'SQLPS')
        {
            $importedModule = $importedModule | Where-Object -Property 'ModuleType' -EQ -Value 'Manifest'
        }

        Write-Verbose -Message ($script:localizedData.PreferredModule_ImportedModule -f $importedModule.Name, $importedModule.Version, $importedModule.Path)
    }
    finally
    {
        Write-Debug -Message ($script:localizedData.PreferredModule_PoppingLocation)

        Pop-Location
    }
}
#EndRegion '.\Public\Import-SqlDscPreferredModule.ps1' 161
#Region '.\Public\Initialize-SqlDscRebuildDatabase.ps1' -1

<#
    .SYNOPSIS
        Rebuilds the system databases for an SQL Server instance.

    .DESCRIPTION
        Rebuilds the system databases for an SQL Server instance.

        See the link in the commands help for information on each parameter. The
        link points to SQL Server command line setup documentation.

    .PARAMETER MediaPath
        Specifies the path where to find the SQL Server installation media. On this
        path the SQL Server setup executable must be found.

    .PARAMETER Timeout
        Specifies how long to wait for the setup process to finish. Default value
        is `7200` seconds (2 hours). If the setup process does not finish before
        this time, an exception will be thrown.

    .PARAMETER Force
        If specified the command will not ask for confirmation. Same as if Confirm:$false
        is used.

    .PARAMETER InstanceName
        See the notes section for more information.

    .PARAMETER SAPwd
        See the notes section for more information.

    .PARAMETER SqlCollation
        See the notes section for more information.

    .PARAMETER SqlSysAdminAccounts
        See the notes section for more information.

    .PARAMETER SqlTempDbDir
        See the notes section for more information.

    .PARAMETER SqlTempDbLogDir
        See the notes section for more information.

    .PARAMETER SqlTempDbFileCount
        See the notes section for more information.

    .PARAMETER SqlTempDbFileSize
        See the notes section for more information.

    .PARAMETER SqlTempDbFileGrowth
        See the notes section for more information.

    .PARAMETER SqlTempDbLogFileSize
        See the notes section for more information.

    .PARAMETER SqlTempDbLogFileGrowth
        See the notes section for more information.

    .LINK
        https://docs.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server-from-the-command-prompt

    .OUTPUTS
        None.

    .EXAMPLE
        Initialize-SqlDscRebuildDatabase -InstanceName 'MyInstance' -SqlSysAdminAccounts @('MyAdminAccount') -MediaPath 'E:\'

        Rebuilds the database of the instance 'MyInstance'.

    .NOTES
        The parameters are intentionally not described since it would take a lot
        of effort to keep them up to date. Instead there is a link that points to
        the SQL Server command line setup documentation which will stay relevant.

        For RebuildDatabase the parameter SAPwd must be set if the instance was
        installed with SecurityMode = 'SQL'.
#>
function Initialize-SqlDscRebuildDatabase
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '', Justification = 'Because ShouldProcess is used in Invoke-SetupAction')]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $MediaPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $InstanceName,

        [Parameter()]
        [System.Security.SecureString]
        $SAPwd,

        [Parameter()]
        [System.String]
        $SqlCollation,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $SqlSysAdminAccounts,

        [Parameter()]
        [System.String]
        $SqlTempDbDir,

        [Parameter()]
        [System.String]
        $SqlTempDbLogDir,

        [Parameter()]
        [System.UInt16]
        $SqlTempDbFileCount,

        [Parameter()]
        [ValidateRange(4, 262144)]
        [System.UInt16]
        $SqlTempDbFileSize,

        [Parameter()]
        [ValidateRange(0, 1024)]
        [System.UInt16]
        $SqlTempDbFileGrowth,

        [Parameter()]
        [ValidateRange(4, 262144)]
        [System.UInt16]
        $SqlTempDbLogFileSize,

        [Parameter()]
        [ValidateRange(0, 1024)]
        [System.UInt16]
        $SqlTempDbLogFileGrowth,

        [Parameter()]
        [System.UInt32]
        $Timeout = 7200,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    Invoke-SetupAction -RebuildDatabase @PSBoundParameters
}
#EndRegion '.\Public\Initialize-SqlDscRebuildDatabase.ps1' 146
#Region '.\Public\Install-SqlDscBIReportServer.ps1' -1

<#
    .SYNOPSIS
        Installs SQL Server Power BI Report Server.

    .DESCRIPTION
        Installs SQL Server Power BI Report Server using the provided setup executable.

    .PARAMETER AcceptLicensingTerms
        Required parameter to be able to run unattended install. By specifying this
        parameter you acknowledge the acceptance of all license terms and notices for
        the specified features, the terms and notices that the setup executable
        normally asks for.

    .PARAMETER MediaPath
        Specifies the path where to find the SQL Server installation media. On this
        path the SQL Server setup executable must be found.

    .PARAMETER ProductKey
        Specifies the product key to use for the installation, e.g. '12345-12345-12345-12345-12345'.
        This parameter is mutually exclusive with the parameter Edition.

    .PARAMETER EditionUpgrade
        Upgrades the edition of the installed product. Requires that either the
        ProductKey or the Edition parameter is also assigned. By default no edition
        upgrade is performed.

    .PARAMETER Edition
        Specifies a free custom edition to use for the installation. This parameter
        is mutually exclusive with the parameter ProductKey.

    .PARAMETER LogPath
        Specifies the file path where to write the log files, e.g. 'C:\Logs\Install.log'.
        By default log files are created under %TEMP%.

    .PARAMETER InstallFolder
        Specifies the folder where to install the product, e.g. 'C:\Program Files\Power BI Report Server'.
        By default the product is installed under the default installation folder.

        Reporting Services: %ProgramFiles%\Microsoft SQL Server Reporting Services
        PI Report Server: %ProgramFiles%\Microsoft Power BI Report Server

    .PARAMETER SuppressRestart
        Suppresses the restart of the computer after the installation is finished.
        By default the computer is restarted after the installation is finished.

    .PARAMETER Timeout
        Specifies how long to wait for the setup process to finish. Default value
        is `7200` seconds (2 hours). If the setup process does not finish before
        this time, an exception will be thrown.

    .PARAMETER Force
        If specified the command will not ask for confirmation. Same as if Confirm:$false
        is used.

    .PARAMETER PassThru
        If specified the command will return the setup process exit code.

    .OUTPUTS
        When PassThru is specified the function will return the setup process exit
        code as System.Int32. Otherwise, the function does not generate any output.

    .EXAMPLE
        Install-SqlDscBIReportServer -AcceptLicensingTerms -MediaPath 'E:\PowerBIReportServer.exe'

        Installs Power BI Report Server with default settings.

    .EXAMPLE
        Install-SqlDscBIReportServer -AcceptLicensingTerms -MediaPath 'E:\PowerBIReportServer.exe' -ProductKey '12345-12345-12345-12345-12345'

        Installs Power BI Report Server using a product key.

    .EXAMPLE
        Install-SqlDscBIReportServer -AcceptLicensingTerms -MediaPath 'E:\PowerBIReportServer.exe' -Edition 'Evaluation' -InstallFolder 'C:\Program Files\Power BI Report Server'

        Installs Power BI Report Server in evaluation edition to a custom folder.

    .EXAMPLE
        Install-SqlDscBIReportServer -AcceptLicensingTerms -MediaPath 'E:\PowerBIReportServer.exe' -ProductKey '12345-12345-12345-12345-12345' -EditionUpgrade -LogPath 'C:\Logs\PowerBIReportServer_Install.log'

        Installs Power BI Report Server and upgrades the edition using a product key. Also specifies a custom log path.

    .EXAMPLE
        $exitCode = Install-SqlDscBIReportServer -AcceptLicensingTerms -MediaPath 'E:\PowerBIReportServer.exe' -PassThru

        Installs Power BI Report Server with default settings and returns the setup exit code.
#>
function Install-SqlDscBIReportServer
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '', Justification = 'Because ShouldProcess is used in Invoke-SetupAction')]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([System.Int32])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $AcceptLicensingTerms,

        [Parameter(Mandatory = $true)]
        [System.String]
        $MediaPath,

        [Parameter()]
        [System.String]
        $ProductKey,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $EditionUpgrade,

        [Parameter()]
        [ValidateSet('Developer', 'Evaluation', 'ExpressAdvanced')]
        [System.String]
        $Edition,

        [Parameter()]
        [System.String]
        $LogPath,

        [Parameter()]
        [System.String]
        $InstallFolder,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $SuppressRestart,

        [Parameter()]
        [System.UInt32]
        $Timeout = 7200,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $PassThru
    )

    $exitCode = Invoke-ReportServerSetupAction -Install @PSBoundParameters

    if ($PassThru.IsPresent)
    {
        return $exitCode
    }
}
#EndRegion '.\Public\Install-SqlDscBIReportServer.ps1' 147
#Region '.\Public\Install-SqlDscReportingService.ps1' -1

<#
    .SYNOPSIS
        Installs SQL Server Reporting Services or Power BI Report Server.

    .DESCRIPTION
        Installs SQL Server Reporting Services or Power BI Report Server using
        the provided setup executable.

    .PARAMETER AcceptLicensingTerms
        Required parameter to be able to run unattended install. By specifying this
        parameter you acknowledge the acceptance of all license terms and notices for
        the specified features, the terms and notices that the setup executable
        normally asks for.

    .PARAMETER MediaPath
        Specifies the path where to find the SQL Server installation media. On this
        path the SQL Server setup executable must be found.

    .PARAMETER ProductKey
        Specifies the product key to use for the installation, e.g. '12345-12345-12345-12345-12345'.
        This parameter is mutually exclusive with the parameter Edition.

    .PARAMETER EditionUpgrade
        Upgrades the edition of the installed product. Requires that either the
        ProductKey or the Edition parameter is also assigned. By default no edition
        upgrade is performed.

    .PARAMETER Edition
        Specifies a free custom edition to use for the installation. This parameter
        is mutually exclusive with the parameter ProductKey.

    .PARAMETER LogPath
        Specifies the file path where to write the log files, e.g. 'C:\Logs\Install.log'.
        By default log files are created under %TEMP%.

    .PARAMETER InstallFolder
        Specifies the folder where to install the product, e.g. 'C:\Program Files\SSRS'.
        By default the product is installed under the default installation folder.

        Reporting Services: %ProgramFiles%\Microsoft SQL Server Reporting Services
        PI Report Server: %ProgramFiles%\Microsoft Power BI Report Server

    .PARAMETER SuppressRestart
        Suppresses the restart of the computer after the installation is finished.
        By default the computer is restarted after the installation is finished.

    .PARAMETER Timeout
        Specifies how long to wait for the setup process to finish. Default value
        is `7200` seconds (2 hours). If the setup process does not finish before
        this time, an exception will be thrown.

    .PARAMETER Force
        If specified the command will not ask for confirmation. Same as if Confirm:$false
        is used.

    .PARAMETER PassThru
        If specified the command will return the setup process exit code.

    .OUTPUTS
        When PassThru is specified the function will return the setup process exit
        code as System.Int32. Otherwise, the function does not generate any output.

    .EXAMPLE
        Install-SqlDscReportingService -AcceptLicensingTerms -MediaPath 'E:\SQLServerReportingServices.exe'

        Installs SQL Server Reporting Services with default settings.

    .EXAMPLE
        Install-SqlDscReportingService -AcceptLicensingTerms -MediaPath 'E:\SQLServerReportingServices.exe' -ProductKey '12345-12345-12345-12345-12345'

        Installs SQL Server Reporting Services using a product key.

    .EXAMPLE
        Install-SqlDscReportingService -AcceptLicensingTerms -MediaPath 'E:\PowerBIReportServer.exe' -Edition 'Evaluation' -InstallFolder 'C:\Program Files\Power BI Report Server'

        Installs Power BI Report Server in evaluation edition to a custom folder.

    .EXAMPLE
        Install-SqlDscReportingService -AcceptLicensingTerms -MediaPath 'E:\SQLServerReportingServices.exe' -ProductKey '12345-12345-12345-12345-12345' -EditionUpgrade -LogPath 'C:\Logs\SSRS_Install.log'

        Installs SQL Server Reporting Services and upgrades the edition using a
        product key. Also specifies a custom log path.

    .EXAMPLE
        $exitCode = Install-SqlDscReportingService -AcceptLicensingTerms -MediaPath 'E:\SQLServerReportingServices.exe' -PassThru

        Installs SQL Server Reporting Services with default settings and returns the setup exit code.
#>
function Install-SqlDscReportingService
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '', Justification = 'Because ShouldProcess is used in Invoke-SetupAction')]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([System.Int32])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $AcceptLicensingTerms,

        [Parameter(Mandatory = $true)]
        [System.String]
        $MediaPath,

        [Parameter()]
        [System.String]
        $ProductKey,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $EditionUpgrade,

        [Parameter()]
        [ValidateSet('Developer', 'Evaluation', 'ExpressAdvanced')]
        [System.String]
        $Edition,

        [Parameter()]
        [System.String]
        $LogPath,

        [Parameter()]
        [System.String]
        $InstallFolder,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $SuppressRestart,

        [Parameter()]
        [System.UInt32]
        $Timeout = 7200,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $PassThru
    )

    $exitCode = Invoke-ReportServerSetupAction -Install @PSBoundParameters

    if ($PassThru.IsPresent)
    {
        return $exitCode
    }
}
#EndRegion '.\Public\Install-SqlDscReportingService.ps1' 149
#Region '.\Public\Install-SqlDscServer.ps1' -1

<#
    .SYNOPSIS
        Executes an setup action using Microsoft SQL Server setup executable.

    .DESCRIPTION
        Executes an setup action using Microsoft SQL Server setup executable.

        See the link in the commands help for information on each parameter. The
        link points to SQL Server command line setup documentation.

    .PARAMETER Install
        Specifies the setup action Install.

    .PARAMETER Uninstall
        Specifies the setup action Uninstall.

    .PARAMETER PrepareImage
        Specifies the setup action PrepareImage.

    .PARAMETER Upgrade
        Specifies the setup action Upgrade.

    .PARAMETER EditionUpgrade
        Specifies the setup action EditionUpgrade.

    .PARAMETER InstallFailoverCluster
        Specifies the setup action InstallFailoverCluster.

    .PARAMETER PrepareFailoverCluster
        Specifies the setup action PrepareFailoverCluster.

    .PARAMETER ConfigurationFile
        Specifies an configuration file to use during SQL Server setup. This
        parameter cannot be used together with any of the setup actions, but instead
        it is expected that the configuration file specifies what setup action to
        run.

    .PARAMETER AcceptLicensingTerms
        Required parameter to be able to run unattended install. By specifying this
        parameter you acknowledge the acceptance all license terms and notices for
        the specified features, the terms and notices that the Microsoft SQL Server
        setup executable normally ask for.

    .PARAMETER MediaPath
        Specifies the path where to find the SQL Server installation media. On this
        path the SQL Server setup executable must be found.

    .PARAMETER Timeout
        Specifies how long to wait for the setup process to finish. Default value
        is `7200` seconds (2 hours). If the setup process does not finish before
        this time, an exception will be thrown.

    .PARAMETER Force
        If specified the command will not ask for confirmation. Same as if Confirm:$false
        is used.

    .PARAMETER SuppressPrivacyStatementNotice
        See the notes section for more information.

    .PARAMETER IAcknowledgeEntCalLimits
        See the notes section for more information.

    .PARAMETER InstanceName
        See the notes section for more information.

    .PARAMETER Enu
        See the notes section for more information.

    .PARAMETER UpdateEnabled
        See the notes section for more information.

    .PARAMETER UpdateSource
        See the notes section for more information.

    .PARAMETER Features
        See the notes section for more information.

    .PARAMETER Role
        See the notes section for more information.

    .PARAMETER InstallSharedDir
        See the notes section for more information.

    .PARAMETER InstallSharedWowDir
        See the notes section for more information.

    .PARAMETER InstanceDir
        See the notes section for more information.

    .PARAMETER InstanceId
        See the notes section for more information.

    .PARAMETER PBEngSvcAccount
        See the notes section for more information.

    .PARAMETER PBEngSvcPassword
        See the notes section for more information.

    .PARAMETER PBEngSvcStartupType
        See the notes section for more information.

    .PARAMETER PBDMSSvcAccount
        See the notes section for more information.

    .PARAMETER PBDMSSvcPassword
        See the notes section for more information.

    .PARAMETER PBDMSSvcStartupType
        See the notes section for more information.

    .PARAMETER PBStartPortRange
        See the notes section for more information.

    .PARAMETER PBEndPortRange
        See the notes section for more information.

    .PARAMETER PBScaleOut
        See the notes section for more information.

    .PARAMETER ProductKey
        See the notes section for more information.

    .PARAMETER AgtSvcAccount
        See the notes section for more information.

    .PARAMETER AgtSvcPassword
        See the notes section for more information.

    .PARAMETER AgtSvcStartupType
        See the notes section for more information.

    .PARAMETER ASBackupDir
        See the notes section for more information.

    .PARAMETER ASCollation
        See the notes section for more information.

    .PARAMETER ASConfigDir
        See the notes section for more information.

    .PARAMETER ASDataDir
        See the notes section for more information.

    .PARAMETER ASLogDir
        See the notes section for more information.

    .PARAMETER ASTempDir
        See the notes section for more information.

    .PARAMETER ASServerMode
        See the notes section for more information.

    .PARAMETER ASSvcAccount
        See the notes section for more information.

    .PARAMETER ASSvcPassword
        See the notes section for more information.

    .PARAMETER ASSvcStartupType
        See the notes section for more information.

    .PARAMETER ASSysAdminAccounts
        See the notes section for more information.

    .PARAMETER ASProviderMSOLAP
        See the notes section for more information.

    .PARAMETER FarmAccount
        See the notes section for more information.

    .PARAMETER FarmPassword
        See the notes section for more information.

    .PARAMETER Passphrase
        See the notes section for more information.

    .PARAMETER FarmAdminiPort
        See the notes section for more information.

    .PARAMETER BrowserSvcStartupType
        See the notes section for more information.

    .PARAMETER FTUpgradeOption
        See the notes section for more information.

    .PARAMETER EnableRanU
        See the notes section for more information.

    .PARAMETER InstallSqlDataDir
        See the notes section for more information.

    .PARAMETER SqlBackupDir
        See the notes section for more information.

    .PARAMETER SecurityMode
        See the notes section for more information.

    .PARAMETER SAPwd
        See the notes section for more information.

    .PARAMETER SqlCollation
        See the notes section for more information.

    .PARAMETER AddCurrentUserAsSqlAdmin
        See the notes section for more information.

    .PARAMETER SqlSvcAccount
        See the notes section for more information.

    .PARAMETER SqlSvcPassword
        See the notes section for more information.

    .PARAMETER SqlSvcStartupType
        See the notes section for more information.

    .PARAMETER SqlSysAdminAccounts
        See the notes section for more information.

    .PARAMETER SqlTempDbDir
        See the notes section for more information.

    .PARAMETER SqlTempDbLogDir
        See the notes section for more information.

    .PARAMETER SqlTempDbFileCount
        See the notes section for more information.

    .PARAMETER SqlTempDbFileSize
        See the notes section for more information.

    .PARAMETER SqlTempDbFileGrowth
        See the notes section for more information.

    .PARAMETER SqlTempDbLogFileSize
        See the notes section for more information.

    .PARAMETER SqlTempDbLogFileGrowth
        See the notes section for more information.

    .PARAMETER SqlUserDbDir
        See the notes section for more information.

    .PARAMETER SqlSvcInstantFileInit
        See the notes section for more information.

    .PARAMETER SqlUserDbLogDir
        See the notes section for more information.

    .PARAMETER SqlMaxDop
        See the notes section for more information.

    .PARAMETER UseSqlRecommendedMemoryLimits
        See the notes section for more information.

    .PARAMETER SqlMinMemory
        See the notes section for more information.

    .PARAMETER SqlMaxMemory
        See the notes section for more information.

    .PARAMETER FileStreamLevel
        See the notes section for more information.

    .PARAMETER FileStreamShareName
        See the notes section for more information.

    .PARAMETER ISSvcAccount
        See the notes section for more information.

    .PARAMETER ISSvcPassword
        See the notes section for more information.

    .PARAMETER ISSvcStartupType
        See the notes section for more information.

    .PARAMETER AllowUpgradeForSSRSSharePointMode
        See the notes section for more information.

    .PARAMETER NpEnabled
        See the notes section for more information.

    .PARAMETER TcpEnabled
        See the notes section for more information.

    .PARAMETER RsInstallMode
        See the notes section for more information.

    .PARAMETER RSSvcAccount
        See the notes section for more information.

    .PARAMETER RSSvcPassword
        See the notes section for more information.

    .PARAMETER RSSvcStartupType
        See the notes section for more information.

    .PARAMETER MPYCacheDirectory
        See the notes section for more information.

    .PARAMETER MRCacheDirectory
        See the notes section for more information.

    .PARAMETER SqlInstJava
        See the notes section for more information.

    .PARAMETER SqlJavaDir
        See the notes section for more information.

    .PARAMETER FailoverClusterGroup
        See the notes section for more information.

    .PARAMETER FailoverClusterDisks
        See the notes section for more information.

    .PARAMETER FailoverClusterNetworkName
        See the notes section for more information.

    .PARAMETER FailoverClusterIPAddresses
        See the notes section for more information.

    .PARAMETER FailoverClusterRollOwnership
        See the notes section for more information.

    .PARAMETER AzureSubscriptionId
        See the notes section for more information.

    .PARAMETER AzureResourceGroup
        See the notes section for more information.

    .PARAMETER AzureRegion
        See the notes section for more information.

    .PARAMETER AzureTenantId
        See the notes section for more information.

    .PARAMETER AzureServicePrincipal
        See the notes section for more information.

    .PARAMETER AzureServicePrincipalSecret
        See the notes section for more information.

    .PARAMETER AzureArcProxy
        See the notes section for more information.

    .PARAMETER SkipRules
        See the notes section for more information.

    .PARAMETER ProductCoveredBySA
        See the notes section for more information.

    .LINK
        https://docs.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server-from-the-command-prompt

    .OUTPUTS
        None.

    .EXAMPLE
        Install-SqlDscServer -Install -AcceptLicensingTerms -InstanceName 'MyInstance' -Features 'SQLENGINE' -SqlSysAdminAccounts @('MyAdminAccount') -MediaPath 'E:\'

        Installs the database engine for the named instance MyInstance.

    .EXAMPLE
        Install-SqlDscServer -Install -AcceptLicensingTerms -InstanceName 'MyInstance' -Features 'SQLENGINE','ARC' -SqlSysAdminAccounts @('MyAdminAccount') -MediaPath 'E:\' -AzureSubscriptionId 'MySubscriptionId' -AzureResourceGroup 'MyRG' -AzureRegion 'West-US' -AzureTenantId 'MyTenantId' -AzureServicePrincipal 'MyPrincipalName' -AzureServicePrincipalSecret ('MySecret' | ConvertTo-SecureString -AsPlainText -Force)

        Installs the database engine for the named instance MyInstance and onboard the server to Azure Arc.

    .EXAMPLE
        Install-SqlDscServer -Install -AcceptLicensingTerms -MediaPath 'E:\' -AzureSubscriptionId 'MySubscriptionId' -AzureResourceGroup 'MyRG' -AzureRegion 'West-US' -AzureTenantId 'MyTenantId' -AzureServicePrincipal 'MyPrincipalName' -AzureServicePrincipalSecret ('MySecret' | ConvertTo-SecureString -AsPlainText -Force)

        Installs the Azure Arc Agent on the server.

    .EXAMPLE
        Install-SqlDscServer -ConfigurationFile 'MySqlConfig.ini' -MediaPath 'E:\'

        Installs SQL Server using the configuration file 'MySqlConfig.ini'.

    .EXAMPLE
        Install-SqlDscServer -PrepareImage -AcceptLicensingTerms -Features 'SQLENGINE' -InstanceId 'MyInstance' -MediaPath 'E:\'

        Prepares the server for using the database engine for an instance named 'MyInstance'.

    .EXAMPLE
        Install-SqlDscServer -Upgrade -AcceptLicensingTerms -InstanceName 'MyInstance' -MediaPath 'E:\'

        Upgrades the instance 'MyInstance' with the SQL Server version that is provided by the media path.

    .EXAMPLE
        Install-SqlDscServer -EditionUpgrade -AcceptLicensingTerms -ProductKey 'NewEditionProductKey' -InstanceName 'MyInstance' -MediaPath 'E:\'

        Upgrades the instance 'MyInstance' with the SQL Server edition that is provided by the media path.

    .EXAMPLE
        Install-SqlDscServer -InstallFailoverCluster -AcceptLicensingTerms -InstanceName 'MyInstance' -Features 'SQLENGINE' -InstallSqlDataDir 'D:\MSSQL\Data' -SqlSysAdminAccounts @('MyAdminAccount') -FailoverClusterNetworkName 'TestCluster01A' -FailoverClusterIPAddresses 'IPv4;192.168.0.46;ClusterNetwork1;255.255.255.0' -MediaPath 'E:\'

        Installs the database engine in a failover cluster with the instance name 'MyInstance'.

    .EXAMPLE
        Install-SqlDscServer -PrepareFailoverCluster -AcceptLicensingTerms -InstanceName 'MyInstance' -Features 'SQLENGINE' -MediaPath 'E:\'

        Prepares to installs the database engine in a failover cluster with the instance name 'MyInstance'.

    .NOTES
        The parameters are intentionally not described since it would take a lot
        of effort to keep them up to date. Instead there is a link that points to
        the SQL Server command line setup documentation which will stay relevant.
#>
function Install-SqlDscServer
{
    # cSpell: ignore PBDMS Admini AZUREEXTENSION
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '', Justification = 'Because ShouldProcess is used in Invoke-SetupAction')]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType()]
    param
    (
        [Parameter(ParameterSetName = 'Install', Mandatory = $true)]
        [Parameter(ParameterSetName = 'InstallRole', Mandatory = $true)]
        [Parameter(ParameterSetName = 'InstallAzureArcAgent', Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $Install,

        [Parameter(ParameterSetName = 'PrepareImage', Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $PrepareImage,

        [Parameter(ParameterSetName = 'Upgrade', Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $Upgrade,

        [Parameter(ParameterSetName = 'EditionUpgrade', Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $EditionUpgrade,

        [Parameter(ParameterSetName = 'InstallFailoverCluster', Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $InstallFailoverCluster,

        [Parameter(ParameterSetName = 'PrepareFailoverCluster', Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $PrepareFailoverCluster,

        [Parameter(ParameterSetName = 'UsingConfigurationFile', Mandatory = $true)]
        [System.String]
        $ConfigurationFile,

        [Parameter(ParameterSetName = 'Install', Mandatory = $true)]
        [Parameter(ParameterSetName = 'InstallRole', Mandatory = $true)]
        [Parameter(ParameterSetName = 'InstallAzureArcAgent', Mandatory = $true)]
        [Parameter(ParameterSetName = 'PrepareImage', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Upgrade', Mandatory = $true)]
        [Parameter(ParameterSetName = 'EditionUpgrade', Mandatory = $true)]
        [Parameter(ParameterSetName = 'InstallFailoverCluster', Mandatory = $true)]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster', Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $AcceptLicensingTerms,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [System.Management.Automation.SwitchParameter]
        $SuppressPrivacyStatementNotice,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'PrepareImage')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [System.Management.Automation.SwitchParameter]
        $IAcknowledgeEntCalLimits,

        [Parameter(Mandatory = $true)]
        [System.String]
        $MediaPath,

        [Parameter(ParameterSetName = 'Install', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Upgrade', Mandatory = $true)]
        [Parameter(ParameterSetName = 'EditionUpgrade', Mandatory = $true)]
        [Parameter(ParameterSetName = 'InstallFailoverCluster', Mandatory = $true)]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster', Mandatory = $true)]
        [Parameter(ParameterSetName = 'InstallRole')]
        [System.String]
        $InstanceName,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'PrepareImage')]
        [Parameter(ParameterSetName = 'Upgrade')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [System.Management.Automation.SwitchParameter]
        $Enu,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'PrepareImage')]
        [Parameter(ParameterSetName = 'Upgrade')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [System.Management.Automation.SwitchParameter]
        $UpdateEnabled,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'PrepareImage')]
        [Parameter(ParameterSetName = 'Upgrade')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [System.String]
        $UpdateSource,

        [Parameter(ParameterSetName = 'Install', Mandatory = $true)]
        [Parameter(ParameterSetName = 'PrepareImage', Mandatory = $true)]
        [Parameter(ParameterSetName = 'InstallFailoverCluster', Mandatory = $true)]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster', Mandatory = $true)]
        [Parameter(ParameterSetName = 'InstallRole')]
        [ValidateSet(
            'SQL',
            'SQLEngine', # Part of parent feature SQL
            'Replication', # Part of parent feature SQL
            'FullText', # Part of parent feature SQL
            'DQ', # Part of parent feature SQL
            'PolyBase', # Part of parent feature SQL
            'PolyBaseCore', # Part of parent feature SQL
            'PolyBaseJava', # Part of parent feature SQL
            'AdvancedAnalytics', # Part of parent feature SQL
            'SQL_INST_MR', # Part of parent feature SQL
            'SQL_INST_MPY', # Part of parent feature SQL
            'SQL_INST_JAVA', # Part of parent feature SQL
            'AS',
            'RS',
            'RS_SHP',
            'RS_SHPWFE', # cspell: disable-line
            'DQC',
            'IS',
            'IS_Master', # Part of parent feature IS
            'IS_Worker', # Part of parent feature IS
            'MDS',
            'SQL_SHARED_MPY',
            'SQL_SHARED_MR',
            'Tools',
            'BC', # Part of parent feature Tools
            'Conn', # Part of parent feature Tools
            'DREPLAY_CTLR', # Part of parent feature Tools (cspell: disable-line)
            'DREPLAY_CLT', # Part of parent feature Tools (cspell: disable-line)
            'SNAC_SDK', # Part of parent feature Tools (cspell: disable-line)
            'SDK', # Part of parent feature Tools
            'LocalDB', # Part of parent feature Tools
            'AZUREEXTENSION'
        )]
        [System.String[]]
        $Features,

        [Parameter(ParameterSetName = 'InstallRole', Mandatory = $true)]
        [ValidateSet(
            'ALLFeatures_WithDefaults',
            'SPI_AS_NewFarm',
            'SPI_AS_ExistingFarm'
        )]
        [System.String]
        $Role,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'PrepareImage')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [System.String]
        $InstallSharedDir,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [System.String]
        $InstallSharedWowDir,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'PrepareImage')]
        [Parameter(ParameterSetName = 'Upgrade')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [System.String]
        $InstanceDir,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'PrepareImage', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Upgrade')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [System.String]
        $InstanceId,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'PrepareImage')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [System.String]
        $PBEngSvcAccount,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'PrepareImage')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [System.Security.SecureString]
        $PBEngSvcPassword,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'PrepareImage')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [ValidateSet('Automatic', 'Disabled', 'Manual')]
        [System.String]
        $PBEngSvcStartupType,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [System.String]
        $PBDMSSvcAccount, # cspell: disable-line

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [System.Security.SecureString]
        $PBDMSSvcPassword, # cspell: disable-line

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [ValidateSet('Automatic', 'Disabled', 'Manual')]
        [System.String]
        $PBDMSSvcStartupType, # cspell: disable-line

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'PrepareImage')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [System.UInt16]
        $PBStartPortRange,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'PrepareImage')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [System.UInt16]
        $PBEndPortRange,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'PrepareImage')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [System.Management.Automation.SwitchParameter]
        $PBScaleOut,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'Upgrade')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [Parameter(ParameterSetName = 'EditionUpgrade', Mandatory = $true)]
        [System.String]
        $ProductKey, # This is argument PID but $PID is reserved variable.

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [System.String]
        $AgtSvcAccount,

        [Parameter(ParameterSetName = 'UsingConfigurationFile')]
        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [System.Security.SecureString]
        $AgtSvcPassword,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [ValidateSet('Automatic', 'Disabled', 'Manual')]
        [System.String]
        $AgtSvcStartupType,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [System.String]
        $ASBackupDir,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [System.String]
        $ASCollation,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [System.String]
        $ASConfigDir,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [System.String]
        $ASDataDir,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [System.String]
        $ASLogDir,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [System.String]
        $ASTempDir,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [ValidateSet('Multidimensional', 'PowerPivot', 'Tabular')]
        [System.String]
        $ASServerMode,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [System.String]
        $ASSvcAccount,

        [Parameter(ParameterSetName = 'UsingConfigurationFile')]
        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [System.Security.SecureString]
        $ASSvcPassword,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [ValidateSet('Automatic', 'Disabled', 'Manual')]
        [System.String]
        $ASSvcStartupType,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [System.String[]]
        $ASSysAdminAccounts,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [System.Management.Automation.SwitchParameter]
        $ASProviderMSOLAP,

        [Parameter(ParameterSetName = 'InstallRole')]
        [System.String]
        $FarmAccount,

        [Parameter(ParameterSetName = 'InstallRole')]
        [System.Security.SecureString]
        $FarmPassword,

        [Parameter(ParameterSetName = 'InstallRole')]
        [System.Security.SecureString]
        $Passphrase,

        [Parameter(ParameterSetName = 'InstallRole')]
        [ValidateRange(0, 65536)]
        [System.UInt16]
        $FarmAdminiPort, # cspell: disable-line

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'Upgrade')]
        [ValidateSet('Automatic', 'Disabled', 'Manual')]
        [System.String]
        $BrowserSvcStartupType,

        [Parameter(ParameterSetName = 'Upgrade')]
        [ValidateSet('Rebuild', 'Reset', 'Import')]
        [System.String]
        $FTUpgradeOption,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [System.Management.Automation.SwitchParameter]
        $EnableRanU,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster', Mandatory = $true)]
        [System.String]
        $InstallSqlDataDir,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [System.String]
        $SqlBackupDir,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [ValidateSet('SQL')]
        [System.String]
        $SecurityMode,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [System.Security.SecureString]
        $SAPwd,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [System.String]
        $SqlCollation,

        [Parameter(ParameterSetName = 'InstallRole')]
        [System.Management.Automation.SwitchParameter]
        $AddCurrentUserAsSqlAdmin,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [System.String]
        $SqlSvcAccount,

        [Parameter(ParameterSetName = 'UsingConfigurationFile')]
        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [System.Security.SecureString]
        $SqlSvcPassword,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [ValidateSet('Automatic', 'Disabled', 'Manual')]
        [System.String]
        $SqlSvcStartupType,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster', Mandatory = $true)]
        [Parameter(ParameterSetName = 'InstallRole')]
        [System.String[]]
        $SqlSysAdminAccounts,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [System.String]
        $SqlTempDbDir,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [System.String]
        $SqlTempDbLogDir,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [System.UInt16]
        $SqlTempDbFileCount,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [ValidateRange(4, 262144)]
        [System.UInt16]
        $SqlTempDbFileSize,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [ValidateRange(0, 1024)]
        [System.UInt16]
        $SqlTempDbFileGrowth,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [ValidateRange(4, 262144)]
        [System.UInt16]
        $SqlTempDbLogFileSize,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [ValidateRange(0, 1024)]
        [System.UInt16]
        $SqlTempDbLogFileGrowth,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [System.String]
        $SqlUserDbDir,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [System.Management.Automation.SwitchParameter]
        $SqlSvcInstantFileInit,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [System.String]
        $SqlUserDbLogDir,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [ValidateRange(0, 32767)]
        [System.UInt16]
        $SqlMaxDop,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [System.Management.Automation.SwitchParameter]
        $UseSqlRecommendedMemoryLimits,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [ValidateRange(0, 2147483647)]
        [System.UInt32]
        $SqlMinMemory,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [ValidateRange(0, 2147483647)]
        [System.UInt32]
        $SqlMaxMemory,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [ValidateRange(0, 3)]
        [System.UInt16]
        $FileStreamLevel,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [System.String]
        $FileStreamShareName,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'Upgrade')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [System.String]
        $ISSvcAccount,

        [Parameter(ParameterSetName = 'UsingConfigurationFile')]
        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'Upgrade')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [System.Security.SecureString]
        $ISSvcPassword,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'Upgrade')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [ValidateSet('Automatic', 'Disabled', 'Manual')]
        [System.String]
        $ISSvcStartupType,

        [Parameter(ParameterSetName = 'Upgrade')]
        [System.Management.Automation.SwitchParameter]
        $AllowUpgradeForSSRSSharePointMode,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [System.Management.Automation.SwitchParameter]
        $NpEnabled,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [System.Management.Automation.SwitchParameter]
        $TcpEnabled,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [ValidateSet('SharePointFilesOnlyMode', 'DefaultNativeMode', 'FilesOnlyMode')]
        [System.String]
        $RsInstallMode,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [System.String]
        $RSSvcAccount,

        [Parameter(ParameterSetName = 'UsingConfigurationFile')]
        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [System.Security.SecureString]
        $RSSvcPassword,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [ValidateSet('Automatic', 'Disabled', 'Manual')]
        [System.String]
        $RSSvcStartupType,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [System.String]
        $MPYCacheDirectory,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [System.String]
        $MRCacheDirectory,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [System.Management.Automation.SwitchParameter]
        $SqlInstJava,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [System.String]
        $SqlJavaDir,

        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [System.String]
        $FailoverClusterGroup,

        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [System.String[]]
        $FailoverClusterDisks,

        [Parameter(ParameterSetName = 'InstallFailoverCluster', Mandatory = $true)]
        [System.String]
        $FailoverClusterNetworkName,

        [Parameter(ParameterSetName = 'InstallFailoverCluster', Mandatory = $true)]
        [System.String[]]
        $FailoverClusterIPAddresses,

        [Parameter(ParameterSetName = 'Upgrade')]
        [ValidateRange(0, 2)]
        [System.UInt16]
        $FailoverClusterRollOwnership,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallAzureArcAgent', Mandatory = $true)]
        [System.String]
        $AzureSubscriptionId,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallAzureArcAgent', Mandatory = $true)]
        [System.String]
        $AzureResourceGroup,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallAzureArcAgent', Mandatory = $true)]
        [System.String]
        $AzureRegion,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallAzureArcAgent', Mandatory = $true)]
        [System.String]
        $AzureTenantId,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallAzureArcAgent', Mandatory = $true)]
        [System.String]
        $AzureServicePrincipal,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallAzureArcAgent', Mandatory = $true)]
        [System.Security.SecureString]
        $AzureServicePrincipalSecret,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallAzureArcAgent')]
        [System.String]
        $AzureArcProxy,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'EditionUpgrade')]
        [System.String[]]
        $SkipRules,

        [Parameter(ParameterSetName = 'Install')]
        [Parameter(ParameterSetName = 'InstallRole')]
        [Parameter(ParameterSetName = 'Upgrade')]
        [Parameter(ParameterSetName = 'InstallFailoverCluster')]
        [Parameter(ParameterSetName = 'PrepareFailoverCluster')]
        [Parameter(ParameterSetName = 'EditionUpgrade')]
        [System.Management.Automation.SwitchParameter]
        $ProductCoveredBySA,

        [Parameter()]
        [System.UInt32]
        $Timeout = 7200,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    Invoke-SetupAction @PSBoundParameters
}
#EndRegion '.\Public\Install-SqlDscServer.ps1' 1144
#Region '.\Public\Invoke-SqlDscQuery.ps1' -1

<#
    .SYNOPSIS
        Executes a query on the specified database.

    .DESCRIPTION
        Executes a query on the specified database.

    .PARAMETER ServerObject
        Specifies current server connection object.

    .PARAMETER ServerName
        Specifies the server name where the instance exist.

    .PARAMETER InstanceName
       Specifies the instance name on which to execute the T-SQL query.

    .PARAMETER Credential
        Specifies the credentials to use to impersonate a user when connecting.
        If this is not provided then the current user will be used to connect
        to the SQL Server Database Engine instance.

    .PARAMETER LoginType
        Specifies which type of credentials are specified. The valid types are
        Integrated, WindowsUser, and SqlLogin. If WindowsUser or SqlLogin are
        specified then the Credential needs to be specified as well. Defaults
        to `Integrated`.

    .PARAMETER DatabaseName
        Specifies the name of the database to execute the T-SQL query in.

    .PARAMETER Query
        The query string to execute.

    .PARAMETER PassThru
        Specifies if the command should return any result the query might return.

    .PARAMETER StatementTimeout
        Set the query StatementTimeout in seconds. Default 600 seconds (10 minutes).

    .PARAMETER RedactText
        One or more text strings to redact from the query when verbose messages
        are written to the console. Strings will be escaped so they will not
        be interpreted as regular expressions (RegEx).

    .PARAMETER Encrypt
        Specifies if encryption should be used.

    .PARAMETER Force
        Specifies that the query should be executed without any confirmation.

    .OUTPUTS
        `[System.Data.DataSet]` when passing parameter **PassThru**, otherwise
        outputs none.

    .EXAMPLE
        $serverObject = Connect-SqlDscDatabaseEngine
        Invoke-SqlDscQuery -ServerObject $serverObject -DatabaseName 'master' `
            -Query 'SELECT name FROM sys.databases' -PassThru

        Connects to the default instance and then runs a query to return all the
        database names in the instance.

    .EXAMPLE
        $serverObject = Connect-SqlDscDatabaseEngine
        $serverObject | Invoke-SqlDscQuery -DatabaseName 'master' `
            -Query 'RESTORE DATABASE [NorthWinds] WITH RECOVERY'

        Connects to the default instance and then runs the query to restore the
        database NorthWinds.

    .EXAMPLE
        $serverObject = Connect-SqlDscDatabaseEngine
        Invoke-SqlDscQuery -ServerObject $serverObject -DatabaseName 'master' `
            -Query "select * from MyTable where password = 'PlaceholderPa\ssw0rd1' and password = 'placeholder secret passphrase'" `
            -RedactText @('PlaceholderPa\sSw0rd1','Placeholder Secret PassPhrase') `
            -PassThru -Verbose

        Shows how to redact sensitive information in the query when the query string
        is output as verbose information when the parameter Verbose is used. For it
        to work the sensitiv information must be known and passed into the parameter
        RedactText. If any single character is wrong the sensitiv information will
        not be redacted. The redaction is case-insensitive.

    .EXAMPLE
        Invoke-SqlDscQuery -ServerName Server1 -InstanceName MSSQLSERVER -DatabaseName 'master' `
            -Query 'SELECT name FROM sys.databases' -PassThru

        Connects to the default instance and then runs a query to return all the
        database names in the instance.
#>
function Invoke-SqlDscQuery
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseSyntacticallyCorrectExamples', '', Justification = 'Because the rule does not yet support parsing the code when a parameter type is not available. The ScriptAnalyzer rule UseSyntacticallyCorrectExamples will always error in the editor due to https://github.com/indented-automation/Indented.ScriptAnalyzerRules/issues/8.')]
    [OutputType([System.Data.DataSet])]
    [CmdletBinding(DefaultParameterSetName = 'ByServerName', SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param
    (
        [Parameter(ParameterSetName = 'ByServerObject', Mandatory = $true, ValueFromPipeline = $true)]
        [Microsoft.SqlServer.Management.Smo.Server]
        $ServerObject,

        [Parameter(ParameterSetName = 'ByServerName')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ServerName = (Get-ComputerName),

        [Parameter(ParameterSetName = 'ByServerName')]
        [System.String]
        $InstanceName = 'MSSQLSERVER',

        [Parameter(ParameterSetName = 'ByServerName')]
        [Alias('SetupCredential')]
        [Alias('DatabaseCredential')]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter(ParameterSetName = 'ByServerName')]
        [ValidateSet('Integrated', 'WindowsUser', 'SqlLogin')]
        [System.String]
        $LoginType = 'Integrated',

        [Parameter(ParameterSetName = 'ByServerName')]
        [System.Management.Automation.SwitchParameter]
        $Encrypt,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DatabaseName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Query,

        [Parameter()]
        [Alias('WithResults')]
        [Switch]
        $PassThru,

        [Parameter()]
        [ValidateNotNull()]
        [System.Int32]
        $StatementTimeout = 600,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $RedactText,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    begin
    {
        if ($Force.IsPresent -and -not $Confirm)
        {
            $ConfirmPreference = 'None'
        }

        if ($PSCmdlet.ParameterSetName -eq 'ByServerName')
        {
            $connectSqlDscDatabaseEngineParameters = @{
                ServerName       = $ServerName
                InstanceName     = $InstanceName
                StatementTimeout = $StatementTimeout
                ErrorAction      = 'Stop'
                Verbose          = $VerbosePreference
            }

            if ($Encrypt.IsPresent)
            {
                $connectSqlDscDatabaseEngineParameters.Encrypt = $true
            }

            if ($LoginType -ne 'Integrated')
            {
                $connectSqlDscDatabaseEngineParameters['LoginType'] = $LoginType
            }

            if ($PSBoundParameters.ContainsKey('Credential'))
            {
                $connectSqlDscDatabaseEngineParameters.Credential = $Credential
            }

            $ServerObject = Connect-SqlDscDatabaseEngine @connectSqlDscDatabaseEngineParameters
        }

        if ($PSCmdlet.ParameterSetName -eq 'ByServerObject')
        {
            $InstanceName = $ServerObject.InstanceName
        }

        $redactedQuery = $Query

        if ($PSBoundParameters.ContainsKey('RedactText'))
        {
            $redactedQuery = ConvertTo-RedactedText -Text $Query -RedactPhrase $RedactText
        }
    }

    process
    {
        $result = $null

        $verboseDescriptionMessage = $script:localizedData.Query_Invoke_ShouldProcessVerboseDescription -f $InstanceName
        $verboseWarningMessage = $script:localizedData.Query_Invoke_ShouldProcessVerboseWarning -f $InstanceName
        $captionMessage = $script:localizedData.Query_Invoke_ShouldProcessCaption

        if ($PSCmdlet.ShouldProcess($verboseDescriptionMessage, $verboseWarningMessage, $captionMessage))
        {
            $previousStatementTimeout = $null

            if ($PSCmdlet.ParameterSetName -eq 'ByServerObject')
            {
                if ($PSBoundParameters.ContainsKey('StatementTimeout'))
                {
                    # Make sure we can return the StatementTimeout before exiting.
                    $previousStatementTimeout = $ServerObject.ConnectionContext.StatementTimeout

                    $ServerObject.ConnectionContext.StatementTimeout = $StatementTimeout
                }
            }

            try
            {
                if ($PassThru)
                {
                    Write-Verbose -Message (
                        $script:localizedData.Query_Invoke_ExecuteQueryWithResults -f $redactedQuery
                    )

                    $result = $ServerObject.Databases[$DatabaseName].ExecuteWithResults($Query)

                    return $result
                }
                else
                {
                    Write-Verbose -Message (
                        $script:localizedData.Query_Invoke_ExecuteNonQuery -f $redactedQuery
                    )

                    $null = $ServerObject.Databases[$DatabaseName].ExecuteNonQuery($Query)
                }
            }
            catch
            {
                $writeErrorParameters = @{
                    Message      = $_.Exception.ToString()
                    Category     = 'InvalidOperation'
                    ErrorId      = 'ISDQ0001' # cSpell: disable-line
                    TargetObject = $DatabaseName
                }

                Write-Error @writeErrorParameters
            }
            finally
            {
                if ($previousStatementTimeout)
                {
                    $ServerObject.ConnectionContext.StatementTimeout = $previousStatementTimeout
                }
            }
        }
    }

    end
    {
        if ($PSCmdlet.ParameterSetName -eq 'ByServerName')
        {
            $ServerObject | Disconnect-SqlDscDatabaseEngine -Force -Verbose:$VerbosePreference
        }
    }
}
#EndRegion '.\Public\Invoke-SqlDscQuery.ps1' 275
#Region '.\Public\New-SqlDscAudit.ps1' -1

<#
    .SYNOPSIS
        Creates a server audit.

    .DESCRIPTION
        This command creates a server audit on a SQL Server Database Engine instance.

    .PARAMETER ServerObject
        Specifies current server connection object.

    .PARAMETER Name
        Specifies the name of the server audit to be added.

    .PARAMETER AuditFilter
        Specifies the filter that should be used on the audit. See [predicate expression](https://docs.microsoft.com/en-us/sql/t-sql/statements/create-server-audit-transact-sql)
        how to write the syntax for the filter.

    .PARAMETER OnFailure
        Specifies what should happen when writing events to the store fails.
        This can be 'Continue', 'FailOperation', or 'Shutdown'.

    .PARAMETER QueueDelay
        Specifies the maximum delay before a event is written to the store.
        When set to low this could impact server performance.
        When set to high events could be missing when a server crashes.

    .PARAMETER AuditGuid
        Specifies the GUID found in the mirrored database. To support scenarios such
        as database mirroring an audit needs a specific GUID.

    .PARAMETER Force
        Specifies that the audit should be created without any confirmation.

    .PARAMETER Refresh
        Specifies that the **ServerObject**'s audits should be refreshed before
        creating the audit object. This is helpful when audits could have been
        modified outside of the **ServerObject**, for example through T-SQL. But
        on instances with a large amount of audits it might be better to make
        sure the ServerObject is recent enough.

    .PARAMETER LogType
        Specifies the log location where the audit should write to.
        This can be SecurityLog or ApplicationLog.

    .PARAMETER Path
        Specifies the location where te log files wil be placed.

    .PARAMETER ReserveDiskSpace
        Specifies if the needed file space should be reserved. To use this parameter
        the parameter **MaximumFiles** must also be used.

    .PARAMETER MaximumFiles
        Specifies the number of files on disk.

    .PARAMETER MaximumFileSize
        Specifies the maximum file size in units by parameter MaximumFileSizeUnit.

    .PARAMETER MaximumFileSizeUnit
        Specifies the unit that is used for the file size. This can be set to `Megabyte`,
        `Gigabyte`, or `Terabyte`.

    .PARAMETER MaximumRolloverFiles
        Specifies the amount of files on disk before SQL Server starts reusing
        the files. If not specified then it is set to unlimited.

    .PARAMETER PassThru
        If specified the created audit object will be returned.

    .OUTPUTS
        `[Microsoft.SqlServer.Management.Smo.Audit]` is passing parameter **PassThru**,
         otherwise none.

    .EXAMPLE
        $serverObject = Connect-SqlDscDatabaseEngine -InstanceName 'MyInstance'
        $sqlServerObject | New-SqlDscAudit -Name 'MyFileAudit' -Path 'E:\auditFolder'

        Create a new file audit named **MyFileAudit**.

    .EXAMPLE
        $serverObject = Connect-SqlDscDatabaseEngine -InstanceName 'MyInstance'
        $sqlServerObject | New-SqlDscAudit -Name 'MyAppLogAudit' -LogType 'ApplicationLog'

        Create a new application log audit named **MyAppLogAudit**.

    .EXAMPLE
        $serverObject = Connect-SqlDscDatabaseEngine -InstanceName 'MyInstance'
        $sqlServerObject | New-SqlDscAudit -Name 'MyFileAudit' -Path 'E:\auditFolder' -PassThru

        Create a new file audit named **MyFileAudit** and returns the Audit object.

    .NOTES
        This command has the confirm impact level set to medium since an audit is
        created but by default is is not enabled.

        See the SQL Server documentation for more information for the possible
        parameter values to pass to this command: https://docs.microsoft.com/en-us/sql/t-sql/statements/create-server-audit-transact-sql
#>
function New-SqlDscAudit
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseSyntacticallyCorrectExamples', '', Justification = 'Because the rule does not yet support parsing the code when a parameter type is not available. The ScriptAnalyzer rule UseSyntacticallyCorrectExamples will always error in the editor due to https://github.com/indented-automation/Indented.ScriptAnalyzerRules/issues/8.')]
    [OutputType([Microsoft.SqlServer.Management.Smo.Audit])]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param
    (
        [Parameter(ParameterSetName = 'Log', Mandatory = $true, ValueFromPipeline = $true)]
        [Parameter(ParameterSetName = 'File', Mandatory = $true, ValueFromPipeline = $true)]
        [Parameter(ParameterSetName = 'FileWithSize', Mandatory = $true, ValueFromPipeline = $true)]
        [Parameter(ParameterSetName = 'FileWithMaxFiles', Mandatory = $true, ValueFromPipeline = $true)]
        [Parameter(ParameterSetName = 'FileWithMaxRolloverFiles', Mandatory = $true, ValueFromPipeline = $true)]
        [Parameter(ParameterSetName = 'FileWithSizeAndMaxFiles', Mandatory = $true, ValueFromPipeline = $true)]
        [Parameter(ParameterSetName = 'FileWithSizeAndMaxRolloverFiles', Mandatory = $true, ValueFromPipeline = $true)]
        [Microsoft.SqlServer.Management.Smo.Server]
        $ServerObject,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $AuditFilter,

        [Parameter()]
        [ValidateSet('Continue', 'FailOperation', 'Shutdown')]
        [System.String]
        $OnFailure,

        [Parameter()]
        [ValidateRange(1000, 2147483647)]
        [System.UInt32]
        $QueueDelay,

        [Parameter()]
        [ValidatePattern('^[0-9a-fA-F]{8}-(?:[0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$')]
        [System.String]
        $AuditGuid,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Refresh,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $PassThru,

        [Parameter(ParameterSetName = 'Log', Mandatory = $true)]
        [ValidateSet('SecurityLog', 'ApplicationLog')]
        [System.String]
        $LogType,

        [Parameter(ParameterSetName = 'File', Mandatory = $true)]
        [Parameter(ParameterSetName = 'FileWithSize', Mandatory = $true)]
        [Parameter(ParameterSetName = 'FileWithMaxFiles', Mandatory = $true)]
        [Parameter(ParameterSetName = 'FileWithMaxRolloverFiles', Mandatory = $true)]
        [Parameter(ParameterSetName = 'FileWithSizeAndMaxFiles', Mandatory = $true)]
        [Parameter(ParameterSetName = 'FileWithSizeAndMaxRolloverFiles', Mandatory = $true)]
        [ValidateScript({
                if (-not (Test-Path -Path $_))
                {
                    throw ($script:localizedData.Audit_PathParameterValueInvalid -f $_)
                }

                return $true
            })]
        [System.String]
        $Path,

        [Parameter(ParameterSetName = 'FileWithSize', Mandatory = $true)]
        [Parameter(ParameterSetName = 'FileWithSizeAndMaxFiles', Mandatory = $true)]
        [Parameter(ParameterSetName = 'FileWithSizeAndMaxRolloverFiles', Mandatory = $true)]
        [ValidateRange(2, 2147483647)]
        [System.UInt32]
        $MaximumFileSize,

        [Parameter(ParameterSetName = 'FileWithSize', Mandatory = $true)]
        [Parameter(ParameterSetName = 'FileWithSizeAndMaxFiles', Mandatory = $true)]
        [Parameter(ParameterSetName = 'FileWithSizeAndMaxRolloverFiles', Mandatory = $true)]
        [ValidateSet('Megabyte', 'Gigabyte', 'Terabyte')]
        [System.String]
        $MaximumFileSizeUnit,

        [Parameter(ParameterSetName = 'FileWithSizeAndMaxFiles', Mandatory = $true)]
        [Parameter(ParameterSetName = 'FileWithMaxFiles', Mandatory = $true)]
        [System.UInt32]
        $MaximumFiles,

        [Parameter(ParameterSetName = 'FileWithMaxFiles')]
        [Parameter(ParameterSetName = 'FileWithSizeAndMaxFiles')]
        [System.Management.Automation.SwitchParameter]
        $ReserveDiskSpace,

        [Parameter(ParameterSetName = 'FileWithSizeAndMaxRolloverFiles', Mandatory = $true)]
        [Parameter(ParameterSetName = 'FileWithMaxRolloverFiles', Mandatory = $true)]
        [ValidateRange(0, 2147483647)]
        [System.UInt32]
        $MaximumRolloverFiles
    )

    process
    {
        if ($Force.IsPresent -and -not $Confirm)
        {
            $ConfirmPreference = 'None'
        }

        $getSqlDscAuditParameters = @{
            ServerObject = $ServerObject
            Name         = $Name
            Refresh      = $Refresh
            ErrorAction  = 'SilentlyContinue'
        }

        $auditObject = Get-SqlDscAudit @getSqlDscAuditParameters

        if ($auditObject.Count -gt 0)
        {
            $auditAlreadyPresentMessage = $script:localizedData.Audit_AlreadyPresent -f $Name

            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new(
                    $auditAlreadyPresentMessage,
                    'NSDA0001', # cspell: disable-line
                    [System.Management.Automation.ErrorCategory]::InvalidOperation,
                    $DatabaseName
                )
            )
        }

        $auditObject = New-Object -TypeName 'Microsoft.SqlServer.Management.Smo.Audit' -ArgumentList @($ServerObject, $Name)

        $queryType = switch ($PSCmdlet.ParameterSetName)
        {
            'Log'
            {
                $LogType
            }

            default
            {
                'File'
            }
        }

        $auditObject.DestinationType = $queryType

        if ($PSCmdlet.ParameterSetName -match 'File')
        {
            $auditObject.FilePath = $Path

            if ($PSCmdlet.ParameterSetName -match 'FileWithSize')
            {
                $convertedMaximumFileSizeUnit = (
                    @{
                        Megabyte = 'MB'
                        Gigabyte = 'GB'
                        Terabyte = 'TB'
                    }
                ).$MaximumFileSizeUnit

                $auditObject.MaximumFileSize = $MaximumFileSize
                $auditObject.MaximumFileSizeUnit = $convertedMaximumFileSizeUnit
            }

            if ($PSCmdlet.ParameterSetName -in @('FileWithMaxFiles', 'FileWithSizeAndMaxFiles'))
            {
                $auditObject.MaximumFiles = $MaximumFiles

                if ($PSBoundParameters.ContainsKey('ReserveDiskSpace'))
                {
                    $auditObject.ReserveDiskSpace = $ReserveDiskSpace.IsPresent
                }
            }

            if ($PSCmdlet.ParameterSetName -in @('FileWithMaxRolloverFiles', 'FileWithSizeAndMaxRolloverFiles'))
            {
                $auditObject.MaximumRolloverFiles = $MaximumRolloverFiles
            }
        }

        if ($PSBoundParameters.ContainsKey('OnFailure'))
        {
            $auditObject.OnFailure = $OnFailure
        }

        if ($PSBoundParameters.ContainsKey('QueueDelay'))
        {
            $auditObject.QueueDelay = $QueueDelay
        }

        if ($PSBoundParameters.ContainsKey('AuditGuid'))
        {
            $auditObject.Guid = $AuditGuid
        }

        if ($PSBoundParameters.ContainsKey('AuditFilter'))
        {
            $auditObject.Filter = $AuditFilter
        }

        $verboseDescriptionMessage = $script:localizedData.Audit_Add_ShouldProcessVerboseDescription -f $Name, $ServerObject.InstanceName
        $verboseWarningMessage = $script:localizedData.Audit_Add_ShouldProcessVerboseWarning -f $Name
        $captionMessage = $script:localizedData.Audit_Add_ShouldProcessCaption

        if ($PSCmdlet.ShouldProcess($verboseDescriptionMessage, $verboseWarningMessage, $captionMessage))
        {
            $auditObject.Create()

            if ($PassThru.IsPresent)
            {
                return $auditObject
            }
        }
    }
}
#EndRegion '.\Public\New-SqlDscAudit.ps1' 319
#Region '.\Public\Remove-SqlDscAudit.ps1' -1

<#
    .SYNOPSIS
        Removes a server audit.

    .DESCRIPTION
        This command removes a server audit from a SQL Server Database Engine instance.

    .PARAMETER ServerObject
        Specifies current server connection object.

    .PARAMETER AuditObject
        Specifies an audit object to remove.

    .PARAMETER Name
        Specifies the name of the server audit to be removed.

    .PARAMETER Force
        Specifies that the audit should be removed without any confirmation.

    .PARAMETER Refresh
        Specifies that the **ServerObject**'s audits should be refreshed before
        trying removing the audit object. This is helpful when audits could have
        been modified outside of the **ServerObject**, for example through T-SQL.
        But on instances with a large amount of audits it might be better to make
        sure the **ServerObject** is recent enough, or pass in **AuditObject**.

    .EXAMPLE
        $serverObject = Connect-SqlDscDatabaseEngine -InstanceName 'MyInstance'
        $auditObject = $sqlServerObject | Get-SqlDscAudit -Name 'MyFileAudit'
        $auditObject | Remove-SqlDscAudit

        Removes the audit named **MyFileAudit**.

    .EXAMPLE
        $serverObject = Connect-SqlDscDatabaseEngine -InstanceName 'MyInstance'
        $sqlServerObject | Remove-SqlDscAudit -Name 'MyFileAudit'

        Removes the audit named **MyFileAudit**.

    .OUTPUTS
        None.
#>
function Remove-SqlDscAudit
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseSyntacticallyCorrectExamples', '', Justification = 'Because the rule does not yet support parsing the code when a parameter type is not available. The ScriptAnalyzer rule UseSyntacticallyCorrectExamples will always error in the editor due to https://github.com/indented-automation/Indented.ScriptAnalyzerRules/issues/8.')]
    [OutputType()]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param
    (
        [Parameter(ParameterSetName = 'ServerObject', Mandatory = $true, ValueFromPipeline = $true)]
        [Microsoft.SqlServer.Management.Smo.Server]
        $ServerObject,

        [Parameter(ParameterSetName = 'AuditObject', Mandatory = $true, ValueFromPipeline = $true)]
        [Microsoft.SqlServer.Management.Smo.Audit]
        $AuditObject,

        [Parameter(ParameterSetName = 'ServerObject', Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force,

        [Parameter(ParameterSetName = 'ServerObject')]
        [System.Management.Automation.SwitchParameter]
        $Refresh
    )

    process
    {
        if ($Force.IsPresent -and -not $Confirm)
        {
            $ConfirmPreference = 'None'
        }

        if ($PSCmdlet.ParameterSetName -eq 'ServerObject')
        {
            $getSqlDscAuditParameters = @{
                ServerObject = $ServerObject
                Name         = $Name
                Refresh      = $Refresh
                ErrorAction  = 'Stop'
            }

            # If this command does not find the audit it will throw an exception.
            $auditObjectArray = Get-SqlDscAudit @getSqlDscAuditParameters

            # Pick the only object in the array.
            $AuditObject = $auditObjectArray | Select-Object -First 1
        }

        $verboseDescriptionMessage = $script:localizedData.Audit_Remove_ShouldProcessVerboseDescription -f $AuditObject.Name, $AuditObject.Parent.InstanceName
        $verboseWarningMessage = $script:localizedData.Audit_Remove_ShouldProcessVerboseWarning -f $AuditObject.Name
        $captionMessage = $script:localizedData.Audit_Remove_ShouldProcessCaption

        if ($PSCmdlet.ShouldProcess($verboseDescriptionMessage, $verboseWarningMessage, $captionMessage))
        {
            <#
                If the passed audit object has already been dropped, then we silently
                do nothing, using the method DropIfExist(), since the job is done.
            #>
            $AuditObject.DropIfExists()
        }
    }
}
#EndRegion '.\Public\Remove-SqlDscAudit.ps1' 108
#Region '.\Public\Remove-SqlDscNode.ps1' -1

<#
    .SYNOPSIS
        Removes a SQL Server node from an Failover Cluster instance (FCI).

    .DESCRIPTION
        Removes a SQL Server node from an Failover Cluster instance (FCI).

        See the link in the commands help for information on each parameter. The
        link points to SQL Server command line setup documentation.

    .PARAMETER MediaPath
        Specifies the path where to find the SQL Server installation media. On this
        path the SQL Server setup executable must be found.

    .PARAMETER Timeout
        Specifies how long to wait for the setup process to finish. Default value
        is `7200` seconds (2 hours). If the setup process does not finish before
        this time, an exception will be thrown.

    .PARAMETER Force
        If specified the command will not ask for confirmation. Same as if Confirm:$false
        is used.

    .PARAMETER InstanceName
        See the notes section for more information.

    .PARAMETER ConfirmIPDependencyChange
        See the notes section for more information.

    .LINK
        https://docs.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server-from-the-command-prompt

    .OUTPUTS
        None.

    .EXAMPLE
        Remove-SqlDscNode -InstanceName 'MyInstance' -MediaPath 'E:\'

        Removes the current node's SQL Server instance 'MyInstance' from the
        Failover Cluster instance.

    .NOTES
        All parameters has intentionally not been added to this comment-based help
        since it would take a lot of effort to keep them up to date. Instead there is
        a link in the comment-based help that points to the SQL Server command line
        setup documentation which will stay relevant.
#>
function Remove-SqlDscNode
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '', Justification = 'Because ShouldProcess is used in Invoke-SetupAction')]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $MediaPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $InstanceName,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $ConfirmIPDependencyChange,

        [Parameter()]
        [System.UInt32]
        $Timeout = 7200,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    Invoke-SetupAction -RemoveNode @PSBoundParameters
}
#EndRegion '.\Public\Remove-SqlDscNode.ps1' 78
#Region '.\Public\Remove-SqlDscTraceFlag.ps1' -1

<#
    .SYNOPSIS
        Removes trace flags from a Database Engine instance.

    .DESCRIPTION
        Removes trace flags from a Database Engine instance, keeping any other
        trace flags currently set.

    .PARAMETER ServiceObject
        Specifies the Service object on which to remove the trace flags.

    .PARAMETER ServerName
        Specifies the server name where the instance exist.

    .PARAMETER InstanceName
       Specifies the instance name on which to remove the trace flags.

    .PARAMETER TraceFlag
        Specifies the trace flags to remove.

    .PARAMETER Force
        Specifies that the trace flag should be removed without any confirmation.

    .EXAMPLE
        Remove-SqlDscTraceFlag -TraceFlag 4199

        Removes the trace flag 4199 from the Database Engine default instance
        on the server where the command in run.

    .EXAMPLE
        $serviceObject = Get-SqlDscManagedComputerService -ServiceType 'DatabaseEngine'
        Remove-SqlDscTraceFlag -ServiceObject $serviceObject -TraceFlag 4199

        Removes the trace flag 4199 from the Database Engine default instance
        on the server where the command in run.

    .EXAMPLE
        Remove-SqlDscTraceFlag -InstanceName 'SQL2022' -TraceFlag 4199,3226

        Removes the trace flags 4199 and 3226 from the Database Engine instance
        'SQL2022' on the server where the command in run.

    .EXAMPLE
        $serviceObject = Get-SqlDscManagedComputerService -ServiceType 'DatabaseEngine' -InstanceName 'SQL2022'
        Remove-SqlDscTraceFlag -ServiceObject $serviceObject -TraceFlag 4199,3226

        Removes the trace flags 4199 and 3226 from the Database Engine instance
        'SQL2022' on the server where the command in run.

    .OUTPUTS
        None.
#>
function Remove-SqlDscTraceFlag
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseSyntacticallyCorrectExamples', '', Justification = 'Because the rule does not yet support parsing the code when a parameter type is not available. The ScriptAnalyzer rule UseSyntacticallyCorrectExamples will always error in the editor due to https://github.com/indented-automation/Indented.ScriptAnalyzerRules/issues/8.')]
    [OutputType()]
    [CmdletBinding(DefaultParameterSetName = 'ByServerName', SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param
    (
        [Parameter(ParameterSetName = 'ByServiceObject', Mandatory = $true, ValueFromPipeline = $true)]
        [Microsoft.SqlServer.Management.Smo.Wmi.Service]
        $ServiceObject,

        [Parameter(ParameterSetName = 'ByServerName')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ServerName = (Get-ComputerName),

        [Parameter(ParameterSetName = 'ByServerName')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $InstanceName = 'MSSQLSERVER',

        [Parameter(Mandatory = $true)]
        [System.UInt32[]]
        $TraceFlag,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    begin
    {
        if ($Force.IsPresent -and -not $Confirm)
        {
            $ConfirmPreference = 'None'
        }
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq 'ByServiceObject')
        {
            $InstanceName = $ServiceObject.Name -replace '^MSSQL\$'
        }

        # Copy $PSBoundParameters to keep it intact.
        $getSqlDscTraceFlagParameters = @{} + $PSBoundParameters

        $commonParameters = [System.Management.Automation.PSCmdlet]::OptionalCommonParameters

        # Remove parameters that Get-SqlDscTraceFLag does not have/support.
        $commonParameters + @('Force', 'TraceFlag') |
            ForEach-Object -Process {
                $getSqlDscTraceFlagParameters.Remove($_)
            }

        $currentTraceFlags = Get-SqlDscTraceFlag @getSqlDscTraceFlagParameters -ErrorAction 'Stop'

        if ($currentTraceFlags)
        {
            # Must always return an array. An empty array when removing the last value.
            $desiredTraceFlags = [System.UInt32[]] @(
                $currentTraceFlags |
                    ForEach-Object -Process {
                        # Keep values that should not be removed.
                        if ($_ -notin $TraceFlag)
                        {
                            $_
                        }
                    }
            )

            $verboseDescriptionMessage = $script:localizedData.TraceFlag_Remove_ShouldProcessVerboseDescription -f $InstanceName, ($TraceFlag -join ', ')
            $verboseWarningMessage = $script:localizedData.TraceFlag_Remove_ShouldProcessVerboseWarning -f $InstanceName
            $captionMessage = $script:localizedData.TraceFlag_Remove_ShouldProcessCaption

            if ($PSCmdlet.ShouldProcess($verboseDescriptionMessage, $verboseWarningMessage, $captionMessage))
            {
                # Copy $PSBoundParameters to keep it intact.
                $setSqlDscTraceFlagParameters = @{} + $PSBoundParameters

                $setSqlDscTraceFlagParameters.TraceFLag = $desiredTraceFlags

                Set-SqlDscTraceFlag @setSqlDscTraceFlagParameters -ErrorAction 'Stop'
            }
        }
        else
        {
            Write-Debug -Message $script:localizedData.TraceFlag_Remove_NoCurrentTraceFlags
        }
    }
}
#EndRegion '.\Public\Remove-SqlDscTraceFlag.ps1' 145
#Region '.\Public\Repair-SqlDscBIReportServer.ps1' -1

<#
    .SYNOPSIS
        Repairs an existing SQL Server Power BI Report Server installation.

    .DESCRIPTION
        Repairs an existing SQL Server Power BI Report Server installation using
        the provided setup executable.

    .PARAMETER AcceptLicensingTerms
        Required parameter to be able to run unattended repair. By specifying this
        parameter you acknowledge the acceptance of all license terms and notices for
        the specified features, the terms and notices that the setup executable
        normally asks for.

    .PARAMETER MediaPath
        Specifies the path where to find the SQL Server installation media. On this
        path the SQL Server setup executable must be found.

    .PARAMETER ProductKey
        Specifies the product key to use for the repair, e.g. '12345-12345-12345-12345-12345'.
        This parameter is mutually exclusive with the parameter Edition.

    .PARAMETER EditionUpgrade
        Upgrades the edition of the installed product. Requires that either the
        ProductKey or the Edition parameter is also assigned. By default no edition
        upgrade is performed.

    .PARAMETER Edition
        Specifies a free custom edition to use for the repair. This parameter
        is mutually exclusive with the parameter ProductKey.

    .PARAMETER LogPath
        Specifies the file path where to write the log files, e.g. 'C:\Logs\Repair.log'.
        By default log files are created under %TEMP%.

    .PARAMETER InstallFolder
        Specifies the folder where to install the product, e.g. 'C:\Program Files\Power BI Report Server'.
        By default the product is installed under the default installation folder.

        PI Report Server: %ProgramFiles%\Microsoft Power BI Report Server

    .PARAMETER SuppressRestart
        Suppresses the restart of the computer after the repair is finished.
        By default the computer is restarted after the repair is finished.

    .PARAMETER Timeout
        Specifies how long to wait for the setup process to finish. Default value
        is `7200` seconds (2 hours). If the setup process does not finish before
        this time, an exception will be thrown.

    .PARAMETER Force
        If specified the command will not ask for confirmation. Same as if Confirm:$false
        is used.

    .PARAMETER PassThru
        If specified the command will return the setup process exit code.

    .OUTPUTS
        When PassThru is specified the function will return the setup process exit
        code as System.Int32. Otherwise, the function does not generate any output.

    .EXAMPLE
        Repair-SqlDscBIReportServer -AcceptLicensingTerms -MediaPath 'E:\PowerBIReportServer.exe'

        Repairs Power BI Report Server with default settings.

    .EXAMPLE
        Repair-SqlDscBIReportServer -AcceptLicensingTerms -MediaPath 'E:\PowerBIReportServer.exe' -ProductKey '12345-12345-12345-12345-12345' -EditionUpgrade

        Repairs Power BI Report Server and upgrades the edition using a
        product key.

    .EXAMPLE
        Repair-SqlDscBIReportServer -AcceptLicensingTerms -MediaPath 'E:\PowerBIReportServer.exe' -LogPath 'C:\Logs\PowerBIReportServer_Repair.log'

        Repairs Power BI Report Server and specifies a custom log path.

    .EXAMPLE
        $exitCode = Repair-SqlDscBIReportServer -AcceptLicensingTerms -MediaPath 'E:\PowerBIReportServer.exe' -PassThru

        Repairs Power BI Report Server with default settings and returns the setup exit code.
#>
function Repair-SqlDscBIReportServer
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '', Justification = 'Because ShouldProcess is used in Invoke-SetupAction')]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([System.Int32])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $AcceptLicensingTerms,

        [Parameter(Mandatory = $true)]
        [System.String]
        $MediaPath,

        [Parameter()]
        [System.String]
        $ProductKey,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $EditionUpgrade,

        [Parameter()]
        [ValidateSet('Developer', 'Evaluation', 'ExpressAdvanced')]
        [System.String]
        $Edition,

        [Parameter()]
        [System.String]
        $LogPath,

        [Parameter()]
        [System.String]
        $InstallFolder,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $SuppressRestart,

        [Parameter()]
        [System.UInt32]
        $Timeout = 7200,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $PassThru
    )

    $exitCode = Invoke-ReportServerSetupAction -Repair @PSBoundParameters

    if ($PassThru.IsPresent)
    {
        return $exitCode
    }
}
#EndRegion '.\Public\Repair-SqlDscBIReportServer.ps1' 143
#Region '.\Public\Repair-SqlDscReportingService.ps1' -1

<#
    .SYNOPSIS
        Repairs an existing SQL Server Reporting Services or Power BI Report Server
        installation.

    .DESCRIPTION
        Repairs an existing SQL Server Reporting Services or Power BI Report Server
        installation using the provided setup executable.

    .PARAMETER AcceptLicensingTerms
        Required parameter to be able to run unattended repair. By specifying this
        parameter you acknowledge the acceptance of all license terms and notices for
        the specified features, the terms and notices that the setup executable
        normally asks for.

    .PARAMETER MediaPath
        Specifies the path where to find the SQL Server installation media. On this
        path the SQL Server setup executable must be found.

    .PARAMETER ProductKey
        Specifies the product key to use for the repair, e.g. '12345-12345-12345-12345-12345'.
        This parameter is mutually exclusive with the parameter Edition.

    .PARAMETER EditionUpgrade
        Upgrades the edition of the installed product. Requires that either the
        ProductKey or the Edition parameter is also assigned. By default no edition
        upgrade is performed.

    .PARAMETER Edition
        Specifies a free custom edition to use for the repair. This parameter
        is mutually exclusive with the parameter ProductKey.

    .PARAMETER LogPath
        Specifies the file path where to write the log files, e.g. 'C:\Logs\Repair.log'.
        By default log files are created under %TEMP%.

    .PARAMETER InstallFolder
        Specifies the folder where to install the product, e.g. 'C:\Program Files\SSRS'.
        By default the product is installed under the default installation folder.

        Reporting Services: %ProgramFiles%\Microsoft SQL Server Reporting Services
        PI Report Server: %ProgramFiles%\Microsoft Power BI Report Server

    .PARAMETER SuppressRestart
        Suppresses the restart of the computer after the repair is finished.
        By default the computer is restarted after the repair is finished.

    .PARAMETER Timeout
        Specifies how long to wait for the setup process to finish. Default value
        is `7200` seconds (2 hours). If the setup process does not finish before
        this time, an exception will be thrown.

    .PARAMETER Force
        If specified the command will not ask for confirmation. Same as if Confirm:$false
        is used.

    .PARAMETER PassThru
        If specified the command will return the setup process exit code.

    .OUTPUTS
        When PassThru is specified the function will return the setup process exit
        code as System.Int32. Otherwise, the function does not generate any output.

    .EXAMPLE
        Repair-SqlDscReportingService -AcceptLicensingTerms -MediaPath 'E:\SQLServerReportingServices.exe'

        Repairs SQL Server Reporting Services with default settings.

    .EXAMPLE
        Repair-SqlDscReportingService -AcceptLicensingTerms -MediaPath 'E:\SQLServerReportingServices.exe' -ProductKey '12345-12345-12345-12345-12345' -EditionUpgrade

        Repairs SQL Server Reporting Services and upgrades the edition using a
        product key.

    .EXAMPLE
        Repair-SqlDscReportingService -AcceptLicensingTerms -MediaPath 'E:\PowerBIReportServer.exe' -LogPath 'C:\Logs\PowerBIReportServer_Repair.log'

        Repairs Power BI Report Server and specifies a custom log path.

    .EXAMPLE
        $exitCode = Repair-SqlDscReportingService -AcceptLicensingTerms -MediaPath 'E:\SQLServerReportingServices.exe' -PassThru

        Repairs SQL Server Reporting Services with default settings and returns the setup exit code.
#>
function Repair-SqlDscReportingService
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '', Justification = 'Because ShouldProcess is used in Invoke-SetupAction')]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([System.Int32])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $AcceptLicensingTerms,

        [Parameter(Mandatory = $true)]
        [System.String]
        $MediaPath,

        [Parameter()]
        [System.String]
        $ProductKey,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $EditionUpgrade,

        [Parameter()]
        [ValidateSet('Developer', 'Evaluation', 'ExpressAdvanced')]
        [System.String]
        $Edition,

        [Parameter()]
        [System.String]
        $LogPath,

        [Parameter()]
        [System.String]
        $InstallFolder,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $SuppressRestart,

        [Parameter()]
        [System.UInt32]
        $Timeout = 7200,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $PassThru
    )

    $exitCode = Invoke-ReportServerSetupAction -Repair @PSBoundParameters

    if ($PassThru.IsPresent)
    {
        return $exitCode
    }
}
#EndRegion '.\Public\Repair-SqlDscReportingService.ps1' 145
#Region '.\Public\Repair-SqlDscServer.ps1' -1

<#
    .SYNOPSIS
        Executes an setup action using Microsoft SQL Server setup executable.

    .DESCRIPTION
        Executes an setup action using Microsoft SQL Server setup executable.

        See the link in the commands help for information on each parameter. The
        link points to SQL Server command line setup documentation.

    .PARAMETER MediaPath
        Specifies the path where to find the SQL Server installation media. On this
        path the SQL Server setup executable must be found.

    .PARAMETER Timeout
        Specifies how long to wait for the setup process to finish. Default value
        is `7200` seconds (2 hours). If the setup process does not finish before
        this time, an exception will be thrown.

    .PARAMETER Force
        If specified the command will not ask for confirmation. Same as if Confirm:$false
        is used.

    .PARAMETER InstanceName
        See the notes section for more information.

    .PARAMETER Enu
        See the notes section for more information.

    .PARAMETER Features
        See the notes section for more information.

    .PARAMETER PBEngSvcAccount
        See the notes section for more information.

    .PARAMETER PBEngSvcPassword
        See the notes section for more information.

    .PARAMETER PBEngSvcStartupType
        See the notes section for more information.

    .PARAMETER PBStartPortRange
        See the notes section for more information.

    .PARAMETER PBEndPortRange
        See the notes section for more information.

    .PARAMETER PBScaleOut
        See the notes section for more information.

    .LINK
        https://docs.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server-from-the-command-prompt

    .OUTPUTS
        None.

    .EXAMPLE
        Repair-SqlDscServer -InstanceName 'MyInstance' -Features 'SQLENGINE' -MediaPath 'E:\'

        Repairs the database engine of the instance 'MyInstance'.

    .NOTES
        The parameters are intentionally not described since it would take a lot
        of effort to keep them up to date. Instead there is a link that points to
        the SQL Server command line setup documentation which will stay relevant.
#>
function Repair-SqlDscServer
{
    # cSpell: ignore AZUREEXTENSION
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '', Justification = 'Because ShouldProcess is used in Invoke-SetupAction')]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $MediaPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $InstanceName,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Enu,

        [Parameter(Mandatory = $true)]
        [ValidateSet(
            'SQL',
            'SQLEngine', # Part of parent feature SQL
            'Replication', # Part of parent feature SQL
            'FullText', # Part of parent feature SQL
            'DQ', # Part of parent feature SQL
            'PolyBase', # Part of parent feature SQL
            'PolyBaseCore', # Part of parent feature SQL
            'PolyBaseJava', # Part of parent feature SQL
            'AdvancedAnalytics', # Part of parent feature SQL
            'SQL_INST_MR', # Part of parent feature SQL
            'SQL_INST_MPY', # Part of parent feature SQL
            'SQL_INST_JAVA', # Part of parent feature SQL
            'AS',
            'RS',
            'RS_SHP',
            'RS_SHPWFE', # cspell: disable-line
            'DQC',
            'IS',
            'IS_Master', # Part of parent feature IS
            'IS_Worker', # Part of parent feature IS
            'MDS',
            'SQL_SHARED_MPY',
            'SQL_SHARED_MR',
            'Tools',
            'BC', # Part of parent feature Tools
            'Conn', # Part of parent feature Tools
            'DREPLAY_CTLR', # Part of parent feature Tools (cspell: disable-line)
            'DREPLAY_CLT', # Part of parent feature Tools (cspell: disable-line)
            'SNAC_SDK', # Part of parent feature Tools (cspell: disable-line)
            'SDK', # Part of parent feature Tools
            'LocalDB', # Part of parent feature Tools
            'AZUREEXTENSION'
        )]
        [System.String[]]
        $Features,

        [Parameter()]
        [System.String]
        $PBEngSvcAccount,

        [Parameter()]
        [System.Security.SecureString]
        $PBEngSvcPassword,

        [Parameter()]
        [ValidateSet('Automatic', 'Disabled', 'Manual')]
        [System.String]
        $PBEngSvcStartupType,

        [Parameter()]
        [System.UInt16]
        $PBStartPortRange,

        [Parameter()]
        [System.UInt16]
        $PBEndPortRange,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $PBScaleOut,

        [Parameter()]
        [System.UInt32]
        $Timeout = 7200,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    Invoke-SetupAction -Repair @PSBoundParameters
}
#EndRegion '.\Public\Repair-SqlDscServer.ps1' 161
#Region '.\Public\Save-SqlDscSqlServerMediaFile.ps1' -1

<#
    .SYNOPSIS
        Downloads SQL Server media from a provided URL and saves the downloaded
        media file to the specified file path

    .DESCRIPTION
        The Save-SqlDscSqlServerMediaFile function downloads SQL Server media from a
        provided URL and saves the downloaded media file to the specified file path.

        If the URL ends with ".exe", it is treated as an executable that downloads
        an ISO. If it doesn't, it is treated as a direct link to an ISO.

        The function also prints the SHA1 hash of the downloaded file.

    .PARAMETER Url
        The URL of the SQL Server media to download.

    .PARAMETER DestinationPath
        The file path where the downloaded media file should be saved.

    .PARAMETER FileName
        The file name of the downloaded media file. Defaults to media.iso if not
        provided.

    .PARAMETER Language
        The language parameter specifies the language of the downloaded iso. This
        parameter is only used when the provided URL is an executable file. Defaults
        to 'en-US' if not provided.

    .PARAMETER Quiet
        Disables verbose progress output during the download process.

    .PARAMETER Force
        Forces the download of the media file even if the file already exists at the
        specified destination path.

    .PARAMETER SkipExecution
        When specified, and the URL points to an executable (.exe), the function will
        download the executable file without executing it. The file will be saved using
        the provided FileName parameter.

    .EXAMPLE
        Save-SqlDscSqlServerMediaFile -Url 'https://download.microsoft.com/download/c/c/9/cc9c6797-383c-4b24-8920-dc057c1de9d3/SQL2022-SSEI-Dev.exe' -DestinationPath 'C:\path\to\destination'

        This downloads the SQL Server 2022 media and saves it to the specified destination path.

    .EXAMPLE
        Save-SqlDscSqlServerMediaFile -Url 'https://download.microsoft.com/download/c/c/9/cc9c6797-383c-4b24-8920-dc057c1de9d3/SQL2022-SSEI-Dev.exe' -DestinationPath 'C:\path\to\destination' -SkipExecution

        This downloads the SQL Server 2022 installer executable but does not execute it to extract the ISO.

    .EXAMPLE
        Save-SqlDscSqlServerMediaFile -Url 'https://download.microsoft.com/download/d/a/2/da259851-b941-459d-989c-54a18a5d44dd/SQL2019-SSEI-Dev.exe' -DestinationPath 'C:\path\to\destination'

        This downloads the SQL Server 2019 media and saves it to the specified destination path.

    .EXAMPLE
        Save-SqlDscSqlServerMediaFile -Url 'https://download.microsoft.com/download/E/F/2/EF23C21D-7860-4F05-88CE-39AA114B014B/SQLServer2017-x64-ENU.iso' -DestinationPath 'C:\path\to\destination'

        This downloads the SQL Server 2017 media and saves it to the specified destination path.

    .EXAMPLE
        Save-SqlDscSqlServerMediaFile -Url 'https://download.microsoft.com/download/9/0/7/907AD35F-9F9C-43A5-9789-52470555DB90/ENU/SQLServer2016SP1-FullSlipstream-x64-ENU.iso' -DestinationPath 'C:\path\to\destination'

        This downloads the SQL Server 2016 media and saves it to the specified destination path.
#>
function Save-SqlDscSqlServerMediaFile
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([System.IO.FileInfo])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Url,

        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]
        [ValidateScript({ Test-Path $_ -PathType 'Container' })]
        $DestinationPath,

        [Parameter()]
        [System.String]
        $FileName = 'media.iso',

        [Parameter()]
        # Supported by SQL Server version 2019 and 2022.
        [ValidateSet('zh-CN', 'zh-TW', 'en-US', 'fr-FR', 'de-DE', 'it-IT', 'ja-JP', 'ko-KR', 'pt-BR', 'ru-RU', 'es-ES')]
        [System.String]
        $Language = 'en-US',

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Quiet,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $SkipExecution
    )

    if ($Force.IsPresent -and -not $Confirm)
    {
        $ConfirmPreference = 'None'
    }

    if ((Get-Item -Path "$DestinationPath/*.iso" -Force).Count -gt 0 -and -not $SkipExecution)
    {
        $auditAlreadyPresentMessage = $script:localizedData.SqlServerMediaFile_Save_InvalidDestinationFolder

        $PSCmdlet.ThrowTerminatingError(
            [System.Management.Automation.ErrorRecord]::new(
                $auditAlreadyPresentMessage,
                'SSDSSM0001', # cspell: disable-line
                [System.Management.Automation.ErrorCategory]::InvalidOperation,
                $DestinationPath
            )
        )
    }

    $destinationFilePath = Join-Path -Path $DestinationPath -ChildPath $FileName

    if ((Test-Path -Path $destinationFilePath))
    {
        $verboseDescriptionMessage = $script:localizedData.SqlServerMediaFile_Save_ShouldProcessVerboseDescription -f $destinationFilePath
        $verboseWarningMessage = $script:localizedData.SqlServerMediaFile_Save_ShouldProcessVerboseWarning -f $destinationFilePath
        $captionMessage = $script:localizedData.SqlServerMediaFile_Save_ShouldProcessCaption

        if ($PSCmdlet.ShouldProcess($verboseDescriptionMessage, $verboseWarningMessage, $captionMessage))
        {
            Remove-Item -Path $destinationFilePath -Force
        }
        else
        {
            return
        }
    }

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $isExecutable = $false

    if ($Url -match '\.exe$')
    {
        $isExecutable = $true

        # Change the file extension of the destination file path to .exe
        $destinationExecutableFilePath = [System.IO.Path]::ChangeExtension($destinationFilePath, 'exe')

        $downloadedFilePath = $destinationExecutableFilePath
    }
    else
    {
        $downloadedFilePath = $destinationFilePath
    }

    if ($Quiet.IsPresent)
    {
        <#
            By switching to 'SilentlyContinue' it removes the progress bar of
            Invoke-WebRequest and should also theoretically increase the download
            speed.
        #>
        $previousProgressPreference = $ProgressPreference
        $ProgressPreference = 'SilentlyContinue'
    }

    Write-Verbose -Message ($script:localizedData.SqlServerMediaFile_Save_DownloadingInformation -f $Url)

    # Download the URL content.
    Invoke-WebRequest -Uri $Url -OutFile $downloadedFilePath | Out-Null

    if ($Quiet.IsPresent)
    {
        # Revert the progress preference back to the previous value.
        $ProgressPreference = $previousProgressPreference
    }

    if ($isExecutable -and -not $SkipExecution)
    {
        Write-Verbose -Message $script:localizedData.SqlServerMediaFile_Save_IsExecutable

        $executableArguments = @(
            '/Quiet'
        )

        if ($VerbosePreference -eq 'SilentlyContinue')
        {
            $executableArguments += @(
                '/HideProgressBar'
            )
        }
        else
        {
            $executableArguments += @(
                '/Verbose'
            )
        }

        $executableArguments += @(
            '/Action=Download',
            "/Language=$Language",
            '/MediaType=ISO',
            "/MediaPath=$destinationPath"
        )

        $startProcessArgumentList = $executableArguments -join ' '

        # Download ISO media using the downloaded executable.
        Start-Process -FilePath $destinationExecutableFilePath -ArgumentList $startProcessArgumentList -Wait

        Write-Verbose -Message $script:localizedData.SqlServerMediaFile_Save_RemovingExecutable

        # Remove the downloaded executable.
        Remove-Item -Path $destinationExecutableFilePath -Force

        # Get all the iso files in the destination path and if there are more than one throw an error.
        $isoFile = Get-Item -Path "$DestinationPath/*.iso" -Force

        if ($isoFile.Count -gt 1)
        {
            $writeErrorParameters = @{
                Message      = $script:localizedData.SqlServerMediaFile_Save_MultipleFilesFoundAfterDownload
                Category     = 'InvalidOperation'
                ErrorId      = 'SSDSSM0002' # CSpell: disable-line
                TargetObject = $ServiceType
            }

            Write-Error @writeErrorParameters
        }

        Write-Verbose -Message ($script:localizedData.SqlServerMediaFile_Save_RenamingFile -f $isoFile.Name, $FileName)

        # Rename the iso file in the destination path.
        Rename-Item -Path $isoFile.FullName -NewName $FileName -Force
    }

    return (Get-Item -Path $destinationFilePath)
}
#EndRegion '.\Public\Save-SqlDscSqlServerMediaFile.ps1' 243
#Region '.\Public\Set-SqlDscAudit.ps1' -1

<#
    .SYNOPSIS
        Updates a server audit.

    .DESCRIPTION
        This command updates and existing server audit on a SQL Server Database Engine
        instance.

    .PARAMETER ServerObject
        Specifies current server connection object.

    .PARAMETER AuditObject
        Specifies an audit object to update.

    .PARAMETER Name
        Specifies the name of the server audit to be updated.

    .PARAMETER AuditFilter
        Specifies the filter that should be used on the audit. See [predicate expression](https://docs.microsoft.com/en-us/sql/t-sql/statements/create-server-audit-transact-sql)
        how to write the syntax for the filter.

    .PARAMETER OnFailure
        Specifies what should happen when writing events to the store fails.
        This can be 'Continue', 'FailOperation', or 'Shutdown'.

    .PARAMETER QueueDelay
        Specifies the maximum delay before a event is written to the store.
        When set to low this could impact server performance.
        When set to high events could be missing when a server crashes.

    .PARAMETER AuditGuid
        Specifies the GUID found in the mirrored database. To support scenarios such
        as database mirroring an audit needs a specific GUID.

    .PARAMETER Force
        Specifies that the audit should be updated without any confirmation.

    .PARAMETER Refresh
        Specifies that the audit object should be refreshed before updating. This
        is helpful when audits could have been modified outside of the **ServerObject**,
        for example through T-SQL. But on instances with a large amount of audits
        it might be better to make sure the ServerObject is recent enough.

    .PARAMETER Path
        Specifies the location where te log files wil be placed.

    .PARAMETER ReserveDiskSpace
        Specifies if the needed file space should be reserved. To use this parameter
        the parameter **MaximumFiles** must also be used.

    .PARAMETER MaximumFiles
        Specifies the number of files on disk.

    .PARAMETER MaximumFileSize
        Specifies the maximum file size in units by parameter MaximumFileSizeUnit.
        Minimum allowed value is 2 (MB). It also allowed to set the value to 0 which
        mean unlimited file size.

    .PARAMETER MaximumFileSizeUnit
        Specifies the unit that is used for the file size. this can be KB, MB or GB.

    .PARAMETER MaximumRolloverFiles
        Specifies the amount of files on disk before SQL Server starts reusing
        the files. If not specified then it is set to unlimited.

    .PARAMETER PassThru
        If specified the changed audit object will be returned.

    .OUTPUTS
        `[Microsoft.SqlServer.Management.Smo.Audit]` is passing parameter **PassThru**,
         otherwise none.

    .EXAMPLE
        $serverObject = Connect-SqlDscDatabaseEngine -InstanceName 'MyInstance'
        $sqlServerObject | Set-SqlDscAudit -Name 'MyFileAudit' -Path 'E:\auditFolder' -QueueDelay 1000

        Updates the file audit named **MyFileAudit** by setting the path to ''E:\auditFolder'
        and the queue delay to 1000.

    .EXAMPLE
        $serverObject = Connect-SqlDscDatabaseEngine -InstanceName 'MyInstance'
        $sqlServerObject | New-SqlDscAudit -Name 'MyAppLogAudit' -QueueDelay 1000

        Updates the application log audit named **MyAppLogAudit** by setting the
        queue delay to 1000.

    .EXAMPLE
        $serverObject = Connect-SqlDscDatabaseEngine -InstanceName 'MyInstance'
        $sqlServerObject | Set-SqlDscAudit -Name 'MyFileAudit' -Path 'E:\auditFolder' -QueueDelay 1000 -PassThru

        Updates the file audit named **MyFileAudit** by setting the path to ''E:\auditFolder'
        and the queue delay to 1000, and returns the Audit object.

    .NOTES
        This command has the confirm impact level set to high since an audit is
        unknown to be enable at the point when the command is issued.

        See the SQL Server documentation for more information for the possible
        parameter values to pass to this command: https://docs.microsoft.com/en-us/sql/t-sql/statements/create-server-audit-transact-sql
#>
function Set-SqlDscAudit
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseSyntacticallyCorrectExamples', '', Justification = 'Because the rule does not yet support parsing the code when a parameter type is not available. The ScriptAnalyzer rule UseSyntacticallyCorrectExamples will always error in the editor due to https://github.com/indented-automation/Indented.ScriptAnalyzerRules/issues/8.')]
    [OutputType([Microsoft.SqlServer.Management.Smo.Audit])]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param
    (
        [Parameter(ParameterSetName = 'ServerObject', Mandatory = $true, ValueFromPipeline = $true)]
        [Parameter(ParameterSetName = 'ServerObjectWithSize', Mandatory = $true, ValueFromPipeline = $true)]
        [Parameter(ParameterSetName = 'ServerObjectWithMaxFiles', Mandatory = $true, ValueFromPipeline = $true)]
        [Parameter(ParameterSetName = 'ServerObjectWithMaxRolloverFiles', Mandatory = $true, ValueFromPipeline = $true)]
        [Parameter(ParameterSetName = 'ServerObjectWithSizeAndMaxFiles', Mandatory = $true, ValueFromPipeline = $true)]
        [Parameter(ParameterSetName = 'ServerObjectWithSizeAndMaxRolloverFiles', Mandatory = $true, ValueFromPipeline = $true)]
        [Microsoft.SqlServer.Management.Smo.Server]
        $ServerObject,

        [Parameter(ParameterSetName = 'AuditObject', Mandatory = $true, ValueFromPipeline = $true)]
        [Parameter(ParameterSetName = 'AuditObjectWithSize', Mandatory = $true, ValueFromPipeline = $true)]
        [Parameter(ParameterSetName = 'AuditObjectWithMaxFiles', Mandatory = $true, ValueFromPipeline = $true)]
        [Parameter(ParameterSetName = 'AuditObjectWithMaxRolloverFiles', Mandatory = $true, ValueFromPipeline = $true)]
        [Parameter(ParameterSetName = 'AuditObjectWithSizeAndMaxFiles', Mandatory = $true, ValueFromPipeline = $true)]
        [Parameter(ParameterSetName = 'AuditObjectWithSizeAndMaxRolloverFiles', Mandatory = $true, ValueFromPipeline = $true)]
        [Microsoft.SqlServer.Management.Smo.Audit]
        $AuditObject,

        [Parameter(ParameterSetName = 'ServerObject', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ServerObjectWithSize', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ServerObjectWithMaxFiles', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ServerObjectWithMaxRolloverFiles', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ServerObjectWithSizeAndMaxFiles', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ServerObjectWithSizeAndMaxRolloverFiles', Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $AuditFilter,

        [Parameter()]
        [ValidateSet('Continue', 'FailOperation', 'Shutdown')]
        [System.String]
        $OnFailure,

        [Parameter()]
        [ValidateScript({
                if ($_ -in 1..999 -or $_ -gt 2147483647)
                {
                    throw ($script:localizedData.Audit_QueueDelayParameterValueInvalid -f $_)
                }

                return $true
            })]
        [System.UInt32]
        $QueueDelay,

        [Parameter()]
        [ValidatePattern('^[0-9a-fA-F]{8}-(?:[0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$')]
        [System.String]
        $AuditGuid,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Refresh,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $PassThru,

        [Parameter(ParameterSetName = 'ServerObject')]
        [Parameter(ParameterSetName = 'ServerObjectWithSize')]
        [Parameter(ParameterSetName = 'ServerObjectWithMaxFiles')]
        [Parameter(ParameterSetName = 'ServerObjectWithMaxRolloverFiles')]
        [Parameter(ParameterSetName = 'ServerObjectWithSizeAndMaxFiles')]
        [Parameter(ParameterSetName = 'ServerObjectWithSizeAndMaxRolloverFiles')]
        [Parameter(ParameterSetName = 'AuditObject')]
        [Parameter(ParameterSetName = 'AuditObjectWithSize')]
        [Parameter(ParameterSetName = 'AuditObjectWithMaxFiles')]
        [Parameter(ParameterSetName = 'AuditObjectWithMaxRolloverFiles')]
        [Parameter(ParameterSetName = 'AuditObjectWithSizeAndMaxFiles')]
        [Parameter(ParameterSetName = 'AuditObjectWithSizeAndMaxRolloverFiles')]
        [ValidateScript({
                if (-not (Test-Path -Path $_))
                {
                    throw ($script:localizedData.Audit_PathParameterValueInvalid -f $_)
                }

                return $true
            })]
        [System.String]
        $Path,

        [Parameter(ParameterSetName = 'ServerObjectWithSize', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ServerObjectWithSizeAndMaxFiles', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ServerObjectWithSizeAndMaxRolloverFiles', Mandatory = $true)]
        [Parameter(ParameterSetName = 'AuditObjectWithSize', Mandatory = $true)]
        [Parameter(ParameterSetName = 'AuditObjectWithSizeAndMaxFiles', Mandatory = $true)]
        [Parameter(ParameterSetName = 'AuditObjectWithSizeAndMaxRolloverFiles', Mandatory = $true)]
        [ValidateScript({
                if ($_ -eq 1 -or $_ -gt 2147483647)
                {
                    throw ($script:localizedData.Audit_MaximumFileSizeParameterValueInvalid -f $_)
                }

                return $true
            })]
        [System.UInt32]
        $MaximumFileSize,

        [Parameter(ParameterSetName = 'ServerObjectWithSize', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ServerObjectWithSizeAndMaxFiles', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ServerObjectWithSizeAndMaxRolloverFiles', Mandatory = $true)]
        [Parameter(ParameterSetName = 'AuditObjectWithSize', Mandatory = $true)]
        [Parameter(ParameterSetName = 'AuditObjectWithSizeAndMaxFiles', Mandatory = $true)]
        [Parameter(ParameterSetName = 'AuditObjectWithSizeAndMaxRolloverFiles', Mandatory = $true)]
        [ValidateSet('Megabyte', 'Gigabyte', 'Terabyte')]
        [System.String]
        $MaximumFileSizeUnit,

        [Parameter(ParameterSetName = 'ServerObjectWithMaxFiles', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ServerObjectWithSizeAndMaxFiles', Mandatory = $true)]
        [Parameter(ParameterSetName = 'AuditObjectWithMaxFiles', Mandatory = $true)]
        [Parameter(ParameterSetName = 'AuditObjectWithSizeAndMaxFiles', Mandatory = $true)]
        [System.UInt32]
        $MaximumFiles,

        [Parameter(ParameterSetName = 'ServerObjectWithMaxFiles')]
        [Parameter(ParameterSetName = 'ServerObjectWithSizeAndMaxFiles')]
        [Parameter(ParameterSetName = 'AuditObjectWithMaxFiles')]
        [Parameter(ParameterSetName = 'AuditObjectWithSizeAndMaxFiles')]
        [System.Management.Automation.SwitchParameter]
        $ReserveDiskSpace,

        [Parameter(ParameterSetName = 'ServerObjectWithMaxRolloverFiles', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ServerObjectWithSizeAndMaxRolloverFiles', Mandatory = $true)]
        [Parameter(ParameterSetName = 'AuditObjectWithMaxRolloverFiles', Mandatory = $true)]
        [Parameter(ParameterSetName = 'AuditObjectWithSizeAndMaxRolloverFiles', Mandatory = $true)]
        [ValidateRange(0, 2147483647)]
        [System.UInt32]
        $MaximumRolloverFiles
    )

    process
    {
        if ($Force.IsPresent -and -not $Confirm)
        {
            $ConfirmPreference = 'None'
        }

        if ($PSCmdlet.ParameterSetName -eq 'ServerObject')
        {
            $getSqlDscAuditParameters = @{
                ServerObject = $ServerObject
                Name         = $Name
                Refresh      = $Refresh
                ErrorAction  = 'Stop'
            }

            # If this command does not find the audit it will throw an exception.
            $auditObjectArray = Get-SqlDscAudit @getSqlDscAuditParameters

            # Pick the only object in the array.
            $AuditObject = $auditObjectArray | Select-Object -First 1
        }

        if ($Refresh.IsPresent)
        {
            $AuditObject.Refresh()
        }

        $verboseDescriptionMessage = $script:localizedData.Audit_Update_ShouldProcessVerboseDescription -f $AuditObject.Name, $AuditObject.Parent.InstanceName
        $verboseWarningMessage = $script:localizedData.Audit_Update_ShouldProcessVerboseWarning -f $AuditObject.Name
        $captionMessage = $script:localizedData.Audit_Update_ShouldProcessCaption

        if ($PSCmdlet.ShouldProcess($verboseDescriptionMessage, $verboseWarningMessage, $captionMessage))
        {
            if ($PSBoundParameters.ContainsKey('Path'))
            {
                $AuditObject.FilePath = $Path
            }

            if ($PSCmdlet.ParameterSetName -match 'WithSize')
            {
                $queryMaximumFileSizeUnit = (
                    @{
                        Megabyte = 'MB'
                        Gigabyte = 'GB'
                        Terabyte = 'TB'
                    }
                ).$MaximumFileSizeUnit

                $AuditObject.MaximumFileSize = $MaximumFileSize
                $AuditObject.MaximumFileSizeUnit = $queryMaximumFileSizeUnit
            }

            if ($PSCmdlet.ParameterSetName -match 'MaxFiles')
            {
                if ($AuditObject.MaximumRolloverFiles)
                {
                    # Switching to MaximumFiles instead of MaximumRolloverFiles.
                    $AuditObject.MaximumRolloverFiles = 0

                    # Must run method Alter() before setting MaximumFiles.
                    $AuditObject.Alter()
                }

                $AuditObject.MaximumFiles = $MaximumFiles

                if ($PSBoundParameters.ContainsKey('ReserveDiskSpace'))
                {
                    $AuditObject.ReserveDiskSpace = $ReserveDiskSpace.IsPresent
                }
            }

            if ($PSCmdlet.ParameterSetName -match 'MaxRolloverFiles')
            {
                if ($AuditObject.MaximumFiles)
                {
                    # Switching to MaximumRolloverFiles instead of MaximumFiles.
                    $AuditObject.MaximumFiles = 0

                    # Must run method Alter() before setting MaximumRolloverFiles.
                    $AuditObject.Alter()
                }

                $AuditObject.MaximumRolloverFiles = $MaximumRolloverFiles
            }

            if ($PSBoundParameters.ContainsKey('OnFailure'))
            {
                $AuditObject.OnFailure = $OnFailure
            }

            if ($PSBoundParameters.ContainsKey('QueueDelay'))
            {
                $AuditObject.QueueDelay = $QueueDelay
            }

            if ($PSBoundParameters.ContainsKey('AuditGuid'))
            {
                $AuditObject.Guid = $AuditGuid
            }

            if ($PSBoundParameters.ContainsKey('AuditFilter'))
            {
                $AuditObject.Filter = $AuditFilter
            }

            $AuditObject.Alter()

            if ($PassThru.IsPresent)
            {
                return $AuditObject
            }
        }
    }
}
#EndRegion '.\Public\Set-SqlDscAudit.ps1' 361
#Region '.\Public\Set-SqlDscDatabasePermission.ps1' -1

<#
    .SYNOPSIS
        Set permission for a database principal.

    .DESCRIPTION
        Set permission for a database principal.

    .PARAMETER ServerObject
        Specifies current server connection object.

    .PARAMETER DatabaseName
        Specifies the database name.

    .PARAMETER Name
        Specifies the name of the database principal for which the permissions are
        set.

    .PARAMETER State
        Specifies the state of the permission.

    .PARAMETER Permission
        Specifies the permissions.

    .PARAMETER WithGrant
        Specifies that the principal should also be granted the right to grant
        other principals the same permission. This parameter is only valid when
        parameter **State** is set to `Grant` or `Revoke`. When the parameter
        **State** is set to `Revoke` the right to grant will also be revoked,
        and the revocation will cascade.

    .PARAMETER Force
        Specifies that the permissions should be set without any confirmation.

    .OUTPUTS
        None.

    .EXAMPLE
        $serverInstance = Connect-SqlDscDatabaseEngine

        $setPermission = [Microsoft.SqlServer.Management.Smo.DatabasePermissionSet] @{
            Connect = $true
            Update = $true
        }

        Set-SqlDscDatabasePermission -ServerObject $serverInstance -DatabaseName 'MyDatabase' -Name 'MyPrincipal' -State 'Grant' -Permission $setPermission

        Sets the permissions for the principal 'MyPrincipal'.

    .NOTES
        This command excludes fixed roles like _db_datareader_ by default, and will
        always throw a non-terminating error if a fixed role is specified as **Name**.

        If specifying `-ErrorAction 'SilentlyContinue'` then the command will silently
        ignore if the database (parameter **DatabaseName**) is not present or the
        database principal is not present. If specifying `-ErrorAction 'Stop'` the
        command will throw an error if the database or database principal is missing.
#>
function Set-SqlDscDatabasePermission
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseSyntacticallyCorrectExamples', '', Justification = 'Because the rule does not yet support parsing the code when a parameter type is not available. The ScriptAnalyzer rule UseSyntacticallyCorrectExamples will always error in the editor due to https://github.com/indented-automation/Indented.ScriptAnalyzerRules/issues/8.')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('AvoidThrowOutsideOfTry', '', Justification = 'Because the code throws based on an prior expression')]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Microsoft.SqlServer.Management.Smo.Server]
        $ServerObject,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DatabaseName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Grant', 'Deny', 'Revoke')]
        [System.String]
        $State,

        [Parameter(Mandatory = $true)]
        [Microsoft.SqlServer.Management.Smo.DatabasePermissionSet]
        $Permission,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $WithGrant,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    process
    {
        if ($State -eq 'Deny' -and $WithGrant.IsPresent)
        {
            Write-Warning -Message $script:localizedData.DatabasePermission_IgnoreWithGrantForStateDeny
        }

        if ($Force.IsPresent -and -not $Confirm)
        {
            $ConfirmPreference = 'None'
        }

        $sqlDatabaseObject = $null

        if ($ServerObject.Databases)
        {
            $sqlDatabaseObject = $ServerObject.Databases[$DatabaseName]
        }

        if ($sqlDatabaseObject)
        {
            $testSqlDscIsDatabasePrincipalParameters = @{
                ServerObject      = $ServerObject
                DatabaseName      = $DatabaseName
                Name              = $Name
                ExcludeFixedRoles = $true
            }

            $isDatabasePrincipal = Test-SqlDscIsDatabasePrincipal @testSqlDscIsDatabasePrincipalParameters

            if ($isDatabasePrincipal)
            {
                # Get the permissions names that are set to $true in the DatabasePermissionSet.
                $permissionName = $Permission |
                    Get-Member -MemberType 'Property' |
                    Select-Object -ExpandProperty 'Name' |
                    Where-Object -FilterScript {
                        $Permission.$_
                    }

                $verboseDescriptionMessage = $script:localizedData.DatabasePermission_ChangePermissionShouldProcessVerboseDescription -f $Name, $DatabaseName, $ServerObject.InstanceName
                $verboseWarningMessage = $script:localizedData.DatabasePermission_ChangePermissionShouldProcessVerboseWarning -f $Name
                $captionMessage = $script:localizedData.DatabasePermission_ChangePermissionShouldProcessCaption

                if (-not $PSCmdlet.ShouldProcess($verboseDescriptionMessage, $verboseWarningMessage, $captionMessage))
                {
                    # Return without doing anything if the user did not want to continue processing.
                    return
                }

                switch ($State)
                {
                    'Grant'
                    {
                        Write-Verbose -Message (
                            $script:localizedData.DatabasePermission_GrantPermission -f ($permissionName -join ','), $Name
                        )

                        if ($WithGrant.IsPresent)
                        {
                            $sqlDatabaseObject.Grant($Permission, $Name, $true)
                        }
                        else
                        {
                            $sqlDatabaseObject.Grant($Permission, $Name)
                        }
                    }

                    'Deny'
                    {
                        Write-Verbose -Message (
                            $script:localizedData.DatabasePermission_DenyPermission -f ($permissionName -join ','), $Name
                        )

                        $sqlDatabaseObject.Deny($Permission, $Name)
                    }

                    'Revoke'
                    {
                        Write-Verbose -Message (
                            $script:localizedData.DatabasePermission_RevokePermission -f ($permissionName -join ','), $Name
                        )

                        if ($WithGrant.IsPresent)
                        {
                            $sqlDatabaseObject.Revoke($Permission, $Name, $false, $true)
                        }
                        else
                        {
                            $sqlDatabaseObject.Revoke($Permission, $Name)
                        }
                    }
                }
            }
            else
            {
                $missingPrincipalMessage = $script:localizedData.DatabasePermission_MissingPrincipal -f $Name, $DatabaseName

                $PSCmdlet.ThrowTerminatingError(
                    [System.Management.Automation.ErrorRecord]::new(
                        $missingPrincipalMessage,
                        'GSDDP0001', # cSpell: disable-line
                        [System.Management.Automation.ErrorCategory]::InvalidOperation,
                        $Name
                    )
                )
            }
        }
        else
        {
            $missingDatabaseMessage = $script:localizedData.DatabasePermission_MissingDatabase -f $DatabaseName

            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new(
                    $missingDatabaseMessage,
                    'GSDDP0002', # cSpell: disable-line
                    [System.Management.Automation.ErrorCategory]::InvalidOperation,
                    $DatabaseName
                )
            )
        }
    }
}
#EndRegion '.\Public\Set-SqlDscDatabasePermission.ps1' 219
#Region '.\Public\Set-SqlDscServerPermission.ps1' -1

<#
    .SYNOPSIS
        Set permission for a server principal.

    .DESCRIPTION
        This command sets the permissions for a existing principal on a SQL Server
        Database Engine instance.

    .PARAMETER ServerObject
        Specifies current server connection object.

    .PARAMETER Name
        Specifies the name of the principal for which the permissions are set.

    .PARAMETER State
        Specifies the state of the permission.

    .PARAMETER Permission
        Specifies the permissions.

    .PARAMETER WithGrant
        Specifies that the principal should also be granted the right to grant
        other principals the same permission. This parameter is only valid when
        parameter **State** is set to `Grant` or `Revoke`. When the parameter
        **State** is set to `Revoke` the right to grant will also be revoked,
        and the revocation will cascade.

    .PARAMETER Force
        Specifies that the permissions should be set without any confirmation.

    .OUTPUTS
        None.

    .EXAMPLE
        $serverInstance = Connect-SqlDscDatabaseEngine

        $setPermission = [Microsoft.SqlServer.Management.Smo.ServerPermissionSet] @{
            Connect = $true
            Update = $true
        }

        Set-SqlDscServerPermission -ServerObject $serverInstance -Name 'MyPrincipal' -State 'Grant' -Permission $setPermission

        Sets the permissions for the principal 'MyPrincipal'.

    .NOTES
        If specifying `-ErrorAction 'SilentlyContinue'` then the command will silently
        ignore if the principal is not present. If specifying `-ErrorAction 'Stop'` the
        command will throw an error if the principal is missing.
#>
function Set-SqlDscServerPermission
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseSyntacticallyCorrectExamples', '', Justification = 'Because the rule does not yet support parsing the code when a parameter type is not available. The ScriptAnalyzer rule UseSyntacticallyCorrectExamples will always error in the editor due to https://github.com/indented-automation/Indented.ScriptAnalyzerRules/issues/8.')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('AvoidThrowOutsideOfTry', '', Justification = 'Because the code throws based on an prior expression')]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Microsoft.SqlServer.Management.Smo.Server]
        $ServerObject,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Grant', 'Deny', 'Revoke')]
        [System.String]
        $State,

        [Parameter(Mandatory = $true)]
        [Microsoft.SqlServer.Management.Smo.ServerPermissionSet]
        $Permission,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $WithGrant,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    process
    {
        if ($State -eq 'Deny' -and $WithGrant.IsPresent)
        {
            Write-Warning -Message $script:localizedData.ServerPermission_IgnoreWithGrantForStateDeny
        }

        if ($Force.IsPresent -and -not $Confirm)
        {
            $ConfirmPreference = 'None'
        }

        $testSqlDscIsPrincipalParameters = @{
            ServerObject = $ServerObject
            Name         = $Name
        }

        $isLogin = Test-SqlDscIsLogin @testSqlDscIsPrincipalParameters
        $isRole = Test-SqlDscIsRole @testSqlDscIsPrincipalParameters

        if ($isLogin -or $isRole)
        {
            # Get the permissions names that are set to $true in the ServerPermissionSet.
            $permissionName = $Permission |
                Get-Member -MemberType 'Property' |
                Select-Object -ExpandProperty 'Name' |
                Where-Object -FilterScript {
                    $Permission.$_
                }

            $verboseDescriptionMessage = $script:localizedData.ServerPermission_ChangePermissionShouldProcessVerboseDescription -f $Name, $ServerObject.InstanceName
            $verboseWarningMessage = $script:localizedData.ServerPermission_ChangePermissionShouldProcessVerboseWarning -f $Name
            $captionMessage = $script:localizedData.ServerPermission_ChangePermissionShouldProcessCaption

            if (-not $PSCmdlet.ShouldProcess($verboseDescriptionMessage, $verboseWarningMessage, $captionMessage))
            {
                # Return without doing anything if the user did not want to continue processing.
                return
            }

            switch ($State)
            {
                'Grant'
                {
                    Write-Verbose -Message (
                        $script:localizedData.ServerPermission_GrantPermission -f ($permissionName -join ','), $Name
                    )

                    if ($WithGrant.IsPresent)
                    {
                        $ServerObject.Grant($Permission, $Name, $true)
                    }
                    else
                    {
                        $ServerObject.Grant($Permission, $Name)
                    }
                }

                'Deny'
                {
                    Write-Verbose -Message (
                        $script:localizedData.ServerPermission_DenyPermission -f ($permissionName -join ','), $Name
                    )

                    $ServerObject.Deny($Permission, $Name)
                }

                'Revoke'
                {
                    Write-Verbose -Message (
                        $script:localizedData.ServerPermission_RevokePermission -f ($permissionName -join ','), $Name
                    )

                    if ($WithGrant.IsPresent)
                    {
                        $ServerObject.Revoke($Permission, $Name, $false, $true)
                    }
                    else
                    {
                        $ServerObject.Revoke($Permission, $Name)
                    }
                }
            }
        }
        else
        {
            $missingPrincipalMessage = $script:localizedData.ServerPermission_MissingPrincipal -f $Name, $ServerObject.InstanceName

            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new(
                    $missingPrincipalMessage,
                    'GSDDP0001', # cSpell: disable-line
                    [System.Management.Automation.ErrorCategory]::InvalidOperation,
                    $Name
                )
            )
        }
    }
}
#EndRegion '.\Public\Set-SqlDscServerPermission.ps1' 184
#Region '.\Public\Set-SqlDscStartupParameter.ps1' -1

<#
    .SYNOPSIS
        Sets startup parameters on a Database Engine instance.

    .DESCRIPTION
        Sets startup parameters on a Database Engine instance.

    .PARAMETER ServiceObject
        Specifies the Service object on which to set the startup parameters.

    .PARAMETER ServerName
        Specifies the server name where the instance exist.

    .PARAMETER InstanceName
       Specifies the instance name on which to set the startup parameters.

    .PARAMETER TraceFlag
        Specifies the trace flags to set.

    .PARAMETER InternalTraceFlag
        Specifies the internal trace flags to set.

        From the [Database Engine Service Startup Options](https://learn.microsoft.com/en-us/sql/database-engine/configure-windows/database-engine-service-startup-options)
        documentation: "...this sets other internal trace flags that are required
        only by SQL Server support engineers."

    .PARAMETER Force
        Specifies that the startup parameters should be set without any confirmation.

    .EXAMPLE
        Set-SqlDscStartupParameters -TraceFlag 4199

        Replaces the trace flags with 4199 on the Database Engine default instance
        on the server where the command in run.

    .EXAMPLE
        $serviceObject = Get-SqlDscManagedComputerService -ServiceType 'DatabaseEngine'
        Set-SqlDscTraceFlag -ServiceObject $serviceObject -TraceFlag 4199

        Replaces the trace flags with 4199 on the Database Engine default instance
        on the server where the command in run.

    .EXAMPLE
        Set-SqlDscTraceFlag -InstanceName 'SQL2022' -TraceFlag @()

        Removes all the trace flags from the Database Engine instance 'SQL2022'
        on the server where the command in run.

    .OUTPUTS
        None.

    .NOTES
        This command should support setting the values according to this documentation:
        https://learn.microsoft.com/en-us/sql/database-engine/configure-windows/database-engine-service-startup-options
#>
function Set-SqlDscStartupParameter
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseSyntacticallyCorrectExamples', '', Justification = 'Because the rule does not yet support parsing the code when a parameter type is not available. The ScriptAnalyzer rule UseSyntacticallyCorrectExamples will always error in the editor due to https://github.com/indented-automation/Indented.ScriptAnalyzerRules/issues/8.')]
    [OutputType()]
    [CmdletBinding(DefaultParameterSetName = 'ByServerName', SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param
    (
        [Parameter(ParameterSetName = 'ByServiceObject', Mandatory = $true, ValueFromPipeline = $true)]
        [Microsoft.SqlServer.Management.Smo.Wmi.Service]
        $ServiceObject,

        [Parameter(ParameterSetName = 'ByServerName')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ServerName = (Get-ComputerName),

        [Parameter(ParameterSetName = 'ByServerName')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $InstanceName = 'MSSQLSERVER',

        [Parameter()]
        [AllowEmptyCollection()]
        [System.UInt32[]]
        $TraceFlag,

        [Parameter()]
        [AllowEmptyCollection()]
        [System.UInt32[]]
        $InternalTraceFlag,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    begin
    {
        Assert-ElevatedUser -ErrorAction 'Stop'

        if ($Force.IsPresent -and -not $Confirm)
        {
            $ConfirmPreference = 'None'
        }
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq 'ByServiceObject')
        {
            $ServiceObject | Assert-ManagedServiceType -ServiceType 'DatabaseEngine'

            $InstanceName = $ServiceObject.Name -replace '^MSSQL\$'
        }

        if ($PSCmdlet.ParameterSetName -eq 'ByServerName')
        {
            $getSqlDscManagedComputerServiceParameters = @{
                ServerName   = $ServerName
                InstanceName = $InstanceName
                ServiceType  = 'DatabaseEngine'
                ErrorAction  = 'Stop'
            }

            $ServiceObject = Get-SqlDscManagedComputerService @getSqlDscManagedComputerServiceParameters

            if (-not $ServiceObject)
            {
                $writeErrorParameters = @{
                    Message      = $script:localizedData.StartupParameter_Set_FailedToFindServiceObject
                    Category     = 'InvalidOperation'
                    ErrorId      = 'SSDSP0002' # CSpell: disable-line
                    TargetObject = $ServiceObject
                }

                Write-Error @writeErrorParameters
            }
        }

        if ($ServiceObject)
        {
            $verboseDescriptionMessage = $script:localizedData.StartupParameter_Set_ShouldProcessVerboseDescription -f $InstanceName
            $verboseWarningMessage = $script:localizedData.StartupParameter_Set_ShouldProcessVerboseWarning -f $InstanceName
            $captionMessage = $script:localizedData.StartupParameter_Set_ShouldProcessCaption

            if ($PSCmdlet.ShouldProcess($verboseDescriptionMessage, $verboseWarningMessage, $captionMessage))
            {
                $startupParameters = [StartupParameters]::Parse($ServiceObject.StartupParameters)

                if ($PSBoundParameters.ContainsKey('TraceFlag'))
                {
                    $startupParameters.TraceFlag = $TraceFlag
                }

                if ($PSBoundParameters.ContainsKey('InternalTraceFlag'))
                {
                    $startupParameters.InternalTraceFlag = $InternalTraceFlag
                }

                $ServiceObject.StartupParameters = $startupParameters.ToString()
                $ServiceObject.Alter()
            }
        }
    }
}
#EndRegion '.\Public\Set-SqlDscStartupParameter.ps1' 161
#Region '.\Public\Set-SqlDscTraceFlag.ps1' -1

<#
    .SYNOPSIS
        Sets trace flags on a Database Engine instance.

    .DESCRIPTION
        Sets trace flags on a Database Engine instance, replacing any trace flags
        currently set.

    .PARAMETER ServiceObject
        Specifies the Service object on which to set the trace flags.

    .PARAMETER ServerName
        Specifies the server name where the instance exist.

    .PARAMETER InstanceName
       Specifies the instance name on which to set the trace flags.

    .PARAMETER TraceFlag
        Specifies the trace flags to set.

    .PARAMETER Force
        Specifies that the trace flag should be set without any confirmation.

    .EXAMPLE
        Set-SqlDscTraceFlag -TraceFlag 4199

        Replaces the trace flags with 4199 on the Database Engine default instance
        on the server where the command in run.

    .EXAMPLE
        $serviceObject = Get-SqlDscManagedComputerService -ServiceType 'DatabaseEngine'
        Set-SqlDscTraceFlag -ServiceObject $serviceObject -TraceFlag 4199

        Replaces the trace flags with 4199 on the Database Engine default instance
        on the server where the command in run.

    .EXAMPLE
        Set-SqlDscTraceFlag -InstanceName 'SQL2022' -TraceFlag 4199,3226

        Replaces the trace flags with 4199 and 3226 on the Database Engine instance
        'SQL2022' on the server where the command in run.

    .EXAMPLE
        $serviceObject = Get-SqlDscManagedComputerService -ServiceType 'DatabaseEngine' -InstanceName 'SQL2022'
        Set-SqlDscTraceFlag -ServiceObject $serviceObject -TraceFlag 4199,3226

        Replaces the trace flags with 4199 and 3226 on the Database Engine instance
        'SQL2022' on the server where the command in run.

    .EXAMPLE
        Set-SqlDscTraceFlag -InstanceName 'SQL2022' -TraceFlag @()

        Removes all the trace flags from the Database Engine instance 'SQL2022'
        on the server where the command in run.

    .OUTPUTS
        None.
#>
function Set-SqlDscTraceFlag
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseSyntacticallyCorrectExamples', '', Justification = 'Because the rule does not yet support parsing the code when a parameter type is not available. The ScriptAnalyzer rule UseSyntacticallyCorrectExamples will always error in the editor due to https://github.com/indented-automation/Indented.ScriptAnalyzerRules/issues/8.')]
    [OutputType()]
    [CmdletBinding(DefaultParameterSetName = 'ByServerName', SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param
    (
        [Parameter(ParameterSetName = 'ByServiceObject', Mandatory = $true, ValueFromPipeline = $true)]
        [Microsoft.SqlServer.Management.Smo.Wmi.Service]
        $ServiceObject,

        [Parameter(ParameterSetName = 'ByServerName')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ServerName = (Get-ComputerName),

        [Parameter(ParameterSetName = 'ByServerName')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $InstanceName = 'MSSQLSERVER',

        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.UInt32[]]
        $TraceFlag,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    begin
    {
        if ($Force.IsPresent -and -not $Confirm)
        {
            $ConfirmPreference = 'None'
        }
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq 'ByServiceObject')
        {
            $InstanceName = $ServiceObject.Name -replace '^MSSQL\$'
        }

        $verboseDescriptionMessage = $script:localizedData.TraceFlag_Set_ShouldProcessVerboseDescription -f $InstanceName, ($TraceFlag -join ', ')
        $verboseWarningMessage = $script:localizedData.TraceFlag_Set_ShouldProcessVerboseWarning -f $InstanceName
        $captionMessage = $script:localizedData.TraceFlag_Set_ShouldProcessCaption

        if ($PSCmdlet.ShouldProcess($verboseDescriptionMessage, $verboseWarningMessage, $captionMessage))
        {
            Set-SqlDscStartupParameter @PSBoundParameters
        }
    }
}
#EndRegion '.\Public\Set-SqlDscTraceFlag.ps1' 115
#Region '.\Public\Test-SqlDscIsDatabasePrincipal.ps1' -1

<#
    .SYNOPSIS
        Returns whether the database principal exist.

    .DESCRIPTION
        Returns whether the database principal exist.

    .PARAMETER ServerObject
        Specifies current server connection object.

    .PARAMETER DatabaseName
        Specifies the SQL database name.

    .PARAMETER Name
        Specifies the name of the database principal.

    .PARAMETER ExcludeUsers
        Specifies that database users should not be evaluated.

    .PARAMETER ExcludeRoles
        Specifies that database roles should not be evaluated for the specified
        name. This will also exclude fixed roles.

    .PARAMETER ExcludeFixedRoles
        Specifies that fixed roles should not be evaluated for the specified name.

    .PARAMETER ExcludeApplicationRoles
        Specifies that fixed application roles should not be evaluated for the
        specified name.

    .OUTPUTS
        [System.Boolean]

    .EXAMPLE
        $serverInstance = Connect-SqlDscDatabaseEngine
        Test-SqlDscIsDatabasePrincipal -ServerObject $serverInstance -DatabaseName 'MyDatabase' -Name 'MyPrincipal'

        Returns $true if the principal exist in the database, if not $false is returned.

    .EXAMPLE
        $serverInstance = Connect-SqlDscDatabaseEngine
        Test-SqlDscIsDatabasePrincipal -ServerObject $serverInstance -DatabaseName 'MyDatabase' -Name 'MyPrincipal' -ExcludeUsers

        Returns $true if the principal exist in the database and is not a user, if not $false is returned.

    .EXAMPLE
        $serverInstance = Connect-SqlDscDatabaseEngine
        Test-SqlDscIsDatabasePrincipal -ServerObject $serverInstance -DatabaseName 'MyDatabase' -Name 'MyPrincipal' -ExcludeRoles

        Returns $true if the principal exist in the database and is not a role, if not $false is returned.

    .EXAMPLE
        $serverInstance = Connect-SqlDscDatabaseEngine
        Test-SqlDscIsDatabasePrincipal -ServerObject $serverInstance -DatabaseName 'MyDatabase' -Name 'MyPrincipal' -ExcludeFixedRoles

        Returns $true if the principal exist in the database and is not a fixed role, if not $false is returned.

    .EXAMPLE
        $serverInstance = Connect-SqlDscDatabaseEngine
        Test-SqlDscIsDatabasePrincipal -ServerObject $serverInstance -DatabaseName 'MyDatabase' -Name 'MyPrincipal' -ExcludeApplicationRoles

        Returns $true if the principal exist in the database and is not a application role, if not $false is returned.
#>
function Test-SqlDscIsDatabasePrincipal
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseSyntacticallyCorrectExamples', '', Justification = 'Because the rule does not yet support parsing the code when a parameter type is not available. The ScriptAnalyzer rule UseSyntacticallyCorrectExamples will always error in the editor due to https://github.com/indented-automation/Indented.ScriptAnalyzerRules/issues/8.')]
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Microsoft.SqlServer.Management.Smo.Server]
        $ServerObject,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DatabaseName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $ExcludeUsers,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $ExcludeRoles,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $ExcludeFixedRoles,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $ExcludeApplicationRoles
    )

    process
    {
        $principalExist = $false

        $sqlDatabaseObject = $ServerObject.Databases[$DatabaseName]

        if (-not $sqlDatabaseObject)
        {
            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new(
                    ($script:localizedData.IsDatabasePrincipal_DatabaseMissing -f $DatabaseName),
                    'TSDISO0001', # cSpell: disable-line
                    [System.Management.Automation.ErrorCategory]::InvalidOperation,
                    $DatabaseName
                )
            )
        }

        if (-not $ExcludeUsers.IsPresent -and $sqlDatabaseObject.Users[$Name])
        {
            $principalExist = $true
        }

        if (-not $ExcludeRoles.IsPresent)
        {
            $userDefinedRole = if ($ExcludeFixedRoles.IsPresent)
            {
                # Skip fixed roles like db_datareader.
                $sqlDatabaseObject.Roles | Where-Object -FilterScript {
                    -not $_.IsFixedRole -and $_.Name -eq $Name
                }
            }
            else
            {
                $sqlDatabaseObject.Roles[$Name]
            }

            if ($userDefinedRole)
            {
                $principalExist = $true
            }
        }

        if (-not $ExcludeApplicationRoles.IsPresent -and $sqlDatabaseObject.ApplicationRoles[$Name])
        {
            $principalExist = $true
        }

        return $principalExist
    }
}
#EndRegion '.\Public\Test-SqlDscIsDatabasePrincipal.ps1' 151
#Region '.\Public\Test-SqlDscIsLogin.ps1' -1

<#
    .SYNOPSIS
        Returns whether the server principal exist and is a login.

    .DESCRIPTION
        Returns whether the server principal exist and is a login.

    .PARAMETER ServerObject
        Specifies current server connection object.

    .PARAMETER Name
        Specifies the name of the server principal.

    .OUTPUTS
        [System.Boolean]

    .EXAMPLE
        $serverInstance = Connect-SqlDscDatabaseEngine
        Test-SqlDscIsLogin -ServerObject $serverInstance -Name 'MyPrincipal'

        Returns $true if the principal exist as a login, if not $false is returned.
#>
function Test-SqlDscIsLogin
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseSyntacticallyCorrectExamples', '', Justification = 'Because the rule does not yet support parsing the code when a parameter type is not available. The ScriptAnalyzer rule UseSyntacticallyCorrectExamples will always error in the editor due to https://github.com/indented-automation/Indented.ScriptAnalyzerRules/issues/8.')]
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Microsoft.SqlServer.Management.Smo.Server]
        $ServerObject,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    process
    {
        $loginExist = $false

        if ($ServerObject.Logins[$Name])
        {
            $loginExist = $true
        }

        return $loginExist
    }
}
#EndRegion '.\Public\Test-SqlDscIsLogin.ps1' 51
#Region '.\Public\Test-SqlDscIsRole.ps1' -1

<#
    .SYNOPSIS
        Returns whether the database principal exists and is a database role.

    .DESCRIPTION
        Returns whether the database principal exist and is a database role.

    .PARAMETER ServerObject
        Specifies current server connection object.

    .PARAMETER Name
        Specifies the name of the database principal.

    .OUTPUTS
        [System.Boolean]

    .EXAMPLE
        $serverInstance = Connect-SqlDscDatabaseEngine
        Test-SqlDscIsRole -ServerObject $serverInstance -Name 'MyPrincipal'

        Returns $true if the principal exist as role, if not $false is returned.
#>
function Test-SqlDscIsRole
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseSyntacticallyCorrectExamples', '', Justification = 'Because the rule does not yet support parsing the code when a parameter type is not available. The ScriptAnalyzer rule UseSyntacticallyCorrectExamples will always error in the editor due to https://github.com/indented-automation/Indented.ScriptAnalyzerRules/issues/8.')]
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Microsoft.SqlServer.Management.Smo.Server]
        $ServerObject,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    process
    {
        $principalExist = $false

        if ($ServerObject.Roles[$Name])
        {
            $principalExist = $true
        }

        return $principalExist
    }
}
#EndRegion '.\Public\Test-SqlDscIsRole.ps1' 51
#Region '.\Public\Test-SqlDscIsSupportedFeature.ps1' -1

<#
    .SYNOPSIS
        Tests that a feature is supported by a Microsoft SQL Server major version.

    .DESCRIPTION
        Tests that a feature is supported by a Microsoft SQL Server major version.

    .PARAMETER Feature
       Specifies the feature to evaluate.

    .PARAMETER ProductVersion
       Specifies the product version of the Microsoft SQL Server. At minimum the
       major version must be provided.

    .EXAMPLE
        Test-SqlDscIsSupportedFeature -Feature 'RS' -ProductVersion '13'

        Returns $true if the feature is supported.

    .OUTPUTS
        [System.Boolean]
#>
function Test-SqlDscIsSupportedFeature
{
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.String]
        $Feature,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ProductVersion
    )

    begin
    {
        $targetMajorVersion = ($ProductVersion -split '\.')[0]

        <#
            List of features that was removed from a specific major version (and later).
            Feature list: https://learn.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server-from-the-command-prompt#Feature
        #>
        $removedFeaturesPerMajorVersion = @{
            13 = @('ADV_SSMS', 'SSMS') # cSpell: disable-line
            14 = @('RS', 'RS_SHP', 'RS_SHPWFE') # cSpell: disable-line
            16 = @('Tools', 'BC', 'CONN', 'BC', 'DREPLAY_CTLR', 'DREPLAY_CLT', 'SNAC_SDK', 'SDK', 'PolyBaseJava', 'SQL_INST_MR', 'SQL_INST_MPY', 'SQL_SHARED_MPY', 'SQL_SHARED_MR') # cSpell: disable-line
        }

        <#
            List of features that was added to a specific major version.
            Feature list: https://learn.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server-from-the-command-prompt#Feature
        #>
        $addedFeaturesPerMajorVersion = @{
            13 = @('SQL_INST_MR', 'SQL_INST_MPY', 'SQL_INST_JAVA')
            15 = @('PolyBaseCore', 'PolyBaseJava', 'SQL_INST_JAVA') # cSpell: disable-line
        }

        # Evaluate features that was removed and are unsupported for the target's major version.
        $targetUnsupportedFeatures = $removedFeaturesPerMajorVersion.Keys |
            Where-Object -FilterScript {
                $_ -le $targetMajorVersion
            } |
            ForEach-Object -Process {
                $removedFeaturesPerMajorVersion.$_
            }

        <#
            Evaluate features that was added to higher major versions than the
            target's major version which will be unsupported for the target's
            major version.
        #>
        $targetUnsupportedFeatures += $addedFeaturesPerMajorVersion.Keys |
            Where-Object -FilterScript {
                $_ -gt $targetMajorVersion
            } |
            ForEach-Object -Process {
                $addedFeaturesPerMajorVersion.$_
            }

        $supported = $true
    }

    process
    {
        # This does case-insensitive match against the list of unsupported features.
        if ($targetUnsupportedFeatures -and $Feature -in $targetUnsupportedFeatures)
        {
            $supported = $false
        }
    }

    end
    {
        return $supported
    }
}
#EndRegion '.\Public\Test-SqlDscIsSupportedFeature.ps1' 100
#Region '.\Public\Test-SqlDscRSInstalled.ps1' -1

<#
    .SYNOPSIS
        Tests if a SQL Server Reporting Services or Power BI Report Server instance
        is installed.

    .DESCRIPTION
        Tests if a SQL Server Reporting Services or Power BI Report Server instance
        is installed on the local server. The command returns $true if the specified
        instance exists and $false if it does not.

    .PARAMETER InstanceName
        Specifies the name of the SQL Server Reporting Services or Power BI Report Server
        instance to check for. This parameter is required.

    .EXAMPLE
        Test-SqlDscRSInstalled -InstanceName 'SSRS'

        Tests if a SQL Server Reporting Services instance named 'SSRS' is installed.
        Returns $true if the instance exists and $false if it does not.

    .EXAMPLE
        Test-SqlDscRSInstalled -InstanceName 'PBIRS'

        Tests if a Power BI Report Server instance named 'PBIRS' is installed.
        Returns $true if the instance exists and $false if it does not.

    .OUTPUTS
        System.Boolean

        Returns $true if the specified instance exists and $false if it does not.
#>
function Test-SqlDscRSInstalled
{
    # cSpell: ignore PBIRS
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $InstanceName
    )

    Write-Verbose -Message ($script:localizedData.Test_SqlDscRSInstalled_Checking -f $InstanceName)

    $reportingServices = Get-SqlDscRSSetupConfiguration -InstanceName $InstanceName -ErrorAction 'SilentlyContinue'

    if ($reportingServices)
    {
        Write-Verbose -Message ($script:localizedData.Test_SqlDscRSInstalled_Found -f $InstanceName)

        return $true
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.Test_SqlDscRSInstalled_NotFound -f $InstanceName)

        return $false
    }
}
#EndRegion '.\Public\Test-SqlDscRSInstalled.ps1' 61
#Region '.\Public\Uninstall-SqlDscBIReportServer.ps1' -1

<#
    .SYNOPSIS
        Uninstalls SQL Server Power BI Report Server.

    .DESCRIPTION
        Uninstalls SQL Server Power BI Report Server using the provided setup executable.

    .PARAMETER MediaPath
        Specifies the path where to find the SQL Server installation media. On this
        path the SQL Server setup executable must be found.

    .PARAMETER LogPath
        Specifies the file path where to write the log files, e.g. 'C:\Logs\Uninstall.log'.
        By default log files are created under %TEMP%.

    .PARAMETER SuppressRestart
        Suppresses the restart of the computer after the uninstallation is finished.
        By default the computer is restarted after the uninstallation is finished.

    .PARAMETER Timeout
        Specifies how long to wait for the setup process to finish. Default value
        is `7200` seconds (2 hours). If the setup process does not finish before
        this time, an exception will be thrown.

    .PARAMETER Force
        If specified the command will not ask for confirmation. Same as if Confirm:$false
        is used.

    .PARAMETER PassThru
        If specified the command will return the setup process exit code.

    .OUTPUTS
        When PassThru is specified the function will return the setup process exit
        code as System.Int32. Otherwise, the function does not generate any output.

    .EXAMPLE
        Uninstall-SqlDscBIReportServer -MediaPath 'E:\PowerBIReportServer.exe'

        Uninstalls Power BI Report Server.

    .EXAMPLE
        Uninstall-SqlDscBIReportServer -MediaPath 'E:\PowerBIReportServer.exe' -LogPath 'C:\Logs\PowerBIReportServer_Uninstall.log'

        Uninstalls Power BI Report Server and specifies a custom log path.

    .EXAMPLE
        Uninstall-SqlDscBIReportServer -MediaPath 'E:\PowerBIReportServer.exe' -Force

        Uninstalls Power BI Report Server without prompting for confirmation.

    .EXAMPLE
        $exitCode = Uninstall-SqlDscBIReportServer -MediaPath 'E:\PowerBIReportServer.exe' -PassThru

        Uninstalls Power BI Report Server and returns the setup exit code.
#>
function Uninstall-SqlDscBIReportServer
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '', Justification = 'Because ShouldProcess is used in Invoke-SetupAction')]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([System.Int32])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $MediaPath,

        [Parameter()]
        [System.String]
        $LogPath,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $SuppressRestart,

        [Parameter()]
        [System.UInt32]
        $Timeout = 7200,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $PassThru
    )

    $exitCode = Invoke-ReportServerSetupAction -Uninstall @PSBoundParameters

    if ($PassThru.IsPresent)
    {
        return $exitCode
    }
}
#EndRegion '.\Public\Uninstall-SqlDscBIReportServer.ps1' 95
#Region '.\Public\Uninstall-SqlDscReportingService.ps1' -1

<#
    .SYNOPSIS
        Uninstalls SQL Server Reporting Services or Power BI Report Server.

    .DESCRIPTION
        Uninstalls SQL Server Reporting Services or Power BI Report Server using
        the provided setup executable.

    .PARAMETER MediaPath
        Specifies the path where to find the SQL Server installation media. On this
        path the SQL Server setup executable must be found.

    .PARAMETER LogPath
        Specifies the file path where to write the log files, e.g. 'C:\Logs\Uninstall.log'.
        By default log files are created under %TEMP%.

    .PARAMETER SuppressRestart
        Suppresses the restart of the computer after the uninstallation is finished.
        By default the computer is restarted after the uninstallation is finished.

    .PARAMETER Timeout
        Specifies how long to wait for the setup process to finish. Default value
        is `7200` seconds (2 hours). If the setup process does not finish before
        this time, an exception will be thrown.

    .PARAMETER Force
        If specified the command will not ask for confirmation. Same as if Confirm:$false
        is used.

    .PARAMETER PassThru
        If specified the command will return the setup process exit code.

    .OUTPUTS
        When PassThru is specified the function will return the setup process exit
        code as System.Int32. Otherwise, the function does not generate any output.

    .EXAMPLE
        Uninstall-SqlDscReportingService -MediaPath 'E:\SQLServerReportingServices.exe'

        Uninstalls SQL Server Reporting Services.

    .EXAMPLE
        Uninstall-SqlDscReportingService -MediaPath 'E:\PowerBIReportServer.exe' -LogPath 'C:\Logs\PowerBIReportServer_Uninstall.log'

        Uninstalls Power BI Report Server and specifies a custom log path.

    .EXAMPLE
        Uninstall-SqlDscReportingService -MediaPath 'E:\SQLServerReportingServices.exe' -Force

        Uninstalls SQL Server Reporting Services without prompting for confirmation.

    .EXAMPLE
        $exitCode = Uninstall-SqlDscReportingService -MediaPath 'E:\SQLServerReportingServices.exe' -PassThru

        Uninstalls SQL Server Reporting Services and returns the setup exit code.
#>
function Uninstall-SqlDscReportingService
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '', Justification = 'Because ShouldProcess is used in Invoke-SetupAction')]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([System.Int32])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $MediaPath,

        [Parameter()]
        [System.String]
        $LogPath,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $SuppressRestart,

        [Parameter()]
        [System.UInt32]
        $Timeout = 7200,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $PassThru
    )

    $exitCode = Invoke-ReportServerSetupAction -Uninstall @PSBoundParameters

    if ($PassThru.IsPresent)
    {
        return $exitCode
    }
}
#EndRegion '.\Public\Uninstall-SqlDscReportingService.ps1' 96
#Region '.\Public\Uninstall-SqlDscServer.ps1' -1

<#
    .SYNOPSIS
        Uninstall features from a Microsoft SQL Server instance.

    .DESCRIPTION
        Uninstall features from a Microsoft SQL Server instance.

        See the link in the commands help for information on each parameter for
        the setup action Uninstall. The link points to SQL Server command line
        setup documentation.

    .PARAMETER MediaPath
        Specifies the path where to find the SQL Server installation media. On this
        path the SQL Server setup executable must be found.

    .PARAMETER Timeout
        Specifies how long to wait for the setup process to finish. Default value
        is `7200` seconds (2 hours). If the setup process does not finish before
        this time, an exception will be thrown.

    .PARAMETER Force
        If specified the command will not ask for confirmation. Same as if Confirm:$false
        is used.

    .PARAMETER InstanceName
        See the notes section for more information.

    .PARAMETER Features
        See the notes section for more information.

    .PARAMETER SuppressPrivacyStatementNotice
        See the notes section for more information.

    .LINK
        https://docs.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server-from-the-command-prompt

    .OUTPUTS
        None.

    .EXAMPLE
        Uninstall-SqlDscServer -InstanceName 'MyInstance' -Features 'SQLENGINE' -MediaPath 'E:\'

        Uninstalls the database engine from the named instance MyInstance.

    .NOTES
        The parameters are intentionally not described since it would take a lot
        of effort to keep them up to date. Instead there is a link that points to
        the SQL Server command line setup documentation which will stay relevant.
#>
function Uninstall-SqlDscServer
{
    # cSpell: ignore AZUREEXTENSION
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '', Justification = 'Because ShouldProcess is used in Invoke-SetupAction')]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $MediaPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $InstanceName,

        [Parameter()]
        [ValidateSet(
            'SQL',
            'SQLEngine', # Part of parent feature SQL
            'Replication', # Part of parent feature SQL
            'FullText', # Part of parent feature SQL
            'DQ', # Part of parent feature SQL
            'PolyBase', # Part of parent feature SQL
            'PolyBaseCore', # Part of parent feature SQL
            'PolyBaseJava', # Part of parent feature SQL
            'AdvancedAnalytics', # Part of parent feature SQL
            'SQL_INST_MR', # Part of parent feature SQL
            'SQL_INST_MPY', # Part of parent feature SQL
            'SQL_INST_JAVA', # Part of parent feature SQL
            'AS',
            'RS',
            'RS_SHP',
            'RS_SHPWFE', # cspell: disable-line
            'DQC',
            'IS',
            'IS_Master', # Part of parent feature IS
            'IS_Worker', # Part of parent feature IS
            'MDS',
            'SQL_SHARED_MPY',
            'SQL_SHARED_MR',
            'Tools',
            'BC', # Part of parent feature Tools
            'Conn', # Part of parent feature Tools
            'DREPLAY_CTLR', # Part of parent feature Tools (cspell: disable-line)
            'DREPLAY_CLT', # Part of parent feature Tools (cspell: disable-line)
            'SNAC_SDK', # Part of parent feature Tools (cspell: disable-line)
            'SDK', # Part of parent feature Tools
            'LocalDB', # Part of parent feature Tools
            'AZUREEXTENSION'
        )]
        [System.String[]]
        $Features,

        [Parameter()]
        [System.UInt32]
        $Timeout = 7200,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $SuppressPrivacyStatementNotice
    )

    Invoke-SetupAction -Uninstall @PSBoundParameters
}
#EndRegion '.\Public\Uninstall-SqlDscServer.ps1' 119
#Region '.\suffix.ps1' -1

<#
    This check is made so that the real SqlServer or SQLPS module is not loaded into
    the session when the CI runs unit tests of SqlServerDsc. It would conflict with
    the stub types and stub commands used in the unit tests. This is a workaround
    because we cannot set a specific module as a nested module in the module manifest,
    the user must be able to choose to use either SQLPS or SqlServer.
#>
if (-not $env:SqlServerDscCI)
{
    try
    {
        <#
            Import SQL commands and types into the session, so that types used
            by commands can be parsed.
        #>
        Import-SqlDscPreferredModule -ErrorAction 'Stop'
    }
    catch
    {
        <#
            It is not possible to throw the error from Import-SqlDscPreferredModule
            since it will just fail the command Import-Module with an obscure error.
        #>
        Write-Warning -Message $_.Exception.Message
    }
}
#EndRegion '.\suffix.ps1' 27
