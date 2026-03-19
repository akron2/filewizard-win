# File Wizard - Windows Setup Guide

> **🇷🇺 Русская версия:** [WINDOWS_SETUP_RU.md](WINDOWS_SETUP_RU.md)

## Quick Start for Windows

### 1. Install Dependencies

#### Python and Virtual Environment
```powershell
# Make sure Python 3.10-3.12 is installed (3.13+ may have compatibility issues)
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

**Standard installation (recommended)**
```powershell
pip install --upgrade pip
pip install -r requirements_windows.txt
```

**Optional: If you need html5_parser**
```powershell
# Install pkg-config via Chocolatey
choco install pkgconfiglite

# Then install dependencies
pip install --upgrade pip
pip install -r requirements_windows.txt
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

```powershell
.\run.bat
```

Open http://localhost:8000 in your browser.

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

### Port 8000 already in use
Close the previous instance or change the port in run.bat.

## Stopping the Application

Press `Ctrl+C` in the terminal window to stop the server.

## Additional Information

- **Original Repository:** https://github.com/LoredCast/filewizard
- **Issues (original):** https://github.com/LoredCast/filewizard/issues
- **This Repository:** https://github.com/akron2/filewizard-win
