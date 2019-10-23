function Start-QuerySession {
    <#
.SYNOPSIS
 Query Session / Qwinsta
.DESCRIPTION
 Display information about user sessions on a Terminal server
  or a Remote Desktop Session Host (RD Session Host) server.
.PARAMETER ComputerName
 Item properties
.PARAMETER Param2
Switch Force
.EXAMPLE
C:\PS>Start-QuerySession -ComputerName "10.254.164.10"
Query the users with a remote connection to S00018279
.Example
C:\PS>Start-QuerySession -ComputerName "10.578.264.121"
Query the users with a remote connection to machine with this IP
.Notes
 Name:  Start-QuerySession
 Author:Mark Curry
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
        [string[]]$ComputerName,

        [Parameter(Position = 1)]
        [switch]$Param2
    )

    BEGIN {
        Write-Debug -Message "Begin FunctionName, Param1 Count $($ComputerName.count)"
        Write-Debug -Message "Param2 is $($Param2 -eq $true)"
        $Hostname = ([Net.Dns]::GetHostByAddress($ComputerName)).HostName
    }

    PROCESS {
        $QResultRaw = Qwinsta /server:$($Hostname) 
        $Item = $QResultRaw |
            select-string 'session|rdp|console' |
            foreach {
                $ra = $_ -split '\s+|device' -match '^\w'
                if ($ra.count -lt 5) {
                    $Ra += 'null'
                    $ra[3] = $ra[2]
                    $ra[2] = $ra[1]
                    $ra[1] = 'Unknown'      
                } 
                $Ra
            } 
        $ItemCnt = ($Item.count / 5) - 1
        $i = 0
        $n = 5 
        While ($i -lt $ItemCnt) {
            $QObj = New-Object -TypeName psobject
            $QObj | Add-Member -MemberType NoteProperty $Item[0] $Item[$n]
            $n++
            $QObj | Add-Member -MemberType NoteProperty $Item[1] $Item[$n]
            $n++
            $QObj | Add-Member -MemberType NoteProperty $Item[2] $Item[$n]
            $n++
            $QObj | Add-Member -MemberType NoteProperty $Item[3] $Item[$n]
            $n++
            $QObj | Add-Member -MemberType NoteProperty $Item[4] $Item[$n]
            $n++
            $QObj   
            $i++                     
        } 

    } # End process block
    END { }

} #End function

