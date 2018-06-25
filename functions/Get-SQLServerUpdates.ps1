#Requires -Version 4.0
function Get-SQLServerUpdates {
    <#
.Synopsis
    Returns available update list for SQl Server
.DESCRIPTION
    Returns available updates list  (cumulatvie update, service pack) for SQL Server. Source for updates list  - http://sqlserverupdates.com/

    Additional information.
    When I wrote this script I had a problem with Exception 0x800A01B6, 
    some tips for me were at this site: https://www.sepago.com/blog/2016/05/03/powershell-exception-0x800a01b6-while-using-getelementsbytagname-getelementsbyname.
    In the script I use IHTMLDocument3_getElementsByTagName instead of method getElementsByTagName.

    I recommend to use the script at client stations, but I encourage to make a test at servers alternatively. Please send me information about errors and problems by email mnadobnik+blog@gmail.com

.NOTES 
    Author: Mateusz Nadobnik, mnadobnik.pl
    Requires: sysadmin access on SQL Servers

    SQLServerUpdates PowerShell module (http://mnadobnik.pl/sqlserverupdates, mnadobnik@gmail.com)
    Copyright (C) 2017 Mateusz Nadobnik

.LINK
    http://mnadobnik.pl/sqlserverupdates

 .EXAMPLE
   Get-SQLServerUpdateList 

   Update list for all SQL Server from version 2008 to 2016
.EXAMPLE
   Get-SQLServerUpdateList -Version 2012

   Update list only for SQL Server 2012

.LINK
   Author: Mateusz Nadobnik 
   Link: mnadobnik.pl
   Date: 09.12.2017
   Version: 1.0.0.6
    
   Keywords: SQL Server, Updates, Get
   Notes: 1.0.0.4 - Added new object (Link) with links without marks HTML.
          1.0.0.5 - Repaired error with TLS 1.2 and added SQL Server 2017
#>
    [CmdletBinding()]
    [Alias()]
    [OutputType([string])]
    Param
    (
        #Version SQL Sever 
        [ValidateSet('SQL Server 2008', 'SQL Server 2008 R2', 'SQL Server 2012', 'SQL Server 2014', 'SQL Server 2016', 'SQL Server 2017')]$Version
    )

    Begin {
        $linkRegex = '"[^"]*"'
        $ObjReturn = @()
        try {
            #Enable TLS 1.2 
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            $content = Invoke-WebRequest -Uri http://sqlserverupdates.com/
        }
        catch {
            Write-Warning $_.Exception.Message
            Write-Host "Check connection..."
            Break
        }
        
        switch ($Version) {
            'SQL Server 2008' {$updatesbefore = $content.Links | Where-Object InnerText -like "SQL*2008?U*"}
            'SQL Server 2008 R2' {$updatesbefore = $content.Links | Where-Object InnerText -like "SQL*2008?R2*"}
            'SQL Server 2012' {$updatesafter = $content.Links | Where-Object InnerText -like "SQL*2012*"}
            'SQL Server 2014' {$updatesafter = $content.Links | Where-Object InnerText -like "SQL*2014*"}
            'SQL Server 2016' {$updatesafter = $content.Links | Where-Object InnerText -like "SQL*2016*"}
            'SQL Server 2017' {$updatesafter = $content.Links | Where-Object InnerText -like "SQL*2017*"}
            Default {
                # After SQL Server 2012
                $updatesafter = $content.Links | Where-Object InnerText -like "SQL*2[0-9][1-9][0-9]*"
                # Before SQL Server 2012
                $updatesbefore = $content.Links| Where-Object InnerText -like "SQL*2[0-9][0-9]8*"
            }
        }
    }
    Process {
        # After SQL Server 2012
        if ($updatesafter.href -ne $null) {
            foreach ($update in $updatesafter) {
                try {
                    $updateslist = Invoke-WebRequest -Uri $update.href
                }
                catch {
                    Write-Warning $_.Exception.Message
                    Break
                }

                try {
                    $updateslistTR = ($updateslist.ParsedHtml).IHTMLDocument3_getElementsByTagName("tr")
                    $updateslistTD = $updateslistTR | foreach {($_.children)}
                }
                catch {                     
                    Write-Warning $_.Exception.Message
                    Break
                }

                for ($i = 5; $i -lt $updateslistTD.Count; $i++) { 
                    $object = @{} | Select Name, ServicePack, CumulativeUpdate, ReleaseDate, Link, Build, SupportEnds
                    $object.Name = ($update.innerText).Replace(" Updates", "")
                    $object.ServicePack = (($updateslistTD[$i].innerHTML) -Replace "( &nbsp;|&nbsp;|^\s)", ""); $i++
                    $object.CumulativeUpdate = (($updateslistTD[$i].innerHTML) -Replace "( &nbsp;|&nbsp;|^\s)", ""); $i++
                    $object.ReleaseDate = (($updateslistTD[$i].innerHTML) -Replace "( &nbsp;|&nbsp;|^\s)", ""); $i++

                    try {

                        if ([regex]::Matches($object.CumulativeUpdate, $linkRegex) -ne "") {
                            $object.Link = ([regex]::Matches($object.CumulativeUpdate, $linkRegex)[0].Value).Replace('"', '')
                        }
                        elseif ([regex]::Matches($object.ServicePack, $linkRegex) -ne "") {
                            $object.Link = ([regex]::Matches($object.ServicePack, $linkRegex)[0].Value).Replace('"', '')
                        }
                    }
                    catch {
                        $object.Link = $null
                    }

                    $object.Build = (($updateslistTD[$i].innerHTML) -Replace "( &nbsp;|&nbsp;|^\s)", ""); $i++
                    $object.SupportEnds = (($updateslistTD[$i].innerHTML) -Replace "( &nbsp;|&nbsp;|^\s)", "")
                    $ObjReturn += $object

                    #$linkRegex = '"[^"]*"'
                    #([regex]::Matches($ObjReturn[5].CumulativeUpdate,$linkRegex)[0].Value).Replace('"','')
                }
            }
        }
        # Before SQL Server 2012
        if ($updatesbefore.href -ne $null) {
            foreach ($update in $updatesbefore) {
                try {
                    $updateslist = Invoke-WebRequest -Uri $update.href
                }
                catch {
                    Write-Warining $_.Exception.Message
                    Break
                }

                try {
                    $updateslistTR = ($updateslist.ParsedHtml).IHTMLDocument3_getElementsByTagName("tr")
                    $updateslistTD = $updateslistTR | foreach {($_.children)}
                }
                catch {                     
                    Write-Warning $_.Exception.Message
                    Break
                }

                for ($i = 4; $i -lt $updateslistTD.Count; $i++) { 
                    $object = @{} | Select Name, ServicePack, CumulativeUpdate, Link, ReleaseDate, Build, SupportEnds
                    $object.Name = ($update.innerText).Replace(" Updates", "")
                    $object.ServicePack = (($updateslistTD[$i].innerHTML) -Replace "( &nbsp;|&nbsp;|^\s)", ""); $i++
                    $object.CumulativeUpdate = $null;

                    try {

                        $linkRegex = '"[^"]*"'
                        if ([regex]::Matches($object.CumulativeUpdate, $linkRegex) -ne "") {
                            $object.Link = ([regex]::Matches($object.CumulativeUpdate, $linkRegex)[0].Value).Replace('"', '')
                        }
                        elseif ([regex]::Matches($object.ServicePack, $linkRegex) -ne "") {
                            $object.Link = ([regex]::Matches($object.ServicePack, $linkRegex)[0].Value).Replace('"', '')
                        }
                    }
                    catch {
                        $object.Link = $null
                    }

                    $object.ReleaseDate = (($updateslistTD[$i].innerHTML) -Replace "( &nbsp;|&nbsp;|^\s)", ""); $i++
                    $object.Build = (($updateslistTD[$i].innerHTML) -Replace "( &nbsp;|&nbsp;|^\s)", ""); $i++
                    $object.SupportEnds = (($updateslistTD[$i].innerHTML) -Replace "( &nbsp;|&nbsp;|^\s)", "")
                    $ObjReturn += $object
                }
            }  
        }
    }
    End {
        # Return Updates
        return $ObjReturn
    }
}