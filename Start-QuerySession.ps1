function Start-QuerySession {
    <#
.SYNOPSIS
 Query Session / Qwinsta
.DESCRIPTION
 Display information about user sessions on a Terminal server
  or a Remote Desktop Session Host (RD Session Host) server.
.PARAMETER ComputerName
 Host Name or an IP
.EXAMPLE
C:\PS>Start-QuerySession -ComputerName 'NSMCURRY-N1'
Query the users with a current connection to NSMCURRY-N1
.EXAMPLE
C:\PS>Start-QuerySession -ComputerName '10.24.254.10'
Query the users with a current connection to '10.24.254.10'
.Notes
 Name:  Start-QuerySession
 Author: Mark Curry
 Keywords: RDP, Users, Exceeded
 .Link
 https://github.com/i-ScriptALot
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
        Write-Debug -Message "Begin QuerySession, Computer Count $($ComputerName.count)"
        if ($ComputerName -match '\.') {
            $Hostname = ([Net.Dns]::GetHostByAddress($ComputerName)).HostName
        }
        else {
            $Hostname = $ComputerName
        }
    } # End Begin

    PROCESS {
        $QResultRaw = Qwinsta /server:$($Hostname) 
        $Item = $QResultRaw |
            select-string 'session|rdp|console' |
            foreach {
                $QueryIndex = $_ -split '\s+|device' -match '^\w'
                if ($QueryIndex.count -lt 5) {
                    $QueryIndex += 'null'
                    $QueryIndex[3] = $QueryIndex[2]
                    $QueryIndex[2] = $QueryIndex[1]
                    $QueryIndex[1] = 'Unknown'      
                } 
                $QueryIndex
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

