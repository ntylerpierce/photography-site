@echo off
title Sync Gallery

:: Search for Git Bash in common installation locations
set "BASH_EXE="
if exist "%ProgramFiles%\Git\bin\bash.exe"          set "BASH_EXE=%ProgramFiles%\Git\bin\bash.exe"
if exist "%ProgramFiles(x86)%\Git\bin\bash.exe"     set "BASH_EXE=%ProgramFiles(x86)%\Git\bin\bash.exe"
if exist "%LocalAppData%\Programs\Git\bin\bash.exe" set "BASH_EXE=%LocalAppData%\Programs\Git\bin\bash.exe"

if not defined BASH_EXE (
    echo.
    echo  Git Bash not found.
    echo  Install Git for Windows at https://git-scm.com/download/win and try again.
    echo.
    pause
    exit /b 1
)

"%BASH_EXE%" --login "%~dp0sync-gallery.sh"
pause
