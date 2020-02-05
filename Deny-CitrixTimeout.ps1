function Deny-CitrixTimeout {
    # Change timer by setting it as a parameter
    # Deny-CitrixTimeout -TimerInSeconds 600
    # Will set key stroke every 10 minutes 
    param(
        [int]$TimerInSeconds = 480
    )
 
    # Function simulate     

    [System.Object[]]$processes = Get-Process | Where-Object { $_.ProcessName -match "wfica32" }
    if ($processes.count -ge 1) { $process = $processes[0] }

    if ($process -is [System.Diagnostics.Process]) {
        $processes | Format-List -property *

        for (; ; ) {
            [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")

            [Microsoft.VisualBasic.Interaction]::AppActivate($process.Id)
            Start-Sleep -seconds 1

            [void] [System.Reflection.Assembly]::LoadWithPartialName("'System.Windows.Forms")
            [System.Windows.Forms.SendKeys]::SendWait("{SCROLLLOCK}")
            Start-Sleep -Milliseconds 350
            [System.Windows.Forms.SendKeys]::SendWait("{SCROLLLOCK}")
            Start-Sleep -seconds $TimerInSeconds
        }
    }
}