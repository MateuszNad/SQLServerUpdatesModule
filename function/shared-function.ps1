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
   Version: 1.0.0.9
    
   Keywords: Shared function, Version, SQL Server
   Notes: 1.0.0.4 - Without change.
          1.0.0.6 - Repaired syntax
          1.0.0.9 - Added SQL Server 2017 to Get-SQLServerFullName function
          1.1.0.1 - Added parameter - SqlCredential
#>

Function Get-SQLServerFullName($param) {
    switch ($param) {
        9 { return "SQL Server 2005" }
        10 { return "SQL Server 2008" }
        10.50 { return "SQL Server 2008 R2" }
        11 { return "SQL Server 2012" }
        12 { return "SQL Server 2014" }
        13 { return "SQL Server 2016" }
        14 { return "SQL Server 2017" }
    }
}

function Get-SQLServerVersion {
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$ServerInstance,
        [Parameter()]
        [PSCredential]$SqlCredential
    )

    Begin { 
    
    }
    Process {
        try { 
            $connectsqlserver = New-Object Microsoft.SqlServer.Management.Smo.Server $ServerInstance
            $connectsqlserver.ConnectionContext.ApplicationName = "SqlServerUpdatesModule"
            $connectsqlserver.ConnectionContext.ConnectTimeout = 10

            Write-Verbose "Connect to server $ServerInstance"
            if ($connectsqlserver.ConnectionContext.IsOpen -eq $false) {

                if ($null -ne $SqlCredential) {
                    $username = ($SqlCredential.UserName).TrimStart("\")

                    # support both ad\username and username@ad
                    if ($username -like "*\*" -or $username -like "*@*") {
                        if ($username -like "*\*") {
                            $domain, $login = $username.Split("\")
                            if ($domain) {
                                $formatteduser = "$login@$domain"
                            }
                            else {
                                $formatteduser = $username.Split("\")[1]
                            }
                        }
                        else {
                            $formatteduser = $SqlCredential.UserName
                        }

                        $connectsqlserver.ConnectionContext.LoginSecure = $true
                        $connectsqlserver.ConnectionContext.ConnectAsUser = $true
                        $connectsqlserver.ConnectionContext.ConnectAsUserName = $formatteduser
                        $connectsqlserver.ConnectionContext.ConnectAsUserPassword = ($SqlCredential).GetNetworkCredential().Password
                    }
                    else {
                        $connectsqlserver.ConnectionContext.LoginSecure = $false
                        $connectsqlserver.ConnectionContext.set_Login($username)
                        $connectsqlserver.ConnectionContext.set_SecurePassword($SqlCredential.Password)
                    }
                }
                else {
                    $connectsqlserver.ConnectionContext.LoginSecure = $true
                }
                Write-Verbose "[Get-SqlServerVersion] ConnectionString:$($connectsqlserver.ConnectionContext)"
                $connectsqlserver.ConnectionContext.Connect()
            }

            $connectsqlserver | Select-Object Name, Product, Edition, ProductLevel, VersionMajor, 
            @{L = "VersionName"; E = { Get-SQLServerFullName $_.versionmajor } }, @{L = "Build"; E = { $_.VersionString } } 

        }
        catch {
            Write-Debug -Message $_.Exception
            Write-Output $_.Exception.Message -ForegroundColor Yellow  
        }
    }
    End {        
        Write-Verbose "The disconnect connection with $ServerInstance"
        try {
            if ($connectsqlserver.ConnectionContext.IsOpen -eq $true) {
                $connectsqlserver.ConnectionContext.Disconnect()
            }
        }
        catch {
            Write-Output $_.Exception.Message -ForegroundColor Yellow         
        }
    }
}