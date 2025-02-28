$foldersToSearch = @(
    # "C:\Users\",
    # "C:\Program Files\",
    # "C:\Program Files (x86)\",
    # "C:\ProgramData\"
    ".\test"
    )

$fileExtensions = @(
    ".cmd", 
    ".bat", 
    ".ps1"
    )

$LastAccessTimeThreshold = (Get-Date).AddDays(-7)  # Accessed within the last 7 days
$LastModifyTimeThreshold = (Get-Date).AddMonths(-1) # Modified more than a month ago

function Search-Files {
    param (
        [string[]]$Folders,
        [string[]]$Extensions 
    )

    $Results = @()

    foreach ($Folder in $Folders) {
        if (Test-Path $Folder) {  
            $Files = Get-ChildItem -Path $Folder -Recurse -File -ErrorAction SilentlyContinue |
                     Where-Object { $Extensions -contains $_.Extension }

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

function Filter-FilesByTime {
    param (
        [array]$Files,
        [datetime]$LastAccessTimeThreshold,
        [datetime]$LastModifyTimeThreshold 
    )

    return $Files | Where-Object {
        ($_.LastAccessed -gt $LastAccessTimeThreshold) -and
        ($_.LastModified -lt $LastModifyTimeThreshold)
    }
}

$AllScripts = Search-Files -Folders $foldersToSearch -Extensions $fileExtensions

$FilteredScripts = Filter-FilesByTime -Files $AllScripts -LastAccessTimeThreshold $LastAccessTimeThreshold -LastModifyTimeThreshold $LastModifyTimeThreshold

$FilteredScripts | Format-Table -AutoSize
