#Requires -Version 4.0
# https://github.com/AngleSharp/AngleSharp
# https://github.com/AngleSharp/AngleSharp/blob/master/doc/Basics.md

function Get-SqlServerUpdate
{
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
   Version: 1.0.1.1

   Keywords: SQL Server, Updates, Get
   Notes: 1.0.0.4 - Added new object (Link) with links without marks HTML.
          1.0.0.5 - Repaired error with TLS 1.2 and added SQL Server 2017
          1.0.0.7 - Repaired error Cannot index into a null array.
          1.0.1.0 - Repaired error with SQL Server 2017 and refactoring of code.
          1.0.1.1 - Repaired error with SQL Server 2008 R2
          1.0.1.2 - Bad property outerHTML instead of innerText in the function Get-SQLServerUpdates
          1.1.0.2 - Added SqlCredential
          1.1.5.4 - Added cache file with list of updates

#>
    [CmdletBinding()]
    [Alias('Get-SqlServerUpdates')]
    [OutputType([string])]
    Param
    (
        #Version SQL Sever
        [ValidateSet('SQL Server 2008',
            'SQL Server 2008 R2',
            'SQL Server 2012',
            'SQL Server 2014',
            'SQL Server 2016',
            'SQL Server 2017',
            'SQL Server 2019')]
        [string]$Version,
        [switch]$Force,
        [switch]$Offline
    )

    $ElapsedTime = [System.Diagnostics.Stopwatch]::StartNew()

    $linkRegex = '"[^"]*"'
    $ObjReturn = @()
    $parser = New-Object AngleSharp.Html.Parser.HtmlParser
    $WebsiteAddress = 'http://sqlserverupdates.com/'

    if ((-not (Test-Connection -ComputerName 8.8.8.8 -Count 1 -Quiet)) -and (Test-Path $CachedData))
    {
        $ReturnCachedData = $true
    }
    elseif ((Get-Item $CachedData -ErrorAction SilentlyContinue | Where-Object LastWriteTime -ge (Get-Date).AddHours(-4)) -and (-not $Force.IsPresent))
    {
        $ReturnCachedData = $true
    }
    elseif ($Force.IsPresent)
    {
        $ReturnCachedData = $false
    }
    elseif ($Offline.IsPresent)
    {
        $ReturnCachedData = $true
    }
    else
    {
        $ReturnCachedData = $false
    }

    if ($ReturnCachedData)
    {
        Write-Verbose "Reading list of updates with cache file..."
        $result = Import-Clixml -Path $CachedData
        if ($Version)
        {
            return ($result | Where-Object Name -eq $Version)
        }
        else
        {
            return $result
        }
    }
    else
    {
        try
        {
            # enable TLS 1.2
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            $html = Invoke-WebRequest -Uri $WebsiteAddress
            $content = $parser.ParseDocument($html);
            Write-Verbose ("{0};Invoke-WebRequest" -f $ElapsedTime.Elapsed)
        }
        catch
        {
            Write-Output "Check connection..."
            if (Test-Path -Path $CachedData)
            {
                Write-Output "The module will working on cached data"
            }
            Write-Warning $_.Exception.Message
            Break
        }
    }

    # setting for count of column in table on website
    $ColumnSetting = [ordered]@{
        'SQL Server 2008'    = 4
        'SQL Server 2008 R2' = 4
        'SQL Server 2012'    = 5
        'SQL Server 2014'    = 5
        'SQL Server 2016'    = 5
        'SQL Server 2017'    = 4
        'SQL Server 2019'    = 3
    }

    $VersionSQL = [ordered]@{
        'SQL Server 2008'    = ($content.Links | Where-Object Href -Match "sql-server-2008-updates*")[0]
        'SQL Server 2008 R2' = ($content.Links | Where-Object Href -Match "sql-server-2008-r2-updates")[0]
        'SQL Server 2012'    = ($content.Links | Where-Object Href -Match "sql-server-2012-updates")[0]
        'SQL Server 2014'    = ($content.Links | Where-Object Href -Match "sql-server-2014-updates")[0]
        'SQL Server 2016'    = ($content.Links | Where-Object Href -Match "sql-server-2016-updates")[0]
        'SQL Server 2017'    = ($content.Links | Where-Object Href -Match "sql-server-2017-updates")[0]
        'SQL Server 2019'    = ($content.Links | Where-Object Href -Match "sql-server-2019-updates")[0]
    }
    Write-Verbose ("{0};Links" -f $ElapsedTime.Elapsed)

    # if set parameter -Version
    if ($Version)
    {
        $VersionSQL = [ordered]@{
            $Version = $VersionSQL.$Version
        }
    }

    foreach ($SQL in $VersionSQL.Keys)
    {
        # $SQL = 'SQL Server 2008'
        try
        {
            $webHtml = Invoke-WebRequest -Uri $VersionSQL.$SQL.href
            $ListUpdates = $parser.ParseDocument($webHtml);
        }
        catch
        {
            Write-Warning $_.Exception.Message
            Break
        }

        try
        {
            $tableUpdateTR = ($ListUpdates).GetElementsByTagName("tr")
            $tableUpdateTD = $tableUpdateTR | ForEach-Object { ($_.children) }
        }
        catch
        {
            Write-Warning $_.Exception.Message
            Break
        }

        for ($i = $ColumnSetting.$SQL; $i -lt $tableUpdateTD.Count; $i++)
        {
            # new object
            #$update = @{ } | Select-Object
            $update = [PSCustomObject]@{
                Name             = ''
                ServicePack      = ''
                CumulativeUpdate = ''
                ReleaseDate      = ''
                Link             = ''
                Build            = ''
                SupportEnds      = ''
            }

            $update.Name = ($VersionSQL.$SQL.Text).Replace(" Updates", "")

            if ($ColumnSetting.$SQL -eq 5)
            {
                $update.ServicePack = (($tableUpdateTD[$i].innerHTML) -Replace "( &nbsp;|&nbsp;|^\s)", ""); $i++
                $update.CumulativeUpdate = (($tableUpdateTD[$i].innerHTML) -Replace "( &nbsp;|&nbsp;|^\s)", ""); $i++

                $ReleaseDate = (($tableUpdateTD[$i].innerHTML) -Replace "( &nbsp;|&nbsp;|^\s|\?\?)", "").Trim(); $i++
                if ([datetime]::TryParse($ReleaseDate, [ref](Get-Date)))
                {
                    $update.ReleaseDate = [datetime]$ReleaseDate
                }
                else
                {
                    $update.ReleaseDate = [datetime]'0001/01/01'
                }

                $update.Build = (($tableUpdateTD[$i].innerHTML) -Replace "( &nbsp;|&nbsp;|^\s)", ""); $i++
                $update.SupportEnds = (($tableUpdateTD[$i].innerHTML) -Replace "( &nbsp;|&nbsp;|^\s|\?\?)", "").Trim()
            }
            elseif ($ColumnSetting.$SQL -eq 4)
            {
                $update.ServicePack = ''
                $update.CumulativeUpdate = (($tableUpdateTD[$i].innerHTML) -Replace "( &nbsp;|&nbsp;|^\s)", ""); $i++

                $ReleaseDate = (($tableUpdateTD[$i].innerHTML) -Replace "( &nbsp;|&nbsp;|^\s|\?\?)", "").Trim(); $i++
                if ([datetime]::TryParse($ReleaseDate, [ref](Get-Date)))
                {
                    $update.ReleaseDate = [datetime]$ReleaseDate
                }
                else
                {
                    $update.ReleaseDate = [datetime]'0001/01/01'
                }

                $update.Build = (($tableUpdateTD[$i].innerHTML) -Replace "( &nbsp;|&nbsp;|^\s)", ""); $i++
                $update.SupportEnds = (($tableUpdateTD[$i].innerHTML) -Replace "( &nbsp;|&nbsp;|^\s|\?\?)", "").Trim()
            }
            elseif ($ColumnSetting.$SQL -eq 3)
            {
                $update.ServicePack = ''
                $update.CumulativeUpdate = (($tableUpdateTD[$i].innerHTML) -Replace "( &nbsp;|&nbsp;|^\s)", ""); $i++

                $ReleaseDate = (($tableUpdateTD[$i].innerHTML) -Replace "( &nbsp;|&nbsp;|^\s|\?\?)", "").Trim(); $i++
                if ([datetime]::TryParse($ReleaseDate, [ref](Get-Date)))
                {
                    $update.ReleaseDate = [datetime]$ReleaseDate
                }
                else
                {
                    $update.ReleaseDate = [datetime]'0001/01/01'
                }

                $update.Build = (($tableUpdateTD[$i].innerHTML) -Replace "( &nbsp;|&nbsp;|^\s)", "")
                $update.SupportEnds = ''
            }

            try
            {

                if ([regex]::Matches($update.CumulativeUpdate, $linkRegex) -ne "")
                {
                    $update.Link = ([regex]::Matches($update.CumulativeUpdate, $linkRegex)[0].Value).Replace('"', '')
                }
                elseif ([regex]::Matches($object.ServicePack, $linkRegex) -ne "")
                {
                    $update.Link = ([regex]::Matches($update.ServicePack, $linkRegex)[0].Value).Replace('"', '')
                }
            }
            catch
            {
                $update.Link = $null
            }

            $ObjReturn += $update
        }
    }

    Write-Output $ObjReturn
    if ((Get-Item $CachedData -ErrorAction SilentlyContinue | Where-Object LastWriteTime -le (Get-Date).AddHours(-4)) -or (-not (Test-Path $CachedData)) -and (-not $Version))
    {
        $ObjReturn | Export-Clixml -Path $CachedData
    }

    $ElapsedTime.Stop()
}