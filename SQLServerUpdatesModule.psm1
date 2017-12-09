# All supporting functions have been moved to Functions\SharedFunctions.ps1
# If you're looking through the code, you pretty much have to work with two files
# at any one time. The function you're working on, and SharedFunctions.ps1
foreach ($function in (Get-ChildItem "$PSScriptRoot\functions\*.ps1")) { . $function }

# Not supporting the provider path at this time
# if (((Resolve-Path .\).Path).StartsWith("SQLSERVER:\")) { throw "Please change to another drive and reload the module." }

# I renamed this function to be more accurate

#Set-Alias -Name Name-Function -Value Name-Alias

# Strictmode coming when I've got time.
# Set-StrictMode -Version Latest

<# In order to keep backwards compatability, these are loaded here instead of in the manifest.
In a recent version of PowerShell, Publish-Module, which publishes modules to the Gallery began requiring fully
qualified Assembly names such as “Microsoft.SqlServer.Smo, Version=$smoversion, Culture=neutral, PublicKeyToken=89845dcd8080cc91”.
https://blog.netnerds.net/2016/12/loading-smo-in-your-sql-server-centric-powershell-modules/

$assemblylist =  
"Microsoft.SqlServer.Management.Common",  
"Microsoft.SqlServer.Smo",  
"Microsoft.SqlServer.Dmf ",  
"Microsoft.SqlServer.Instapi ",  
"Microsoft.SqlServer.SqlWmiManagement ",  
"Microsoft.SqlServer.ConnectionInfo ",  
"Microsoft.SqlServer.SmoExtended ",  
"Microsoft.SqlServer.SqlTDiagM ",  
"Microsoft.SqlServer.SString ",  
"Microsoft.SqlServer.Management.RegisteredServers ",  
"Microsoft.SqlServer.Management.Sdk.Sfc ",  
"Microsoft.SqlServer.SqlEnum ",  
"Microsoft.SqlServer.RegSvrEnum ",  
"Microsoft.SqlServer.WmiEnum ",  
"Microsoft.SqlServer.ServiceBrokerEnum ",  
"Microsoft.SqlServer.ConnectionInfoExtended ",  
"Microsoft.SqlServer.Management.Collector ",  
"Microsoft.SqlServer.Management.CollectorEnum",  
"Microsoft.SqlServer.Management.Dac",  
"Microsoft.SqlServer.Management.DacEnum",  
"Microsoft.SqlServer.Management.Utility"  
  
foreach ($assembly in $assemblylist)  
{  
    $null = [Reflection.Assembly]::LoadWithPartialName($assembly)  
}  
#>


#https://blog.netnerds.net/2016/12/loading-smo-in-your-sql-server-centric-powershell-modules/
$smoversions = "14.0.0.0", "13.0.0.0", "12.0.0.0", "11.0.0.0", "10.0.0.0", "9.0.242.0", "9.0.0.0"
 
foreach ($smoversion in $smoversions)
{
    try
    {
        Add-Type -AssemblyName "Microsoft.SqlServer.Smo, Version=$smoversion, Culture=neutral, PublicKeyToken=89845dcd8080cc91" -ErrorAction Stop
        $smoadded = $true
    }
    catch
    {
        $smoadded = $false
    }
    
    if ($smoadded -eq $true) { break }
}
 
if ($smoadded -eq $false) { throw "Can't load SMO assemblies. You must have SQL Server Management Studio installed to proceed." }
 
$assemblies = "Management.Common", "Dmf", "Instapi", "SqlWmiManagement", "ConnectionInfo", "SmoExtended", "SqlTDiagM", "Management.Utility",
"SString", "Management.RegisteredServers", "Management.Sdk.Sfc", "SqlEnum", "RegSvrEnum", "WmiEnum", "ServiceBrokerEnum", "Management.XEvent",
"ConnectionInfoExtended", "Management.Collector", "Management.CollectorEnum", "Management.Dac", "Management.DacEnum", "Management.IntegrationServices"
 
foreach ($assembly in $assemblies)
{
    try
    {
        Add-Type -AssemblyName "Microsoft.SqlServer.$assembly, Version=$smoversion, Culture=neutral, PublicKeyToken=89845dcd8080cc91" -ErrorAction Stop
    }
    catch
    {
        # Don't care
    }
}