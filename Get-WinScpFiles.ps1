function Get-WinScpFiles {
    <#
.SYNOPSIS
Compress and download remote Linux files from Windows

.DESCRIPTION
Compress and download remote Linux or Unix files from a Windows box via WinSCP 

.PARAMETER HostName
Ip address or url

.PARAMETER RemotePath
Remote Linux or Unix path

.PARAMETER Destination
Download destination directory 

.PARAMETER User
User

.PARAMETER PW
Password needed if PPK auth fails 

.PARAMETER PpkPath
Path to PPK Key (.ppk) file

.PARAMETER HostKeyFngrprnt
Host Key Finger Print 

.PARAMETER DllPath
Path to WinScp.dll

.PARAMETER LogPath
Log Path (optional)

.EXAMPLE
An example

.NOTES
i-Script-Alot 2019
#>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
            Position = 0, ValueFromPipeline = $true)]
        # HostName #'s
        [String[]]
        $HostName,

        [Parameter(Mandatory = $true)]
        # Remote Path / Accepts wild cards 
        [String]
        $RemotePath,

        [Parameter()]
        # Destination Directory
        [String]
        $Destination = "$Home\Downloads",

        [Parameter(Mandatory = $true)]
        # User Account
        [String]
        $User,

        [Parameter(Mandatory = $true)]
        # Password is needed .ppk auth fails
        [String]
        $PW,

        [Parameter(Mandatory = $true)]
        # path to SshPrivateKeyPath
        [String]
        $PpkPath,

        [Parameter(Mandatory = $true)]
        # path to SshPrivateKeyPath
        [String]
        $HostKeyFngrprnt,

        [Parameter(Mandatory = $true)]
        # path to WinScp.dll
        [String]
        $DllPath,
        
        [Parameter()]
        # Session Log Path
        [String]
        $LogPath

    )
    begin {
        $ErrorActionPreference = 'stop'
        If (-not (Test-Path $DllPath)) {
            Write-Error -Exception "WinScp.dll could not be located at $DllPath" -ErrorAction Stop
        }

        function FileTransferProgress {
            param($e)
            # New line for every new file
            if (($script:lastFileName -ne $Null) -and
                ($script:lastFileName -ne $e.FileName)) { Write-Host }
            # Print transfer progress
            Write-Host -NoNewline ("`r{0} ({1:P0})" -f $e.FileName, $e.FileProgress)
            # Remember a name of the last file reported
            $script:lastFileName = $e.FileName
        }

        $RemoteDir = $RemotePath -replace '(.+\/).+', '$1'
        $TgzPath = "$($RemoteDir)logcap/*.tgz"
    }
    process {
        Foreach ($Address in $HostName) {
            try {
               
                if (!(Test-Path -Path $Destination -ea 0)) {
                    New-Item -Path $Destination -ItemType Directory            
                }
                $null = Test-Connection -ComputerName $Address -Count 1 -Erroraction stop
                # Build Compress Command  
                $Cmd1 = "cd $RemoteDir;mkdir -p ./logcap;rm -f ./logcap/*.tgz;"                            
                $Cmd2 = "tar -czf ./logcap/$($Address)_$(Get-date -f 'MM-dd').tgz "
                $Cmd3 = "$RemotePath 2> /dev/null"   
                $Command = $Cmd1, $Cmd2, $Cmd3 -Join ''
                Write-Verbose -Message "HostName:$($Address)-Preparing to execute the following command:"
                Write-Verbose -Message $Command

                Add-Type -Path $DllPath  

                # Set up session options
                $SessionOptions = New-Object WinSCP.SessionOptions -Property @{
                    Protocol              = [WinSCP.Protocol]::Scp
                    HostName              = $Address
                    UserName              = $User
                    Password              = $PW
                    SshHostKeyFingerprint = $HostKeyFngrprnt
                    SshPrivateKeyPath     = $KeyPath
                }

                $Session = New-Object WinSCP.Session
                Write-Verbose -Message "HostName:$($Address)-Created WinScp session object"

                Write-Verbose -Message "HostName:$($Address)-Recording session to $LogPath"
                $Session.SessionLogPath = $LogPath

                # Continuously report progress of transfer
                $session.add_FileTransferProgress( { FileTransferProgress($_) } )

                # Connect
                $Session.Open($SessionOptions)

                # Compress files
                Write-Verbose -Message "HostName:$($Address)-Connected , Executing log compression"
                $Session.ExecuteCommand($Command).Check()

                # Transfer files
                Write-Verbose -Message "HostName:$($Address)-Requesting files"
                $Session.GetFiles($TgzPath , "$LocalDir\*", $True).Check()

                $FinalTgz = Get-ChildItem  -path $LocalDir  -filter *.tgz  -erroraction stop |
                    where { $_.lastwritetime -gt (get-date).addminutes(-10) } |
                    select -ExpandProperty fullname -ErrorAction stop
                $CmdError = 'N'
            }
            catch {
                $FinalTgz = "HostName:$($Address)-Error: $($Error[0].Message -replace '.+(:\s.+)','$1')"
                $CmdError = 'Y'
            }
            finally {
                # Terminate line after the last file (if any)
                if ($script:lastFileName -ne $Null) {
                    Write-Host
                }
                $Session.Dispose()
                $TgzCopyProperty = [ordered]@{
                    HostName = $Address
                    Result   = $FinalTgz
                    Error    = $CmdError
                }
                New-object PSObject -Property $TgzCopyProperty
            }
        } # End Foreach Loop
    } # End Process
    end { }
} # End Get-WinScpFiles fnc
