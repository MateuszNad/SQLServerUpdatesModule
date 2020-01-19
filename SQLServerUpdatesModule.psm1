Set-StrictMode -Version Latest

# Import the appropriate nested binary module
$PSModuleRoot = $PSScriptRoot # $PSModule.ModuleBase
$CachedData  = Join-Path -Path (Join-Path -Path $PSModuleRoot -ChildPath 'cache') -ChildPath 'sql.server.updates.xml'

$binaryModuleRoot = Join-Path -Path $PSModuleRoot -ChildPath 'net45'
if (($PSVersionTable.Keys -contains "PSEdition") -and ($PSVersionTable.PSEdition -ne 'Desktop')) {
    $binaryModuleRoot = Join-Path -Path $PSModuleRoot -ChildPath 'netstandard2.0'
}

# Load Angle Sharp
Get-ChildItem -Path (Join-Path -Path $binaryModuleRoot -ChildPath 'anglesharp') -Filter *.dll | ForEach-Object {
    [System.Reflection.Assembly]::LoadFile($_.FullName)
}

# Add types to load SMO Assemblies only:
Get-ChildItem -Path (Join-Path -Path $binaryModuleRoot -ChildPath 'smo') -Filter *.dll | ForEach-Object {
    if (($PSVersionTable.Keys -contains "PSEdition") -and ($PSVersionTable.PSEdition -ne 'Desktop')) {
        Add-Type -Path $_.FullName -ErrorAction SilentlyContinue
    }
    else {
        [System.Reflection.Assembly]::LoadFile($_.FullName)
    }
}
# Load function
Get-ChildItem -Path (Join-Path $PSModuleRoot -ChildPath 'function') | ForEach-Object {
    . $_.FullName
}

# CSS file
$script:CSSPath = Join-Path (Join-Path -Path $PSModuleRoot -ChildPath 'css') -ChildPath 'style.css'
