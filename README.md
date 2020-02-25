# SqlServerUpdatesModule
The module downloads information about the newest available updates for SQL Server instances.

The module SqlServerUpdatesModule now works on PowerShell 6 (and PowerShell 7-preview).

- 1.1.5.5 - Added support for Sql Server 2019

## Installing
To install the released version via PowerShell Gallery:

```
PS C:\> Install-Module -Name SqlServerUpdatesModule
```

## Usage

Update list for all SQL Server from version 2008 to 2019.
```
Get-SQLServerUpdateList
```
