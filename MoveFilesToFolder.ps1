param (
    [Parameter(Mandatory=$true, Position=0)]
    [string]$FolderPath
)

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$LogFilePath = "C:\Users\Public\MoveFilesToFolder.txt"

# Function to get the appropriate folder based on the file extension
function GetDestinationFolder($extension, $isFolder) {
    switch -Regex ($extension.ToLower()) {
        "\.jpg|\.png|\.jpeg|\.gif|\.bmp|\.tiff" { return "Imagens" }
        "\.pdf|\.docx?|\.txt|\.md|\.rtf|\.csv|\.xls[x]?|\.ppt[x]?|\.od[tsp]" { return "Documentos" }
        "\.exe|\.msi|\.bat|\.cmd|\.ps1|\.psm1|\.vbs|\.sh|\.bash|\.app|\.elf|\.jar|\.deb" { return "Executáveis" }
        "\.zip|\.rar|\.7z|\.gz|\.tar|\.iso|\.dmg|\.pkg" { return "Compactados" }
        "\.mp3|\.wav|\.ogg|\.flac|\.aac" { return "Áudio" }
        "\.mp4|\.mov|\.avi|\.mkv|\.wmv|\.flv|\.webm" { return "Vídeos" }
        "\.psd|\.ai|\.indd|\.svg|\.eps" { return "Gráficos" }
        default { return "Outros" } 
    }
}

# Function to sort files in the given folder
function Sort-Files($folderPath) {
    "Processing folder: $folderPath" | Out-File $LogFilePath -Append -Force

    $files = Get-ChildItem -LiteralPath $folderPath

    foreach ($file in $files) {
        if ($file -is [System.IO.FileInfo]) {
            $extension = $file.Extension
            $isFolder = $false
            "Processing file: $($file.Name) -> $extension" | Out-File $LogFilePath -Append -Force
        } elseif ($file -is [System.IO.DirectoryInfo]) {
            $extension = ""
            $isFolder = $true
        }

        $destinationFolder = GetDestinationFolder $extension $isFolder
        $destinationPath = Join-Path -Path $folderPath -ChildPath $destinationFolder

        if (-Not (Test-Path $destinationPath -PathType Container)) {
            "Creating destination folder: $destinationPath" | Out-File $LogFilePath -Append -Force
            New-Item -ItemType Directory -Verbose -Force -Path $destinationPath
        }


        if ($isFolder) {
        } else {
            "Moving file: $($file.Name) -> $destinationPath" | Out-File $LogFilePath -Append -Force
            Move-Item -Path $file.FullName -Verbose -Destination $destinationPath
        }
        
    }
}

# Create a FileSystemWatcher object to monitor the target folder
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $FolderPath
$watcher.IncludeSubdirectories = $false
$watcher.EnableRaisingEvents = $true
# Monitor file creation and move events
$watcher.NotifyFilter = [System.IO.NotifyFilters]::FileName -bor `
                        [System.IO.NotifyFilters]::LastAccess -bor `
                        [System.IO.NotifyFilters]::LastWrite


# Register the event handlers
Register-ObjectEvent -InputObject $watcher -EventName Renamed -SourceIdentifier FileRenamed -Action {
    Write-Host "Event Type: " $Event.SourceEventArgs.ChangeType "-->" $Event.SourceEventArgs.FullPath
    Handle-FileSystemEvent $Event
}

Register-ObjectEvent -InputObject $watcher -EventName Created -SourceIdentifier FileCreated -Action {   
    Write-Host "Event Type: " $Event.SourceEventArgs.ChangeType "-->" $Event.SourceEventArgs.FullPath
    Handle-FileSystemEvent $Event
}

Register-ObjectEvent -InputObject $watcher -EventName Deleted -SourceIdentifier FileDeleted -Action {
    Write-Host "Event Type: " $Event.SourceEventArgs.ChangeType "-->" $Event.SourceEventArgs.FullPath
    Handle-FileSystemEvent $Event
}

Register-ObjectEvent -InputObject $watcher -EventName Changed -SourceIdentifier FileChanged -Action {
    Write-Host "Event Type: " $Event.SourceEventArgs.ChangeType "-->" $Event.SourceEventArgs.FullPath
    Handle-FileSystemEvent $Event
}

# Function to handle FileSystemWatcher events
function Handle-FileSystemEvent($Event) {
    $changeType = $Event.SourceEventArgs.ChangeType
    $path = $Event.SourceEventArgs.FullPath

    Write-Host "File change detected: $changeType -> $path"

    Sort-Files $FolderPath
}

# Keep the script running in the background
try {
    while ($true) {
        # Wait for 5 seconds before checking for new events and processing jobs
        Start-Sleep -Seconds 5

        # Check if there are any completed jobs and remove them from the job list
        $completedJobs = Get-Job | Where-Object { $_.State -eq 'Completed' }
        $completedJobs | ForEach-Object {
            Receive-Job $_ -AutoRemoveJob -Wait
        }
    }
}
finally {
    # Clean up resources and unregister the event handler when the script is terminated
    $watcher.EnableRaisingEvents = $false
    Unregister-Event -SourceIdentifier FileRenamed
    Unregister-Event -SourceIdentifier FileCreated
    Unregister-Event -SourceIdentifier FileDeleted
    Unregister-Event -SourceIdentifier FileChangeds
    $watcher.Dispose()

    # Remove all remaining jobs
    Get-Job | Remove-Job -Force
}
