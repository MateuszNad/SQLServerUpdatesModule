#ask . InstallDependencies, Analyze, Test, UpdateVersion #, Clean, Archive

task . UpdateVersion, Publish


task InstallDependencies {
    Install-Module Pester -Force
    Install-Module PSScriptAnalyzer -Force
}

task Analyze {
    $scriptAnalyzerParams = @{
        Path        = "$BuildRoot\function"
        Severity    = @('Error', 'Warning')
        Recurse     = $true
        Verbose     = $false
        ExcludeRule = 'PSUseDeclaredVarsMoreThanAssignments'
    }

    $saResults = Invoke-ScriptAnalyzer @scriptAnalyzerParams

    if ($saResults) {
        $saResults | Format-Table
        throw "One or more PSScriptAnalyzer errors/warnings where found."
    }
}

task Test {
    $invokePesterParams = @{
        Strict     = $true
        PassThru   = $true
        Verbose    = $false
        EnableExit = $false
    }

    # Publish Test Results as NUnitXml
    $testResults = Invoke-Pester ".\$((($BuildFile -split '\\')[-1] -split '\.')[0] + '.Test.ps1')" @invokePesterParams;

    $numberFails = $testResults.FailedCount
    assert($numberFails -eq 0) ('Failed "{0}" unit tests.' -f $numberFails)
}

task UpdateVersion {
    try {
        $moduleManifestFile = ((($BuildFile -split '\\')[-1] -split '\.')[0] + '.psd1')
        $manifestContent = Get-Content $moduleManifestFile -Raw
        [version]$version = [regex]::matches($manifestContent, "ModuleVersion\s*=\s*\'(?<version>(\d+\.)?(\d+\.)?(\d+\.)?(\*|\d+))'") | ForEach-Object { $_.groups['version'].value }
        $newVersion = "{0}.{1}.{2}.{3}" -f $version.Major, $version.Minor, ($version.Build + 1), $version.Revision

        $replacements = "ModuleVersion = '$newVersion'"            
        $manifestContent = $manifestContent -replace "ModuleVersion\s*=\s*\'(?<version>(\d+\.)?(\d+\.)?(\d+\.)?(\*|\d+))'", $replacements

        $manifestContent | Set-Content -Path "$BuildRoot\$moduleManifestFile"
    }
    catch {
        Write-Error -Message $_.Exception.Message
        $host.SetShouldExit($LastExitCode)
    }
}

task Clean {
    $Artifacts = "$BuildRoot\Artifacts"
    
    if (Test-Path -Path $Artifacts) {
        Remove-Item "$Artifacts/*" -Recurse -Force
    }

    New-Item -ItemType Directory -Path $Artifacts -Force
}

task Publish {
    Publish-Module -Path $BuildRoot -NuGetApiKey $env:NuGetApiKey -Verbose
}

task LocalPublish {

}

<#
task Archive {
    $Artifacts = "$BuildRoot\Artifacts"
    $ModuleName = ($buildroot -split '\\')[-1]
    Compress-Archive  -LiteralPath .\TeamCityAgentDSC.psd1 -DestinationPath "$Artifacts\$ModuleName.zip"
    Compress-Archive -Path .\DSCClassResources -Update -DestinationPath "$Artifacts\$ModuleName.zip"
    Compress-Archive -Path .\Examples -Update -DestinationPath "$Artifacts\$ModuleName.zip"
}#>


task Reimport {
    $ModuleName = Split-Path -Path $BuildRoot -Leaf
    if (Get-Module -Name $ModuleName) {
        Remove-Module $ModuleName
    }
    Import-Module $BuildRoot
}