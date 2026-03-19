@echo off
REM File Wizard Windows Launcher
REM This script starts the FastAPI server and Huey task queue worker

echo ========================================
echo File Wizard - Windows Launcher
echo ========================================
echo.

REM Check and download FFmpeg if not found
where ffmpeg >nul 2>nul
if errorlevel 1 (
    echo FFmpeg not found. Downloading...
    if not exist ".\ffmpeg_temp" mkdir ".\ffmpeg_temp"
    cd ffmpeg_temp
    
    REM Download FFmpeg (static build for Windows)
    echo Downloading FFmpeg...
    powershell -Command "Invoke-WebRequest -Uri 'https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip' -OutFile 'ffmpeg.zip'"
    
    echo Extracting FFmpeg...
    powershell -Command "Expand-Archive -Path 'ffmpeg.zip' -DestinationPath '.' -Force"
    
    REM Find the extracted folder (name varies by version)
    for /d %%i in (ffmpeg-*) do set "FFMPEG_DIR=%%i"
    
    if defined FFMPEG_DIR (
        echo FFmpeg downloaded successfully.
        echo Adding FFmpeg to PATH for this session...
        set "FFMPEG_PATH=%CD%\%FFMPEG_DIR%\bin"
        set "PATH=%FFMPEG_PATH%;%PATH%"
        echo FFmpeg is now available.
    ) else (
        echo WARNING: Failed to locate FFmpeg after extraction.
        echo Please install FFmpeg manually or check your internet connection.
    )
    
    cd ..
) else (
    for %%i in (ffmpeg.exe) do echo FFmpeg found: %%~$PATH:i
)

echo.

REM Load environment variables from .env file if it exists
if exist .env (
    echo Loading environment variables from .env...
    for /f "delims=" %%a in (.env) do (
        REM Skip empty lines and comments
        echo %%a | findstr /r /c:"^$" /c:"^#" >nul
        if errorlevel 1 (
            setlocal enabledelayedexpansion
            set "line=%%a"
            REM Extract variable name and value
            for /f "tokens=1,* delims==" %%b in ("!line!") do (
                set "varname=%%b"
                set "varvalue=%%c"
                REM Remove surrounding quotes if present
                set "varvalue=!varvalue:"=!"
                endlocal & set "!varname!=!varvalue!"
            )
        )
    )
    echo Environment loaded.
    echo.
)

REM Set default values if not already set
if not defined SECRET_KEY (
    echo Generating random SECRET_KEY...
    REM Use PowerShell to generate random hex
    for /f "delims=" %%i in ('powershell -Command "[System.BitConverter]::ToString((New-Object Security.Cryptography.SHA256Managed).ComputeHash([System.Text.Encoding]::UTF8.GetBytes([System.Guid]::NewGuid().ToString()))).Replace('-','').Substring(0,32)"') do set SECRET_KEY=%%i
)

if not defined UPLOADS_DIR set UPLOADS_DIR=.\uploads
if not defined PROCESSED_DIR set PROCESSED_DIR=.\processed
if not defined CHUNK_TMP_DIR set CHUNK_TMP_DIR=.\uploads\tmp
if not defined LOCAL_ONLY set LOCAL_ONLY=True

echo Starting File Wizard with configuration:
echo   UPLOADS_DIR=%UPLOADS_DIR%
echo   PROCESSED_DIR=%PROCESSED_DIR%
echo   CHUNK_TMP_DIR=%CHUNK_TMP_DIR%
echo   LOCAL_ONLY=%LOCAL_ONLY%
echo.

REM Create necessary directories
if not exist "%UPLOADS_DIR%" mkdir "%UPLOADS_DIR%"
if not exist "%PROCESSED_DIR%" mkdir "%PROCESSED_DIR%"
if not exist "%CHUNK_TMP_DIR%" mkdir "%CHUNK_TMP_DIR%"

echo ========================================
echo Starting File Wizard...
echo ========================================
echo.

REM Start Uvicorn server in a separate process
echo Starting Uvicorn web server on port 8000...
start "FileWizard Web Server" cmd /k "set LOCAL_ONLY=%LOCAL_ONLY%& set SECRET_KEY=%SECRET_KEY%& set UPLOADS_DIR=%UPLOADS_DIR%& set PROCESSED_DIR=%PROCESSED_DIR%& set CHUNK_TMP_DIR=%CHUNK_TMP_DIR%& uvicorn main:app --host 0.0.0.0 --port 8000 --reload"

REM Wait a moment for server to start
timeout /t 3 /nobreak >nul

echo Starting Huey task queue worker...
echo.
echo ========================================
echo File Wizard is starting...
echo Web interface: http://localhost:8000
echo ========================================
echo.
echo Press Ctrl+C to stop the Huey worker.
echo The web server will continue running in a separate window.
echo.

REM Start Huey consumer in the current process
set LOCAL_ONLY=%LOCAL_ONLY%
set SECRET_KEY=%SECRET_KEY%
set UPLOADS_DIR=%UPLOADS_DIR%
set PROCESSED_DIR=%PROCESSED_DIR%
set CHUNK_TMP_DIR=%CHUNK_TMP_DIR%
python -c "from main import huey; from huey.consumer import Consumer; Consumer(huey, workers=4).run()"
