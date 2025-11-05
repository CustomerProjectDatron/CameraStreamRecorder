# Überprüfen, ob das Skript mit Administratorrechten läuft
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Das Skript wird als Administrator neu gestartet..." -ForegroundColor Yellow
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

function Create-SymbolicLink {
    param (
        [string]$relativeTargetPath, # Relativer Pfad zum Zielordner
        [string]$absoluteLinkPath     # Absoluter Pfad zum symbolischen Link
    )

    # Pfad des aktuellen Skripts
    $scriptDir = $PSScriptRoot
   
    # Wenn der relative Pfad leer oder "." ist, das aktuelle Skriptverzeichnis verwenden
    if ([string]::IsNullOrWhiteSpace($relativeTargetPath) -or $relativeTargetPath -eq ".") {
        $targetPath = $scriptDir
    }
    else {
        $targetPath = Join-Path $scriptDir $relativeTargetPath
    }

    # Sicherstellen, dass der übergeordnete Ordner des symbolischen Links existiert; falls nicht, wird er angelegt
    $parentDir = Split-Path -Path $absoluteLinkPath
    if (-not (Test-Path -LiteralPath $parentDir)) {
        New-Item -ItemType Directory -Force -Path $parentDir | Out-Null
        Write-Host "Ordner '$parentDir' wurde erstellt."
    }

    # Überprüfen, ob ein symbolischer Link oder Ordner bereits existiert
    if (Test-Path $absoluteLinkPath) {
        if ((Get-Item $absoluteLinkPath).LinkType -eq 'SymbolicLink') {
            Write-Host "Symbolischer Link '$absoluteLinkPath' existiert bereits. Er wird entfernt und durch einen neuen ersetzt."
            Remove-Item -LiteralPath $absoluteLinkPath -Force
        }
        elseif (Test-Path $absoluteLinkPath -PathType Container) {
            # Falls ein Ordner mit demselben Namen existiert, diesen umbenennen
            $dateString = Get-Date -Format "yyyy-MM-dd"
            $newFolderName = "$absoluteLinkPath-$dateString"
            Rename-Item -Path $absoluteLinkPath -NewName $newFolderName
            Write-Host "Ordner wurde in '$newFolderName' umbenannt."
        }
    }
    
    # Erstellen des symbolischen Links
    New-Item -ItemType SymbolicLink -Path $absoluteLinkPath -Target $targetPath
    Write-Host "Symbolischer Link '$absoluteLinkPath' wurde erstellt und zeigt auf '$targetPath'."
}

# Mehrere symbolische Links erstellen – so werden nur die Ordner erstellt, die notwendig sind,
# und es wird das Aktivieren mehrerer Projekte ermöglicht.
Create-SymbolicLink -relativeTargetPath "Library\NextStreamRecorder" -absoluteLinkPath "C:\Data\Programs\Library\NextStreamRecorder"
Create-SymbolicLink -relativeTargetPath "Samples\NextStreamRecorder" -absoluteLinkPath "C:\Data\Programs\Samples\NextStreamRecorder"
Create-SymbolicLink -relativeTargetPath "Tests\NextStreamRecorder" -absoluteLinkPath "C:\Data\Programs\Tests\NextStreamRecorder"

# Warten auf eine Benutzereingabe, bevor das Fenster geschlossen wird
Read-Host -Prompt "Drücken Sie Enter, um das Fenster zu schließen..."


