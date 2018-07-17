<#
.Synopsis
   Connect to SQL Server
.DESCRIPTION
   Function can connect to SQL server with authetication Windows
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.LINK
   Author: Mateusz Nadobnik 
   Link: mnadobnik.pl
   Date: 16.07.2017
   Version: 1.0.0.6
    
   Keywords: Shared function, Version, SQL Server
   Notes: 1.0.0.4 - Without change.
          1.0.0.6 - Repaired syntax
#>

Function Get-SQLServerFullName($param) {
    switch ($param) {
        9 { return "SQL Server 2005"}
        10 { return "SQL Server 2008"}
        10.50 { return "SQL Server 2008 R2"}
        11 { return "SQL Server 2012"}
        12 { return "SQL Server 2014"}
        13 { return "SQL Server 2016"}
    }
}

function Get-SQLServerVersion {
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]$ServerInstance
    )

    Begin
    { }

    Process {
        try { 
            $connectsqlserver = New-Object Microsoft.SqlServer.Management.Smo.Server $ServerInstance
            $connectsqlserver.ConnectionContext.ApplicationName = "DBA PowerShell App"
            $connectsqlserver.ConnectionContext.ConnectTimeout = 1

            Write-Verbose "Connect to server $ServerInstance"
            if ($connectsqlserver.ConnectionContext.IsOpen -eq $false) {

                $connectsqlserver.ConnectionContext.Connect()
            }
        }
        catch {
            Write-Host $_.Exception.Message -ForegroundColor Yellow               
        }
        finally { 
            $connectsqlserver | Select-Object Name, Product, Edition, ProductLevel, VersionMajor, @{L = "VersionName"; E = {Get-SQLServerFullName $_.versionmajor}}, @{L = "Build"; E = {$_.VersionString}} 
        }
    }
    End {        
        Write-Verbose "Disconnect all connection"
        try {
            if ($connectsqlserver.ConnectionContext.IsOpen -eq $true) {
                $connectsqlserver.ConnectionContext.Disconnect()
            }
            else {
                
            }
        }
        catch {
            Write-Host $_.Exception.Message -ForegroundColor Yellow         
        }
    }
}

