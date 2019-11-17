function Set-PsProfile {
    <#
.SYNOPSIS
 Create Powershell user profile
.DESCRIPTION
 Create new Powershell user profile and add modules to import
 when Powershell starts
.EXAMPLE
Set-PsProfile
notepad $profile
.NOTES
Mark C
https://github.com/i-ScriptALot/PS-Powershell
 #>
    if (-not (Test-Path $Profile)) {
        New-Item $Profile -ItemType File -Force
        $Content =
        @'
 Import-Module 'Path:\Module_1.psm1'
 Import-Module 'Path:\Module_2.psm1'
'@
        $Content | Add-Content -Path $Profile

        if (Test-Path $Profile) {
            'Powershell profile created'
        }
        else {
            'Error creating Powershell profile'
        }
    }
    else {
        'Powershell profile found. Command not executed'
    }
} # End Ps profile function

