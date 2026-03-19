@echo off
REM File Wizard - Simple Windows Launcher
REM Quick start script for running File Wizard on Windows

echo ========================================
echo File Wizard - Quick Start
echo ========================================
echo.

REM Check if virtual environment exists
if not exist "venv\Scripts\activate.bat" (
    echo Virtual environment not found!
    echo.
    echo Please run the following commands first:
    echo   python -m venv venv
    echo   venv\Scripts\activate
    echo   pip install -r requirements.txt
    echo.
    pause
    exit /b 1
)

REM Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat

REM Check if dependencies are installed
python -c "import fastapi" 2>nul
if errorlevel 1 (
    echo.
    echo Dependencies not installed!
    echo Please run: pip install -r requirements.txt
    echo.
    pause
    exit /b 1
)

REM Set environment variables
set LOCAL_ONLY=True
set UPLOADS_DIR=.\uploads
set PROCESSED_DIR=.\processed
set CHUNK_TMP_DIR=.\uploads\tmp

REM Create directories if they don't exist
if not exist "%UPLOADS_DIR%" mkdir "%UPLOADS_DIR%"
if not exist "%PROCESSED_DIR%" mkdir "%PROCESSED_DIR%"
if not exist "%CHUNK_TMP_DIR%" mkdir "%CHUNK_TMP_DIR%"

echo.
echo ========================================
echo Starting File Wizard...
echo ========================================
echo.
echo Web interface: http://localhost:8000
echo.
echo Press Ctrl+C to stop the server.
echo.

REM Start Uvicorn
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
