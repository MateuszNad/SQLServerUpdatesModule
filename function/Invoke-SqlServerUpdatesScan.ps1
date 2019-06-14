#Requires -Version 4.0
function Invoke-SqlServerUpdatesScan {
    <#
.Synopsis
   Returns information about deficit of installed updates at instance SQL Server.

.DESCRIPTION
    This command download information about the newest available updates for instance SQL Server. 
    Next, it checks build number instance SQL Server in organization (mandatory parameter) and it will return updates required for installation.

    Show-SQLServerUpdatesReport can return report in HTML format.
    
    This function use Get-SQLServerUpdates for download information about availability updates for all edition SQL Server. 
    Function Invoke-SqlServerUpdatesScan is a part of the module SQLServerUpdateModule. More about its function in help. 

.NOTES 
    Author: Mateusz Nadobnik, [mnadobnik.pl]
    Requires: sysadmin access on SQL Servers

    SQLServerUpdates PowerShell module (http://mnadobnik.pl/sqlserverupdates, mnadobnik@gmail.com)
    Copyright (C) 2017 Mateusz Nadobnik

    .LINK
    http://mnadobnik.pl/sqlserverupdates

.EXAMPLE
    Invoke-SqlServerUpdatesScan -BuildNumber '14.0.3048.4'

    Name         :
    Product      :
    VersionName  : SQL Server 2017
    Edition      :
    ProductLevel :
    Build        : 14.0.3048.4
    Updates      : {14.0.3076.1, 14.0.3049.1}
    ToUpdate     : True

    Returns information about deficit of installed updates for version builid SQL Server.

 .EXAMPLE
    Invoke-SqlServerUpdatesScan -BuildNumber '14.0.3048.4' | Select-Object -ExpandProperty Updates

    CumulativeUpdate : <a href="https://support.microsoft.com/en-us/help/4484710/cumulative-update-14-for-sql-server-2017">CU14</a>
    ReleaseDate      : 2019/03/25
    Build            : 14.0.3076.1
    SupportEnds      : N/A
    ServicePack      :

    CumulativeUpdate : <a href="https://support.microsoft.com/en-us/help/4483666/on-demand-hotfix-update-package-for-sql-server-2017-cu13">Hotfix</a>
    ReleaseDate      : 2019/01/07
    Build            : 14.0.3049.1
    SupportEnds      : N/A
    ServicePack      :
    ...

   Returns information about deficit of installed updates for build number SQL Server. Expand properties Updates.

.EXAMPLE
    Invoke-SqlServerUpdatesScan -ServerInstance IT-MN-M

    Name         : IT-MN-M
    Product      : Microsoft SQL Server
    VersionName  : SQL Server 2017
    Edition      : Developer Edition (64-bit)
    ProductLevel : RTM
    Build        : 14.0.1000.169
    Updates      : {14.0.3076.1, 14.0.3049.1, 14.0.3048.4, 14.0.3045.24...}
    ToUpdate     : True

    Returns information about deficit of installed updates for instance with parameter ServerInstance. This command returns objects.

.LINK
   Author: Mateusz Nadobnik 
   Link: mnadobnik.pl
   Date: 14.05.2010
   Version: 1.1.0.0
    
   Keywords: SQL Server, Updates, Get, Reports, Show
   Notes: 
#>

    [CmdletBinding()]
    [Alias('Invoke-SqlUpdatesScan')]
    [OutputType([string])]
    Param
    (
        #The SQL Server instance
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0,
            ParameterSetName = 'Instance')]
        [Alias('SqlInstance')]
        $ServerInstance,
        #Build number SQL Server, example 13.0.4422.0
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true, 
            Position = 1, 
            ParameterSetName = 'Version')]
        [string]$BuildNumber
        #Return report HTML
    )
    Begin {
        $ErrorActionPreference = 'Stop'
        $fnName = '[Invoke-SqlServerUpdatesScan]'
        if ($BuildNumber) {
            #Create new object
            #$BuildNumber = '14.0.1000.16'
            $ServerInstance = [PSCustomObject]@{ 
                Name         = ''
                Product      = ''
                Edition      = ''
                ProductLevel = ''
                VersionMajor = ([version]$BuildNumber).Major
                Build        = $BuildNumber
                VersionName  = Get-SQLServerFullName ([version]$BuildNumber).Major
            }
            try {
                Write-Verbose "$fnName Get update list for $($ServerInstance.VersionName)" 
                $UpdateList = Get-SQLServerUpdates -Version $ServerInstance.VersionName
            }
            catch {
                Write-Host $_.Exception.Message
                exit 1
            }
        }
        else {
            try {
                Write-Verbose "Get update list for all SQL Server"
                $UpdateList = Get-SQLServerUpdates
            }
            catch {
                Write-Warning $_.Exception.Message
                exit 1
            }
        }
    }

    Process {
        foreach ($SqlInstance in $ServerInstance) {
            #Clear variables
            $ServerObj = @()
            $UpdatesObj = @()

            if (-not $BuildNumber) {  
                Write-Debug "[if (-not $BuildNumber)]:true"
                Write-Verbose "Run:Get-SQLServerVersion, Parameters :-ServerInstance $SqlInstance"
                $Instance = Get-SQLServerVersion2 -ServerInstance $SqlInstance
                Write-Verbose "Result:Get-SQLServerVersion $Instance"
            }
            else {
                Write-Debug "[if (-not $BuildNumber)]:false"
                Write-Verbose "$SqlInstance"
                $Instance = $SqlInstance
            }

            if ([int]($Instance.VersionMajor) -le 8) {
                Write-Debug "[if ($($Instance.VersionMajor) -le 8)]:true" 
                Write-Warning "Problem with connect or checked you server with SQL Server 2005 and earlier version"
            } 

            #Create custome object
            $ServerObj = [PSCustomObject]@{
                PSTypeName   = 'SqlServerUpdates.Instance'
                Name         = $Instance.Name
                Product      = $Instance.Product
                VersionName  = $Instance.VersionName
                Edition      = $Instance.Edition
                ProductLevel = $Instance.ProductLevel
                Build        = $Instance.Build
                Updates      = ""
                ToUpdate     = $false
            }


            # If check updates for SQL Server 2005
            if ([int]($Instance.VersionMajor) -eq 9) {
                Write-Debug "[[int]($($Instance.VersionMajor)) -eq 9]:true" 
                $update = [PSCustomObject]@{
                    PSTypeName       = 'SqlServerUpdates.Update'
                    CumulativeUpdate = ""
                    ReleaseDate      = "2012/10/09"
                    Build            = "9.00.5324"
                    SupportEnds      = "2016/04/12 – out of support"
                    ServicePack      = ""
                }
                Add-Member -InputObject $update -MemberType ScriptMethod  -Name ToString -Force -Value { $this.Build }

                $ServerObj.Updates = $update
                $ServerObj.ToUpdate = $true
            }

            if ([int]($Instance.VersionMajor) -ge 9) {
                Write-Debug "[[int]($($Instance.VersionMajor)) -ge 9]:true" 
                $UpdatesList = $UpdateList | Where-Object Name -eq $Instance.VersionName
                
                # if SQL Server is latest Version       
                if (([version]$Instance.Build -ge [version]$UpdatesList[0].Build) -or ($UpdatesList[0].Build -eq "") -and ($UpdatesList[0].Build -ne "various")) {
                    $update = [pscustomobject]@{
                        PSTypeName       = 'SqlServerUpdates.Update'
                        CumulativeUpdate = $UpdatesServer[0].CumulativeUpdate
                        ReleaseDate      = $UpdatesServer[0].ReleaseDate
                        Build            = $UpdatesServer[0].Build
                        SupportEnds      = $UpdatesServer[0].SupportEnds
                        ServicePack      = $UpdatesServer[0].ServicePack
                    }
                    Add-Member -InputObject $update -MemberType ScriptMethod  -Name ToString -Force -Value { $this.Build }

                    $ServerObj.Updates = $update

                    if ([version]$Instance.Build -ge [version]$UpdatesList[0].Build) {
                        Write-Verbose "Setting property: ToUpdate = false"
                        $ServerObj.ToUpdate = $false
                    }
                    else {
                        Write-Verbose "Setting property: ToUpdate = true"
                        $ServerObj.ToUpdate = $true
                    }
                }
                else {
                    foreach ($Update in $UpdatesList) {
                        $outParse = $null
                        if ([Version]::TryParse($Update.Build, [ref]$outParse)) {
                            if ($Update.Build -ne "various") {
                                Write-Debug "[if ($($Update.Build) -ne 'various')]:true"
                                if ([version]$Instance.Build -lt [version]$Update.Build) {
                                    $update = [PSCustomObject]@{
                                        CumulativeUpdate = $Update.CumulativeUpdate
                                        ReleaseDate      = $Update.ReleaseDate
                                        Build            = $Update.Build
                                        SupportEnds      = $Update.SupportEnds
                                        ServicePack      = $Update.ServicePack 
                                    }
                                    Add-Member -InputObject $update -MemberType ScriptMethod  -Name ToString -Force -Value { $this.Build }

                                    $UpdatesObj += $update
                                }
                            }
                        }
                    }
                    $ServerObj.Updates = $UpdatesObj
                    $ServerObj.ToUpdate = $true
                }
                $ServerObj
                #$ObjAllSserversWithUpdates += $ObjServer
            }
        }
    }
    End { }
}

