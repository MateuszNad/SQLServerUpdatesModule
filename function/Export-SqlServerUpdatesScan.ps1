function Export-SqlServerUpdatesScan {
    <#
.Synopsis
   Prepares the report HTML based on data from Invoke-SqlServerUpdatesScan function.

.DESCRIPTION
    The function in pipeline gets object SqlServerUpdates.Instance from Invoke-SqlServerUpdatesScan 
    and prepares the report about updates for Sql Server instance.

.NOTES 
    Author: Mateusz Nadobnik, [mnadobnik.pl]
    Requires: sysadmin access on SQL Servers

    SQLServerUpdates PowerShell module (http://mnadobnik.pl/sqlserverupdates, mnadobnik@gmail.com)
    Copyright (C) 2017 Mateusz Nadobnik

    .LINK
    http://mnadobnik.pl/sqlserverupdates

.EXAMPLE
    Invoke-SqlServerUpdatesScan -BuildNumber '14.0.3048.4' | Export-SqlServerUpdatesScan -File C:\report-build.html

 .EXAMPLE
    Invoke-SqlServerUpdatesScan -ServerInstance IT-MN-M | Export-SqlServerUpdatesScan -File C:\report-instance..html

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
   Date: 15.05.2019
   Version: 1.1.0.0
    
   Keywords: SQL Server, Updates, Get, Reports, Export
   Notes: 

#>
    [CmdletBinding()]
    [Alias('Export-SqlUpdatesScan')]

    param
    (
        [Parameter(ValueFromPipeline = $true, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSTypeName('SqlServerUpdates.Instance')]$SqlServerUpdatesScan,
        [Parameter(Mandatory)]
        [ValidateScript( { [System.IO.Path]::GetExtension($_) -eq '.html' })]
        [string]$File
    )
    begin {
        $Scans = @()
    }
    process {
        $Scans += $SqlServerUpdatesScan
    }
    end {
        [string]$MessageBody = $null
        # Style CSS
        [string]$CSS = "<style>$(Get-Content -Path $CssPath)</style>"
        $MessageBody += $CSS
        $PostContent = "Author <a href='http://mnadobnik.pl/SQLServerUpdatesModule' target='_blank'>SQLServerUpdatesModule</a> - Mateusz Nadobnik</br>
                        Information about updates getting with site <a href='https://sqlserverupdates.com' target='_blank'>https://sqlserverupdates.com</a>"

        #Header for report
        if ($Scans.Name) {
            $HeaderReport = ($Scans.Name).ToUpper() -join ', '
        }
        elseif ($Scans.Build) {
            $HeaderReport = $Scans.Build
        }

        #Prepare HTML
        Write-Verbose "Preparation of an HTML report"
        $MessageBody += "$(Get-Date -Format 'dd-MM-yyyy HH:mm:ss')<h1>Updates Report - ($HeaderReport)</h1></br></br>"
        $MessageBody += (((($Scans | Select-Object ToUpdate, @{L = "Name"; E = { ($_.Name).ToUpper() } }, Product, VersionName, Edition, ProductLevel, `
                        @{L = "Current Build"; E = { $_.Build } }, `
                        @{L = "Available Build"; E = { (($_.Updates).Build) -join " </br> " } }, `
                        @{L = "Cumulative Update"; E = { (($_.Updates).CumulativeUpdate) -join " </br> " } }, `
                        @{L = "Release Date"; E = { (($_.Updates).ReleaseDate) -join " </br> " } }, `
                        @{L = "Support Ends"; E = { "<b>$((($_.Updates).SupportEnds)-join " </br> ")</b>" } }, `
                        @{L = "ServicePack "; E = { (($_.Updates).ServicePack) -join "</br> " } } |
                        ConvertTo-Html -Title "Updates Report" -PostContent $PostContent).Replace("&lt;", "<")).Replace("&gt;", ">")).Replace("&quot;", """")).replace("<tr><td>True", "<tr><td class='toupdate'>True") 
        try {
            Write-Verbose "Create file: $File"
            $MessageBody | Out-File $File
        }
        catch {
            Write-Warning $_.Exception.Message
        }
    }

}

