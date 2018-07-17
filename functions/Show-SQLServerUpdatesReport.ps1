#Requires -Version 4.0
function Show-SQLServerUpdatesReport {
    <#
.Synopsis
   Returns information about deficit of installed updates at instance SQL Server.

.DESCRIPTION
    This command download information about the newest available updates for instance SQL Server. 
    Next, it checks build number instance SQL Server in organization (mandatory parameter) and it will return updates required for installation.

    Show-SQLServerUpdatesReport can return report in HTML format.
    
    This function use Get-SQLServerUpdates for download information about availability updates for all edition SQL Server. 
    Function Get-SQ ServerUpdates is a part of the module SQLServerUpdateModule. More about its function in help. 

.NOTES 
    Author: Mateusz Nadobnik, mnadobnik.pl
    Requires: sysadmin access on SQL Servers

    SQLServerUpdates PowerShell module (http://mnadobnik.pl/sqlserverupdates, mnadobnik@gmail.com)
    Copyright (C) 2017 Mateusz Nadobnik

    .LINK
    http://mnadobnik.pl/sqlserverupdates

.EXAMPLE
    Show-SQLServerUpdates -Version '13.0.4422.0'

    Name         :
    Product      :
    VersionName  : SQL Server 2014
    Edition      :
    ProductLevel :
    Version      : 12.0.4487.0
    Updates      : {@{CumulativeUpdate=<a href="https://support.microsoft.com/en-us/help/4013098/cumulative-update-5-for-sq
                   l-server-2014-sp2">CU5</a>; ReleaseDate=2017/04/17; Build=12.0.5546; SupportEnds=2024/07/09; ServicePack
                   =}, @{CumulativeUpdate=<a href="https://support.microsoft.com/en-us/help/4010394/cumulative-update-4-for
                   -sql-server-2014-sp2">CU4</a>; ReleaseDate=2017/02/21; Build=12.0.5540; SupportEnds=2024/07/09; ServiceP
                   ack=}, @{CumulativeUpdate=<a href="https://support.microsoft.com/en-us/kb/3204388">CU3</a>; ReleaseDate=
                   2016/12/27; Build=12.0.5538; SupportEnds=2024/07/09; ServicePack=}, @{CumulativeUpdate=<a href="https://
                   support.microsoft.com/en-us/kb/3188778">CU2</a>; ReleaseDate=2016/10/18; Build=12.0.5522; SupportEnds=20
                   24/07/09; ServicePack=}...}
    ToUpdate     : True

    Returns information about deficit of installed updates for version builid SQL Server.

 .EXAMPLE
    Show-SQLServerUpdates -Version '12.0.4502' | Select -Expand Updates

    CumulativeUpdate : <a href="https://support.microsoft.com/en-us/help/4013098/cumulative-update-5-for-sql-server-2014-sp
                       2">CU5</a>
    ReleaseDate      : 2017/04/17
    Build            : 12.0.5546
    SupportEnds      : 2024/07/09
    ServicePack      :

    CumulativeUpdate : <a href="https://support.microsoft.com/en-us/help/4010394/cumulative-update-4-for-sql-server-2014-sp
                       2">CU4</a>
    ReleaseDate      : 2017/02/21
    Build            : 12.0.5540
    SupportEnds      : 2024/07/09
    ServicePack      :
    ...

   Returns information about deficit of installed updates for build number SQL Server. Expand properties Updates.

.EXAMPLE
    Show-SQLServerUpdatesReport -ServerInstance it-mn-m\mssqlserver14, test-agsqlserver

    Name         : it-mn-m\mssqlserver14
    Product      : Microsoft SQL Server
    VersionName  : SQL Server 2014
    Edition      : Developer Edition (64-bit)
    ProductLevel : SP1
    Build        : 12.0.4487.0
    Updates      : {@{CumulativeUpdate=<a href="https://support.microsoft.com/en-us/help/4013098/cumulative-update-5-for-sq
                   l-server-2014-sp2">CU5</a>; ReleaseDate=2017/04/17; Build=12.0.5546; SupportEnds=2024/07/09; ServicePack
                   =}, @{CumulativeUpdate=<a href="https://support.microsoft.com/en-us/help/4010394/cumulative-update-4-for
                   -sql-server-2014-sp2">CU4</a>; ReleaseDate=2017/02/21; Build=12.0.5540; SupportEnds=2024/07/09; ServiceP
                   ack=}, @{CumulativeUpdate=<a href="https://support.microsoft.com/en-us/kb/3204388">CU3</a>; ReleaseDate=
                   2016/12/27; Build=12.0.5538; SupportEnds=2024/07/09; ServicePack=}, @{CumulativeUpdate=<a href="https://
                   support.microsoft.com/en-us/kb/3188778">CU2</a>; ReleaseDate=2016/10/18; Build=12.0.5522; SupportEnds=20
                   24/07/09; ServicePack=}...}
    ToUpdate     : True

    Returns information about deficit of installed updates for instance with parameter ServerInstance. This command returns objects.

.EXAMPLE
    Show-SQLServerUpdatesReport -ServerInstance it-mn-m\mssqlserver14, test-agsqlserver -HTML -Path C:\temp\report.html

    Return information about deficit of installed updates for instances with parameter ServerInstance. This command returns report in the format html.

.LINK
   Author: Mateusz Nadobnik 
   Link: mnadobnik.pl
   Date: 16.07.2017
   Version: 1.0.0.6
    
   Keywords: SQL Server, Updates, Get, Reports, Show
   Notes: 1.0.0.4 - Without change.
          1.0.0.6 - issue repaired - HTML Report Has Duplicates the previous Servers available builds
                    Repaired syntax and change changed name variables "$object" to $ObjAllSserversWithUpdates

#>

    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        #The SQL Server instance
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true,
                   Position = 0,
                   ParameterSetName = 'Instance')]
                   $ServerInstance,
        #Build number SQL Server, example 13.0.4422.0
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true, 
                   Position = 0, 
                   ParameterSetName = 'Version')]
                    [string]$BuildNumber,
        #Return report HTML
        [switch]$HTML
    )
    DynamicParam {
        if($HTML) {
            #create a new ParameterAttribute Object
            $pathAttribute = New-Object System.Management.Automation.ParameterAttribute
            $pathAttribute.Mandatory = $true
 
            #create an attributecollection object for the attribute we just created.
            $attributeCollection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
 
            #add our custom attribute
            $attributeCollection.Add($pathAttribute)
 
            #add our paramater specifying the attribute collection
            $pathParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Path', [string], $attributeCollection)
 
            #expose the name of our parameter
            $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramDictionary.Add('Path', $pathParam)
            return $paramDictionary
        }
    }
    Begin {
        [array]$ObjAllSserversWithUpdates = @()

        if($HTML)
        {
            #Check path
            if($PSBoundParameters.Path  -notmatch '[.]html')
            {
                Write-Host "The path $($PSBoundParameters.Path) not contain file with extension html"
                break
            }

            if(-not (Test-Path (Split-Path -Path $PSBoundParameters.Path)))
            {
                Write-Host "Not correct path. The directory $(Split-Path -Path $PSBoundParameters.Path) not exist."
                break
            }
        }
        
        if ($BuildNumber) {
            $ServerInstance = @{} | Select-Object VersionMajor, Build, VersionName
            $ServerInstance.Build = $BuildNumber
            $ServerInstance.VersionName = Get-SQLServerFullName ([int]($BuildNumber.Split(".")[0]))
            #$ServerInstance.VersionName = Get-SQLServerVersion ([int]($BuildNumber.Split(".")[0]))
            $ServerInstance.VersionMajor = [int]($BuildNumber.Split(".")[0])

            try {
                Write-Verbose "Get update list for $($ServerInstance.VersionName)" 
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
            $ObjServer = @()
            $ObjUpdates = @()

            if (-not $BuildNumber) {   
                $Instance = Get-SQLServerVersion -ServerInstance $SqlInstance
            }
            else {
                $Instance = $SqlInstance
            }

            if ([int]($Instance.VersionMajor) -le 8) {
                Write-Warning "Problem with connect or checked you server with SQL Server 2005 and earlier version"
            }

            $ObjServer = @{} | Select-Object Name, Product, VersionName, Edition, ProductLevel, Build, Updates, ToUpdate
            $ObjServer.Name = $Instance.Name
            $ObjServer.Product = $Instance.Product
            $ObjServer.VersionName = $Instance.VersionName
            $ObjServer.Edition = $Instance.Edition
            $ObjServer.ProductLevel = $Instance.ProductLevel
            $ObjServer.Build = $Instance.Build    

            # If check updates for SQL Server 2005
            if ($Instance.VersionMajor -eq 9) {
                $ObjUpdate = @{} | Select+Object CumulativeUpdate, ReleaseDate, Build, SupportEnds, ServicePack

                $ObjUpdate.CumulativeUpdate = ""
                $ObjUpdate.ReleaseDate = "2012/10/09"
                $ObjUpdate.Build = "9.00.5324"
                $ObjUpdate.SupportEnds = "2016/04/12 – out of support"
                $ObjUpdate.ServicePack = ""

                $ObjServer.Updates = $ObjUpdate
                $ObjServer.ToUpdate = $true
            }

            if ($Instance.VersionMajor -ge 9) {
                $UpdatesServer = $UpdateList | Where-Object Name -eq $Instance.VersionName    
                
                # if SQL Server is latest Version       
                if (([double](($Instance.Build) -Replace "\.(.|..)\.", "") -ge [double](($UpdatesServer[0].Build) -replace "\.(.|..)\.", "")) -or ($UpdatesServer[0].Build -eq "") -and ($UpdatesServer[0].Build -ne "various")) {
                    $ObjUpdate = @{} | Select-Object CumulativeUpdate, ReleaseDate, Build, SupportEnds, ServicePack
                    $ObjUpdate.CumulativeUpdate = $UpdatesServer[0].CumulativeUpdate
                    $ObjUpdate.ReleaseDate = $UpdatesServer[0].ReleaseDate
                    $ObjUpdate.Build = $UpdatesServer[0].Build
                    $ObjUpdate.SupportEnds = $UpdatesServer[0].SupportEnds
                    $ObjUpdate.ServicePack = $UpdatesServer[0].ServicePack 

                    $ObjServer.Updates = $ObjUpdate
                    if (([double](($Instance.Build) -Replace "\.(.|..)\.", "") -ge [double](($UpdatesServer[0].Build) -replace "\.(.|..)\.", ""))) {
                        $ObjServer.ToUpdate = $false
                    }
                    else {
                        $ObjServer.ToUpdate = $true
                    }
                }
                else {
                    #Issue - HTML Report Has Duplicates the previous Servers available builds
                    foreach ($Update in $UpdatesServer) {
                        if ($Update.Build -ne "various") { 
                            if ([double](($Instance.Build) -Replace "\.(.|..)\.", "") -lt [double](($Update.Build) -replace "\.(.|..)\.", "")) {
                                $ObjUpdate = @{} | Select-Object CumulativeUpdate, ReleaseDate, Build, SupportEnds, ServicePack
                                $ObjUpdate.CumulativeUpdate = $Update.CumulativeUpdate
                                $ObjUpdate.ReleaseDate = $Update.ReleaseDate
                                $ObjUpdate.Build = $Update.Build
                                $ObjUpdate.SupportEnds = $Update.SupportEnds
                                $ObjUpdate.ServicePack = $Update.ServicePack 

                                # Save not installed update
                                $ObjUpdates += $ObjUpdate
                            }
                        }
                    }

                    $ObjServer.Updates = $ObjUpdates
                    $ObjServer.ToUpdate = $true
                }
                # Add to array
                $ObjAllSserversWithUpdates += $ObjServer
            }
        }
    }
    End {
        [string]$MessageBody = $null
        # Style CSS
        [string]$StyleCSS = "<style> 
                            body 
                            {
                                font-family:Calibri;
                                font-size:12pt;
                                background: #fafafa;
                                color: #5a5a5a;
                            } 
                            h1
                            {
                                font-size: 38px;
                                line-height: 48px;
                                font-weight: 100;
                            }
                            td.toupdate 
                            {
                                color:#e10707;
                                font-weight: 700;
                            }
                            tr:nth-child(odd) td, tr:nth-child(odd) th 
                            {
                                background-color: #f8f8f8;
                            }
                            td 
                            {
                                padding: 8px;
                                line-height: 18px;
                                text-align: center;
                                vertical-align: top;
                                border-top: 1px solid #dddddd;
                            }
                            table td 
                            {
                                padding: 8px;
                                line-height: 18px;
                                text-align: center;
                                vertical-align: top;
                                border-top: 1px solid #dddddd;
                            }

                            table 
                            {
                                border-bottom: 5px solid rgba(225,7,7,.5);
                                border-collapse: collapse;
                                border-spacing: 0;
                                font-size: 14px;
                                line-height: 2;
                                margin: 0 0 20px;
                                width: 100%;
                            }
                            a 
                            {
                                color: #e10707;
                                text-decoration:none;
                            }
                            a:hover
                            {
                                 text-decoration:underline;
                                 color:#FF0000;
                            }
                            body 
                            {
                                font-family:Calibri;
                                font-size:12pt;
                                background: #fafafa;
                                color: #5a5a5a;
                            } 
                            h1
                            {
                                font-size: 38px;
                                line-height: 48px;
                                font-weight: 100;
                            }
                            td.toupdate 
                            {
                                color:#e10707;
                                font-weight: 700;
                            }
                            tr:nth-child(odd) td, tr:nth-child(odd) th 
                            {
                                background-color: #f8f8f8;
                            }
                            td 
                            {
                                padding: 8px;
                                line-height: 18px;
                                text-align: center;
                                vertical-align: top;
                                border-top: 1px solid #dddddd;
                            }
                            table td 
                            {
                                padding: 8px;
                                line-height: 18px;
                                text-align: center;
                                vertical-align: top;
                                border-top: 1px solid #dddddd;
                            }

                            table 
                            {
                                border-bottom: 5px solid rgba(225,7,7,.5);
                                border-collapse: collapse;
                                border-spacing: 0;
                                font-size: 14px;
                                line-height: 2;
                                margin: 0 0 20px;
                                width: 100%;
                            }
                            a 
                            {
                                color: #e10707;
                                text-decoration:none;
                            }
                            a:hover
                            {
                                    text-decoration:underline;
                                    color:#FF0000;
                            }
                                                        </style>"
        $MessageBody += $StyleCSS

        $PostContent = "Author <a href='http://mnadobnik.pl/SQLServerUpdatesModule' target='_blank'>SQLServerUpdatesModule</a> - Mateusz Nadobnik</br>
                        Information about updates getting with site <a href='https://sqlserverupdates.com' target='_blank'>https://sqlserverupdates.com</a>"
        #Prepare HTML
        if ($HTML) {
            $MessageBody += "<h1>Updates Report - ($($ServerInstance -join ','))</h1></br></br>"
            $MessageBody += (((($ObjAllSserversWithUpdates | Select ToUpdate, @{L = "Name"; E = {($_.Name).ToUpper()}}, Product, VersionName, Edition, ProductLevel, `
                            @{L = "Current Build"; E = {$_.Build}}, `
                            @{L = "Available Build"; E = {(($_.Updates).Build) -join " </br> "}}, `
                            @{L = "Cumulative Update"; E = {(($_.Updates).CumulativeUpdate) -join " </br> "}}, `
                            @{L = "Release Date"; E = {(($_.Updates).ReleaseDate) -join " </br> "}}, `
                            @{L = "Support Ends"; E = {"<b>$((($_.Updates).SupportEnds)-join " </br> ")</b>"}}, `
                            @{L = "ServicePack "; E = {(($_.Updates).ServicePack) -join "</br> "}} |
                                ConvertTo-Html -Title "Updates Report" -PostContent $PostContent).Replace("&lt;", "<")).Replace("&gt;", ">")).Replace("&quot;", """")).replace("<tr><td>True", "<tr><td class='toupdate'>True") 
            try {
                $MessageBody | Out-File $PSBoundParameters.Path
            }
            catch {
                Write-Warning $_.Exception.Message
            }
        }
        else {
            return $ObjAllSserversWithUpdates
        }
    }
}

