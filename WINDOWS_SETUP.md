# File Wizard - Windows Setup Guide

> **🇷🇺 Русская версия:** [WINDOWS_SETUP_RU.md](WINDOWS_SETUP_RU.md)

## Quick Start for Windows

### 1. Install Dependencies

#### Python and Virtual Environment
```powershell
# Make sure Python 3.10+ is installed
python --version

# Create virtual environment
python -m venv venv

# Allow script execution (required once)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Activate virtual environment
.\venv\Scripts\Activate.ps1
```

If you see an error about script execution, run:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### Install Python Dependencies

**Option 1: Standard installation (recommended)**
```powershell
pip install --upgrade pip
pip install -r requirements_windows.txt
```

**Option 2: If you need html5_parser**
```powershell
# Install pkg-config via Chocolatey
choco install pkgconfiglite

# Then install dependencies
pip install --upgrade pip
pip install -r requirements.txt
```

### 2. Install External Tools (Optional)

For full functionality, install these tools:

#### Via Chocolatey (recommended)
```powershell
# Install Chocolatey if not already installed
# Run PowerShell as Administrator and execute:
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install tools
choco install ffmpeg
choco install tesseract
choco install libreeoffice
choco install pandoc
choco install poppler
choco install pkgconfiglite  # for html5_parser
```

#### Manual Installation
- **Tesseract OCR:** https://github.com/UB-Mannheim/tesseract/wiki
- **FFmpeg:** https://ffmpeg.org/download.html
- **LibreOffice:** https://www.libreoffice.org/download/
- **Pandoc:** https://pandoc.org/installing.html
- **Poppler** (for PDF tools): https://github.com/oschwartz10612/poppler-windows/releases

After installation, add these tools to your system PATH.

### 3. Configure Environment

Copy the environment file:
```powershell
copy .env.example .env
```

Edit the `.env` file if needed.

### 4. Run the Application

#### Option 1: Batch script (recommended)
```powershell
.\run.bat
```

#### Option 2: PowerShell script
```powershell
.\run.ps1
```

#### Option 3: Manual start
```powershell
# In one terminal window, start the web server
python -m uvicorn main:app --host 0.0.0.0 --port 8000

# In another window, start the task worker
python -m huey_consumer main.huey -w 4
```

### 5. Access the Application

Open your browser and go to:
```
http://localhost:8000
```

## Troubleshooting

### Error: "TesseractNotFoundError"
Install Tesseract OCR and add it to PATH:
```powershell
choco install tesseract
```

### Error: "ffmpeg not found"
Install FFmpeg:
```powershell
choco install ffmpeg
```

### Error importing resource module
This error is fixed in the Windows version. The `resource` module is not available on Windows, and the application now handles this correctly.

### PowerShell script execution blocked
If you see an error about script execution:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### CUDA/GPU issues
For CUDA support on Windows:
1. Install NVIDIA drivers
2. Install CUDA Toolkit
3. Use `requirements_cuda.txt` instead of `requirements.txt`

## Stopping the Application

- When using `.bat` or `.ps1`: press `Ctrl+C` in the terminal window
- The web server will stop automatically when you close the window
- The task worker will stop when you press `Ctrl+C`

## Additional Information

- **Original Repository:** https://github.com/LoredCast/filewizard
- **Issues (original):** https://github.com/LoredCast/filewizard/issues
- **This Repository:** https://github.com/akron2/filewizard-win
