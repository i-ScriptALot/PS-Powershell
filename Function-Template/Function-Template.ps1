function Get-FunctionName {
    <#
.SYNOPSIS
 Function information
.DESCRIPTION
 Explination of function
.PARAMETER Param1
 Item properties
.PARAMETER Param2
Switch Force
.EXAMPLE
C:\PS>Get-FunctionName -param1 "Param1 Value"
Explination of example 1
.Example
C:\PS>"Param1 Value", "Param1 Value2", |  Get-FunctionName -param2
Explination of pipeline example 2
.Notes
 Name: Get-FunctionName
 Author:
 Keywords:
.Link
 https://github.com/i-ScriptALot
.Inputs
Object
.Outputs
Object
#Requires -Version 2.0
#>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $True, HelpMessage = 'Parameter Required',
            ValueFromPipeline = $True, Position = 0)]
        [string[]]$Param1,

        [Parameter(Position = 1)]
        [switch]$Param2
    )

    BEGIN {
        Write-Debug -Message "Begin FunctionName, Param1 Count $($Param1.count)"
        Write-Debug -Message "Param2 is $($Param2 -eq $true)"
    }

    PROCESS {
        foreach ($Value in $Param1 ) {
            Write-Debug "Processing $Value"
            if ($Param2) {
                $Value | Get-Item
            }
            else {
                $Value | Get-Item -Force
            }
        } # End foreach
    } # End process block

    END { }

} #End function

