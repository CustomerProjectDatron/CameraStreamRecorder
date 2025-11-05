@echo off
setlocal EnableDelayedExpansion

:: Den vollständigen Pfad des Skripts speichern, um es später auszuschließen.
set "THIS_SCRIPT=%~f0"

:: Eingabe des Projektnamens
set /p project_name=Enter your project name: 

echo.
echo Renaming files and directories...

:: Alle Dateien und Ordner, deren Namen den Platzhalter enthalten,
:: werden (von den tiefsten Pfaden aus) umbenannt.
:: Dabei werden Objekte in einem .git-Verzeichnis sowie das Skript selbst ausgeschlossen.
for /f "delims=" %%i in ('
    powershell -NoProfile -Command ^
      "Get-ChildItem -Recurse -Force -LiteralPath . | Where-Object { $_.Name -like '*{{PROJECT_NAME}}*' -and $_.FullName -notmatch '\\\.git\\' -and $_.FullName -ne $env:THIS_SCRIPT } | Sort-Object { $_.FullName.Split([io.path]::DirectorySeparatorChar).Count } -Descending | ForEach-Object { $_.FullName }"
') do (
    set "oldPath=%%i"
    :: Den neuen Pfad ermitteln, indem der Platzhalter ersetzt wird.
    for /f "delims=" %%j in ('
        powershell -NoProfile -Command "Write-Output ((\"!oldPath!\" -replace '{{PROJECT_NAME}}','%project_name%'))"
    ') do (
        set "newPath=%%j"
    )
    if /i not "!oldPath!"=="!newPath!" (
        echo Renaming "!oldPath!" to "!newPath!"
        move "!oldPath!" "!newPath!" >nul
    )
)

echo.
echo Replacing text inside files...

:: Alle Dateien rekursiv durchlaufen, dabei .git-Dateien und das Skript selbst überspringen
for /R %%f in (*) do (
    set "skip=0"
    rem Prüfen, ob der Dateipfad ".git" enthält:
    echo "%%f" | findstr /i /c:".git" >nul && set "skip=1"
    rem Prüfen, ob es sich um das Skript selbst handelt:
    if /I "%%~ff"=="%THIS_SCRIPT%" set "skip=1"
    if "!skip!"=="0" (
        powershell -NoProfile -Command ^
          "(Get-Content -Raw -LiteralPath '%%f') -replace '{{PROJECT_NAME}}','%project_name%' | Set-Content -LiteralPath '%%f'"
    )
)

echo.
echo Template has been customized for project: %project_name%
pause
endlocal
