$foldersToSearch = @(
    # "C:\Users\",
    # "C:\Program Files\",
    # "C:\Program Files (x86)\",
    # "C:\ProgramData\"
    ".\test"
    )

$fileExtensions = @{
    # extension = "how to run a command in a new process"
    ".cmd" = "start COMMAND"
    ".bat" = "start COMMAND"
    ".ps1" = "Start-Process COMMAND"
}

$LastAccessTimeThreshold = (Get-Date).AddDays(-7)  
$LastModifyTimeThreshold = (Get-Date).AddMonths(-3)
$PersistCommand = "notepad"


function DodderHunt {

    $Results = @()

    foreach ($Folder in $foldersToSearch) {
        if (Test-Path $Folder) {  
            $Files = Get-ChildItem -Path $Folder -Recurse -File -ErrorAction SilentlyContinue |
                     Where-Object { $fileExtensions.Keys -contains $_.Extension } |
                     Where-Object {($_.LastAccessTime -gt $LastAccessTimeThreshold) -and ($_.LastWriteTime -lt $LastModifyTimeThreshold)}

            foreach ($File in $Files) {
                $Results += [PSCustomObject]@{
                    FilePath     = $File.FullName
                    LastModified = $File.LastWriteTime
                    LastAccessed = $File.LastAccessTime
                }
            }
        }
    }
    return $Results
}

function DodderInfect {
}