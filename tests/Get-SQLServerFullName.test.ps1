Describe "Get-SQLServerFullName" {
    It "Check version " {
        Get-SQLServerFullName 11 | Should Be "SQL Server 2012"
    }
}