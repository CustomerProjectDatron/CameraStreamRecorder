@echo off
setlocal enabledelayedexpansion

REM Get the current directory name for the package filename
for %%i in ("%CD%") do set "DIRNAME=%%~ni"

REM Find highest existing version number
set "HIGHEST_VERSION=0"
set "MAJOR=1"
set "MINOR=0"
set "PATCH=0"

echo Checking for existing packages...
REM Use dir with /B to list files safely, redirect output to temp file
dir /B "*_v*.nextpkg" 2>nul | find "%DIRNAME%_v" > temp_files.txt
set "FILES_FOUND=0"
for /f %%x in (temp_files.txt) do set "FILES_FOUND=1"

if "!FILES_FOUND!"=="1" (
    echo Found existing package files, scanning versions...
    for /f "tokens=*" %%f in (temp_files.txt) do (
        set "FILENAME=%%~nf"
        REM Extract version number from filename (format: ProjectName_v1.2.3)
        for /f "tokens=2 delims=v" %%v in ("!FILENAME!") do (
            set "FOUND_VERSION=%%v"
            REM Parse version components
            for /f "tokens=1,2,3 delims=." %%a in ("!FOUND_VERSION!") do (
                set "FOUND_MAJOR=%%a"
                set "FOUND_MINOR=%%b"
                set "FOUND_PATCH=%%c"
                
                REM Calculate numeric value for comparison (major*10000 + minor*100 + patch)
                set /a "FOUND_NUM=!FOUND_MAJOR!*10000 + !FOUND_MINOR!*100 + !FOUND_PATCH!"
                
                if !FOUND_NUM! GTR !HIGHEST_VERSION! (
                    set "HIGHEST_VERSION=!FOUND_NUM!"
                    set "MAJOR=!FOUND_MAJOR!"
                    set "MINOR=!FOUND_MINOR!"
                    set "PATCH=!FOUND_PATCH!"
                )
            )
        )
    )
) else (
    echo No existing packages found. Using default version 1.0.0
)
REM Clean up temp file
del temp_files.txt 2>nul

REM If packages exist, ask if should increment
if !HIGHEST_VERSION! GTR 0 (
    echo.
    echo ========================================
    echo  EXISTING PACKAGE FOUND
    echo ========================================
    echo  Current highest version: v!MAJOR!.!MINOR!.!PATCH!
    echo  Existing file: !DIRNAME!_v!MAJOR!.!MINOR!.!PATCH!.nextpkg
    echo.
    echo  Options:
    echo  [Y] Increment version to v!MAJOR!.!MINOR!.!PATCH! --^> v!MAJOR!.!MINOR!.!PATCH+1!
    echo  [N] Overwrite existing package
    echo.
    set /p "INCREMENT=Please choose [Y/N]: "
    echo.
    
    if /i "!INCREMENT!"=="y" (
        set /a "PATCH=!PATCH!+1"
        echo Creating new version: v!MAJOR!.!MINOR!.!PATCH!
    ) else (
        echo Overwriting existing package: !DIRNAME!_v!MAJOR!.!MINOR!.!PATCH!.nextpkg
        del "!DIRNAME!_v!MAJOR!.!MINOR!.!PATCH!.nextpkg" 2>nul
    )
) else (
    echo No existing packages found. Starting with version 1.0.0
)

set "VERSION=!MAJOR!.!MINOR!.!PATCH!"
set "PACKAGENAME=%DIRNAME%_v!VERSION!.nextpkg"

echo Creating package: !PACKAGENAME!

REM Try to find 7-Zip installation
set "SEVENZIP="
if exist "%ProgramFiles%\7-Zip\7z.exe" (
    set "SEVENZIP=%ProgramFiles%\7-Zip\7z.exe"
) else if exist "%ProgramFiles(x86)%\7-Zip\7z.exe" (
    set "SEVENZIP=%ProgramFiles(x86)%\7-Zip\7z.exe"
) else (
    echo 7-Zip not found in standard locations.
    echo Please install 7-Zip from https://www.7-zip.org/
    echo Or specify the path manually in this script.
    pause
    exit /b 1
)

echo Using 7-Zip: !SEVENZIP!
echo.

REM Parse metadata.json to get source directories
echo Parsing metadata.json for source directories...
set "SOURCES="

REM Read and parse the JSON file to extract Source values from FileMappings
for /f "tokens=*" %%a in ('type "metadata.json"') do (
    set "line=%%a"
    REM Look for Source entries in FileMappings
    echo !line! | findstr /C:"\"Source\":" >nul
    if !errorlevel! equ 0 (
        REM Extract the source directory name
        for /f "tokens=2 delims=:," %%b in ("!line!") do (
            set "source=%%b"
            REM Remove quotes and spaces
            set "source=!source:"=!"
            set "source=!source: =!"
            if "!SOURCES!"=="" (
                set "SOURCES=!source!"
            ) else (
                set "SOURCES=!SOURCES! !source!"
            )
            echo Found source directory: !source!
        )
    )
)

REM Generate changelog from git commits
echo Generating changelog from git commits...
set "CHANGELOG_FILE=!DIRNAME!_v!MAJOR!.!MINOR!.!PATCH!_CHANGELOG.md"

REM Find last version tag
git tag --sort=-version:refname | findstr /R "^v[0-9]" > temp_tags.txt 2>nul
set "LAST_TAG="
for /f "tokens=1" %%t in (temp_tags.txt) do (
    set "LAST_TAG=%%t"
    goto :found_tag
)
:found_tag
del temp_tags.txt 2>nul

REM Generate changelog
echo # Changelog for Version v!MAJOR!.!MINOR!.!PATCH! > "!CHANGELOG_FILE!"
echo. >> "!CHANGELOG_FILE!"
echo Generated on: %DATE% %TIME% >> "!CHANGELOG_FILE!"
echo. >> "!CHANGELOG_FILE!"

if "!LAST_TAG!"=="" (
    echo ## All Changes ^(Initial Release^) >> "!CHANGELOG_FILE!"
    git log --oneline --pretty=format:"- %%s ^(%%h^)" >> "!CHANGELOG_FILE!" 2>nul
) else (
    echo ## Changes since !LAST_TAG! >> "!CHANGELOG_FILE!"
    git log !LAST_TAG!..HEAD --oneline --pretty=format:"- %%s ^(%%h^)" >> "!CHANGELOG_FILE!" 2>nul
)

echo. >> "!CHANGELOG_FILE!"
echo. >> "!CHANGELOG_FILE!"
echo ## File Changes >> "!CHANGELOG_FILE!"
if "!LAST_TAG!"=="" (
    git diff --name-status HEAD~10..HEAD >> "!CHANGELOG_FILE!" 2>nul
) else (
    git diff --name-status !LAST_TAG!..HEAD >> "!CHANGELOG_FILE!" 2>nul
)

REM Create the archive with 7-Zip
echo Adding files to archive...
echo Sources to include: !SOURCES!
"!SEVENZIP!" a -tzip "!PACKAGENAME!" "metadata.json" "!CHANGELOG_FILE!" !SOURCES!

REM Check result
if exist "!PACKAGENAME!" (
    echo.
    echo Package created successfully: !PACKAGENAME!
    echo Package size:
    dir "!PACKAGENAME!" | findstr "!PACKAGENAME!"
    echo.
    echo Changelog created: !CHANGELOG_FILE!
    echo.
    
    REM Ask if user wants to create git tag
    echo ========================================
    echo  CREATE GIT TAG
    echo ========================================
    echo  Create git tag v!MAJOR!.!MINOR!.!PATCH! for this release?
    echo  This will help track changes for future changelogs.
    echo.
    set /p "CREATE_TAG=Create tag [Y/N]: "
    echo.
    
    if /i "!CREATE_TAG!"=="y" (
        git tag -a "v!MAJOR!.!MINOR!.!PATCH!" -m "Release v!MAJOR!.!MINOR!.!PATCH! - Package: !PACKAGENAME!"
        if !errorlevel! == 0 (
            echo Git tag v!MAJOR!.!MINOR!.!PATCH! created successfully!
            echo Changelog will be more accurate for next release.
        ) else (
            echo Warning: Could not create git tag. Make sure you're in a git repository.
        )
    )
    
    echo.
    echo Package contents:
    "!SEVENZIP!" l "!PACKAGENAME!"
    
    REM Cleanup - ask if changelog file should be kept
    echo.
    echo ========================================
    echo  CLEANUP
    echo ========================================
    echo  Keep changelog file "!CHANGELOG_FILE!" on disk?
    echo.
    set /p "KEEP_CHANGELOG=Keep changelog [Y/N]: "
    
    if /i not "!KEEP_CHANGELOG!"=="y" (
        del "!CHANGELOG_FILE!" 2>nul
        echo Changelog file removed from disk ^(still included in package^).
    ) else (
        echo Changelog file kept: !CHANGELOG_FILE!
    )
) else (
    echo Failed to create package!
    REM Cleanup changelog on failure
    if exist "!CHANGELOG_FILE!" del "!CHANGELOG_FILE!" 2>nul
)

pause