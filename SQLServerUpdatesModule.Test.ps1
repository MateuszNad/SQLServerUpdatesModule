$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$module = 'SQLServerUpdatesModule'

Describe "$module Module Tests" -Tag 'module' {

    Context "Module Directory" {
        
        $directories = ('private', 'public', 'bin', 'tests', 'en-US')

        ForEach ($directory in $directories) {
            It "has the directory $directory" {
                Join-Path -Path $here -ChildPath $directory | Should Exist
            }
        }
    }

    Context "Module files" {
        $files = "$Module.psd1", "$Module.psm1", "$Module.Format.ps1xml", "about_$Module.help.txt", "$Module.Test.ps1", "$Module.build.ps1"
        foreach ($file in $files) {
            It "has the file $file" {
                Join-Path -Path $here -ChildPath $file | Should Exist
            }
        }
    }

    Context 'Module Setup' {
        It "has the root module $module.psm1" {
            "$here\$module.psm1" | Should Exist
        }

        It "has the a manifest file of $module.psm1" {
            "$here\$module.psd1" | Should Exist
            "$here\$module.psd1" | Should FileContentMatch "$module.psm1"
        }

        It "public folder has some functions" {
            $functions = Get-ChildItem (Join-Path -Path $here -ChildPath 'public') 
            $functions.Count | Should Not Be 0
        }

        It "$module is valid PowerShell code" {
            $psFile = Get-Content -Path "$here\$module.psm1" `
                -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
            $errors.Count | Should Be 0
        }
    }
}
Describe "Function in module" -Tag 'function' {

    $functions = Get-ChildItem (Join-Path -Path $here -ChildPath 'public') 

    foreach ($function in $functions) {
        $functionName = $function.Name

        Context "Test Function $functionName" {
      
            It "$functionName.ps1 should exist" {
                $function.FullName | Should Exist
            }
    
            It "$functionName.ps1 should have help block" {
                $function.FullName | Should FileContentMatch '<#'
                $function.FullName | Should FileContentMatch '#>'
            }

            It "$functionName.ps1 should have a SYNOPSIS section in the help block" {
                $function.FullName | Should FileContentMatch '.SYNOPSIS'
            }
    
            It "$functionName.ps1 should have a DESCRIPTION section in the help block" {
                $function.FullName | Should FileContentMatch '.DESCRIPTION'
            }

            It "$functionName.ps1 should have a EXAMPLE section in the help block" {
                $function.FullName | Should FileContentMatch '.EXAMPLE'
            }
    
            It "$functionName.ps1 should be an advanced function" {
                $function.FullName | Should FileContentMatch 'function'
                $function.FullName | Should FileContentMatch 'cmdletbinding'
                $function.FullName | Should FileContentMatch 'param'
            }
      
            It "$functionName.ps1 should contain Write-Verbose blocks" {
                $function.FullName | Should FileContentMatch 'Write-Verbose'
            }
    
            It "$functionName.ps1 is valid PowerShell code" {
                $psFile = Get-Content -Path $function.FullName  `
                    -ErrorAction Stop
                $errors = $null
                $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
                $errors.Count | Should Be 0
            }

    
        } # Context "Test Function $function"

    } # foreach ($function in $functions)

}


