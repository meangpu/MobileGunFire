@echo off
setlocal enabledelayedexpansion
set "BranchName=main"
set "ScriptName=%~nx0"
echo Step 1: Preparing the repository
cd /d "%~dp0"
echo Step 2: Acquiring GitHub repository URL
for /f "tokens=*" %%a in ('git config --get remote.origin.url') do set "RepoUrl=%%a"
if "!RepoUrl!"=="" (
    echo Error: Could not acquire GitHub repository URL.
    echo Please ensure this is a Git repository and has a remote named 'origin'.
    echo Verify by running 'git remote -v' in the repository directory.
    exit /b 1
)
echo Repository URL: !RepoUrl!
echo Step 3: Backing up important files
if not exist "temp_backup" mkdir "temp_backup"
copy "%ScriptName%" "temp_backup\"
echo Step 4: Resetting the repository
if exist ".git" (
    attrib -r ".git\*.*" /s
    rmdir /s /q ".git"
)
echo Step 5: Initializing a new repository
git init -b main
echo Step 6: Copying new build files
rem Add your copy commands here
echo Step 7: Restoring backed-up files
copy /y "temp_backup\*" .
rmdir /s /q "temp_backup"
echo Step 8: Committing changes
git add -A
git commit -m "Reset build %date%" > nul 2>&1
if errorlevel 1 (
    echo No changes to commit. Exiting.
    exit /b 0
)
echo Step 9: Pushing to GitHub
git remote add origin !RepoUrl!
git push -f origin %BranchName%
echo Process completed. Repository has been reset and updated.
echo Opening GitHub repository in default browser...

:: Modified URL parsing section
set "BrowserUrl=!RepoUrl!"
if "!BrowserUrl:~0,4!"=="git@" (
    set "BrowserUrl=!BrowserUrl:git@=https://!"
    set "BrowserUrl=!BrowserUrl::=/"
)
set "BrowserUrl=!BrowserUrl:.git=!"

start "" "!BrowserUrl!"
endlocal