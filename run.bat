@echo off
REM File Wizard Windows Launcher
REM This script starts the FastAPI server and Huey task queue worker

echo ========================================
echo File Wizard - Windows Launcher
echo ========================================
echo.

REM Check for FFmpeg in local folder first, then in system PATH
set "FFMPEG_BIN="
if exist ".\ffmpeg_temp" (
    dir /b /ad ".\ffmpeg_temp" | findstr /r "^ffmpeg-" >nul 2>nul
    if not errorlevel 1 (
        for /d %%i in (ffmpeg_temp\ffmpeg-*) do (
            if exist "%%i\bin\ffmpeg.exe" (
                set "FFMPEG_BIN=%%~fi\bin"
                goto :ffmpeg_found
            )
        )
    )
)
:ffmpeg_found

if not defined FFMPEG_BIN (
    where ffmpeg >nul 2>nul
    if not errorlevel 1 (
        for %%i in (ffmpeg.exe) do set "FFMPEG_BIN=%%~$PATH:i"
    )
)

if not defined FFMPEG_BIN (
    echo FFmpeg not found. Downloading...
    if not exist ".\ffmpeg_temp" mkdir ".\ffmpeg_temp"
    pushd ffmpeg_temp

    REM Download FFmpeg (static build for Windows)
    echo Downloading FFmpeg...
    powershell -Command "Invoke-WebRequest -Uri 'https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip' -OutFile 'ffmpeg.zip'"

    echo Extracting FFmpeg...
    powershell -Command "Expand-Archive -Path 'ffmpeg.zip' -DestinationPath '.' -Force"

    REM Find the extracted folder (name varies by version)
    for /d %%i in (ffmpeg-*) do (
        if exist "%%i\bin\ffmpeg.exe" (
            set "FFMPEG_DIR=%%i"
        )
    )

    if defined FFMPEG_DIR (
        echo FFmpeg downloaded successfully.
        set "FFMPEG_BIN=%CD%\%FFMPEG_DIR%\bin"
        echo FFmpeg path: %FFMPEG_BIN%
    ) else (
        echo WARNING: Failed to locate FFmpeg after extraction.
    )

    popd
)

if defined FFMPEG_BIN (
    echo FFmpeg found: %FFMPEG_BIN%
    set "PATH=%FFMPEG_BIN%;%PATH%"
)

echo.

REM Load environment variables from .env file if it exists
if exist .env (
    echo Loading environment variables from .env...
    for /f "delims=" %%a in (.env) do (
        echo %%a | findstr /r /c:"^$" /c:"^#" >nul
        if errorlevel 1 (
            setlocal enabledelayedexpansion
            set "line=%%a"
            for /f "tokens=1,* delims==" %%b in ("!line!") do (
                set "varname=%%b"
                set "varvalue=%%c"
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
if defined FFMPEG_BIN echo   FFmpeg: %FFMPEG_BIN%
echo.

REM Create necessary directories
if not exist "%UPLOADS_DIR%" mkdir "%UPLOADS_DIR%"
if not exist "%PROCESSED_DIR%" mkdir "%PROCESSED_DIR%"
if not exist "%CHUNK_TMP_DIR%" mkdir "%CHUNK_TMP_DIR%"

echo ========================================
echo Starting File Wizard...
echo ========================================
echo.
echo Web interface: http://localhost:8000
echo.
echo Press Ctrl+C to stop the server.
echo.

REM Start Huey consumer in background, then Uvicorn in foreground
start /B python -c "from main import huey; from huey.consumer import Consumer; Consumer(huey, workers=4).run()"
timeout /t 2 /nobreak >nul
python -m uvicorn main:app --host 0.0.0.0 --port 8000
