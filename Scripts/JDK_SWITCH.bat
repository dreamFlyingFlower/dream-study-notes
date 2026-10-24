@echo off
setlocal enabledelayedexpansion
chcp 936 >nul

:menu
cls
echo ========================================
echo        JDK Version Switcher
echo ========================================
echo.

echo [Current JDK Version]
if defined JAVA_HOME (
    echo   Path: %JAVA_HOME%
    echo.
    echo   Version Info:
    %JAVA_HOME%\bin\java -version 2>&1
) else (
    echo   JAVA_HOME not set
)
echo.
echo ========================================
echo.
echo [Available JDK Versions]
echo.

set count=0
for /f "tokens=1,* delims==" %%a in ('set JAVA_HOME_ 2^>nul') do (
    set /a count+=1
    set "fullname=%%a"
    set "version=!fullname:JAVA_HOME_=!"
    set "path_!count!=%%b"
    echo [!count!] JDK !version!
    echo     Path: %%b
    echo.
)

if %count%==0 (
    echo No JAVA_HOME_* variables found.
    echo.
    echo Please set like: JAVA_HOME_8 = C:\...\jdk1.8.0_202
    pause
    exit /b 1
)

echo [0] Exit
echo.
set /p "choice=Please enter number (0-%count%): "

if "%choice%"=="0" exit
if "%choice%"=="" goto menu

:: Validate input
set "selected_path="
for /l %%i in (1,1,%count%) do (
    if "%choice%"=="%%i" set "selected_path=!path_%%i!"
)

if not defined selected_path (
    echo Invalid option
    pause
    goto menu
)

:: Validate path
if not exist "%selected_path%\bin\java.exe" (
    echo Invalid path: %selected_path%
    pause
    exit /b 1
)

:: Set JAVA_HOME
echo.
echo Setting JAVA_HOME = %selected_path%
setx JAVA_HOME "%selected_path%" /M >nul 2>&1
if errorlevel 1 (
    echo Error: Please run as Administrator
    pause
    exit /b 1
)

:: Update current session
set "JAVA_HOME=%selected_path%"

echo.
echo ========================================
echo Success! JAVA_HOME updated to:
echo %selected_path%
echo.
echo Verify:
%selected_path%\bin\java -version
echo.
echo Note: New version will take effect in new command windows
pause
goto menu