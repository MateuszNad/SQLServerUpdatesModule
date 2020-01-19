# Pester test
Describe Get-SQLServerUpdate {
    It "Count of version Sql Server" {
        (Get-SQLServerUpdate | Group-Object -Property Name).Count | Should Be 6
    }
}

# https://adamtheautomator.com/pester-mock/