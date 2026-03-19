# File Wizard - Windows Launcher
# This script activates the virtual environment and starts the application

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "File Wizard - Windows Launcher" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get the script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

# Check if virtual environment exists
$VenvPath = Join-Path $ScriptDir "venv"
$VenvActivate = Join-Path $VenvPath "Scripts\Activate.ps1"

if (-not (Test-Path $VenvActivate)) {
    Write-Host "ERROR: Virtual environment not found at: $VenvPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please create and set up the virtual environment first:" -ForegroundColor Yellow
    Write-Host "  python -m venv venv" -ForegroundColor White
    Write-Host "  .\venv\Scripts\Activate.ps1" -ForegroundColor White
    Write-Host "  pip install -r requirements_windows.txt" -ForegroundColor White
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Activate virtual environment
Write-Host "Activating virtual environment..." -ForegroundColor Green
& $VenvActivate

# Check if dependencies are installed
Write-Host "Checking dependencies..." -ForegroundColor Green
try {
    $null = Get-Command fastapi -ErrorAction Stop
} catch {
    Write-Host "ERROR: Dependencies not installed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install dependencies:" -ForegroundColor Yellow
    Write-Host "  pip install -r requirements_windows.txt" -ForegroundColor White
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Run the batch file
Write-Host "Starting File Wizard..." -ForegroundColor Green
Write-Host ""
& ".\run.bat"
