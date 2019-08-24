#
# Module manifest for module 'SQLServerUpdatesModule'
#
# Generated by: Mateusz Nadobnik
#
# Generated on: 20/6/2017
#
<#
.LINK
   Author: Mateusz Nadobnik 
   Link: mnadobnik.pl
   Date: 26.01.2018
   Version: 1.1.0.0
    
   Keywords: SQL Server, Updates, Get
   Notes: 1.0.0.4 - Get-SQLServerUpdates. Added new object (Link) with links without marks HTML.
		  1.0.0.5 - Repaired error with TLS 1.2 and added SQL Server 2017
          1.0.0.6 - issue repaired - HTML Report Has Duplicates the previous Servers available builds
          1.0.0.7 - issue repaired - Cannot index into a null array and added path validation for report
          1.0.0.8 - fixed problem with parameters in a pipeline
          1.0.0.9 - Added SQL Server 2017 to Get-SQLServerFullName function
          1.1.0.0 - Refactoring code. Added functions Invoke-SqlServerUpdatesScan and Export-SqlServerUpdatesScan
          1.1.0.1 - Added parameter - SqlCredential to Get-SqlServerVersion
          1.1.0.2 - Added SqlCredential to Invoke-SqlServerUpdatesScan
          1.1.0.3 - Support for PowerShell 6 (and PowerShell 7 preview)
          1.1.0.4 - Added properties to SqlServerUpdates.Instance object
#>

@{
	
    # Script module or binary module file associated with this manifest.
    RootModule             = 'SQLServerUpdatesModule.psm1'
	
    # Version number of this module.
    ModuleVersion = '1.1.2.4'
	
    # ID used to uniquely identify this module
    GUID                   = '9fde4b8f-637b-4a3a-ac62-5235c875dc30'
	
    # Author of this module
    Author                 = 'Nadobnik Mateusz'
	
    # Company or vendor of this module
    CompanyName            = 'mnadobnik.pl'
	
    # Copyright statement for this module
    Copyright              = 'mnadobnik.pl'
	
    # Description of the functionality provided by this module
    Description            = 'The module can parse information about updates with http://sqlserverupdates.com/. Next, it checks build number instance SQL Server in organization (mandatory parameter) and it will return updates required for installation. The script returns objects or report in html format.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion      = '4.0'
	
    # Name of the Windows PowerShell host required by this module
    PowerShellHostName     = ''
	
    # Minimum version of the Windows PowerShell host required by this module
    PowerShellHostVersion  = ''
	
    # Minimum version of the .NET Framework required by this module
    DotNetFrameworkVersion = ''
	
    # Minimum version of the common language runtime (CLR) required by this module
    CLRVersion             = ''
	
    # Processor architecture (None, X86, Amd64, IA64) required by this module
    ProcessorArchitecture  = ''
	
    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules        = @()
	
    <# Assemblies that must be loaded prior to importing this module
    In a recent version of PowerShell, Publish-Module, which publishes modules to the Gallery began requiring fully
    qualified Assembly names such as �Microsoft.SqlServer.Smo, Version=$smoversion, Culture=neutral, PublicKeyToken=89845dcd8080cc91�.
    https://blog.netnerds.net/2016/12/loading-smo-in-your-sql-server-centric-powershell-modules/
	RequiredAssemblies = @('Microsoft.SqlServer.Smo', 'Microsoft.SqlServer.SmoExtended')#>
	
    # Script files () that are run in the caller's environment prior to importing this module
    ScriptsToProcess       = @()
	
    # Type files (xml) to be loaded when importing this module
    TypesToProcess         = @()
	
    # Format files (xml) to be loaded when importing this module
    FormatsToProcess       = @()
	
    # Modules to import as nested modules of the module specified in ModuleToProcess
    NestedModules          = @()
	
    # Functions to export from this module
    FunctionsToExport      = @(
        'Get-SQLServerUpdates',
        'Show-SQLServerUpdatesReport',
        'Export-SqlServerUpdatesScan',
        'Invoke-SqlServerUpdatesScan',
        'Get-SQLServerVersion'
    )
	
    # Cmdlets to export from this module
    CmdletsToExport        = ''
	
    # Variables to export from this module
    VariablesToExport      = '*'
	
    # Aliases to export from this module
    AliasesToExport        = ''
	
    # List of all modules packaged with this module
    ModuleList             = @()
	
    # List of all files packaged with this module
    FileList               = ''
	
    PrivateData            = @{
        # PSData is module packaging and gallery metadata embedded in PrivateData
        # It's for rebuilding PowerShellGet (and PoshCode) NuGet-style packages
        # We had to do this because it's the only place we're allowed to extend the manifest
        # https://connect.microsoft.com/PowerShell/feedback/details/421837
        PSData = @{
            # The primary categorization of this module (from the TechNet Gallery tech tree).
            Category     = "Databases"

            # Keyword tags to help users find this module via navigations and search.
            Tags         = @('updates', 'update', 'sqlserver', 'sql', 'dba', 'database', 'databases', 'instance', 'reports')

            # The web address of an icon which can be used in galleries to represent this module
            IconUri      = "http://mnadobnik.pl/logo.png"

            # The web address of this module's project or support homepage.
            ProjectUri   = "http://mnadobnik.pl/SQLServerUpdatesModule/"

            # The web address of this module's license. Points to a page that's embeddable and linkable.
            LicenseUri   = ""

            # Release notes for this particular version of the module
            # ReleaseNotes = False

            # If true, the LicenseUrl points to an end-user license (not just a source license) which requires the user agreement before use.
            # RequireLicenseAcceptance = ""

            # Indicates this is a pre-release/testing version of the module.
            IsPrerelease = 'True'
        } 
    }
}











