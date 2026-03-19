# File Wizard - Windows Edition

A self-hosted, browser-based utility for file conversion, OCR and audio/video transcription. It wraps common CLI and Python converters (FFmpeg, LibreOffice, Pandoc, ImageMagick, etc.), plus `faster-whisper` and Tesseract OCR.

![Screenshot](screenshot.png)

---

## Features

- Convert between many file formats
- OCR for PDFs and images (Tesseract / ocrmypdf)
- Audio & Video transcription using Whisper (MP4, MKV, AVI, MOV, etc.)
- Speaker diarization - automatically identify different speakers (requires pyannote.audio)
- Simple, responsive dark UI with drag-and-drop
- Background job processing with real-time status updates
- `/settings` page for configuring tools and OAuth
- CPU-only by default; GPU acceleration available

---

## Installation

### Quick Start — Windows

```powershell
# Clone this repository
git clone https://github.com/akron2/filewizard-win.git
cd filewizard-win

# Python 3.10-3.12 recommended (3.13+ may have compatibility issues with some packages)
python --version

# Create and activate virtual environment
python -m venv venv

# Allow script execution (required once)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

.\venv\Scripts\Activate.ps1

# Install dependencies
pip install --upgrade pip
pip install -r requirements_windows.txt

# Run the application
.\run.bat
```

Open http://localhost:8000 in your browser.

---

## External Tools

For full functionality, install these tools:

### Via Chocolatey (recommended)
```powershell
# Install Chocolatey (run PowerShell as Administrator)
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install tools
choco install ffmpeg
choco install tesseract
choco install libreeoffice
choco install pandoc
choco install poppler
choco install pkgconfiglite  # for html5_parser
```

### Manual Installation
- **Tesseract OCR:** https://github.com/UB-Mannheim/tesseract/wiki
- **FFmpeg:** https://ffmpeg.org/download.html
- **LibreOffice:** https://www.libreoffice.org/download/
- **Pandoc:** https://pandoc.org/installing.html
- **Poppler:** https://github.com/oschwartz10612/poppler-windows/releases

---

## Speaker Diarization

Speaker diarization automatically identifies different speakers in conversations.

### First-time Setup

When you first use diarization:
1. The app will automatically open Hugging Face pages in your browser
2. Log in (or create account)
3. Click "Accept" on model pages:
   - https://huggingface.co/pyannote/speaker-diarization-3.1
   - https://huggingface.co/pyannote/segmentation-3.0
4. Return to terminal and press Enter
5. Models will download automatically (~500MB)

### Usage
- Enable "Identify Speakers (Diarization)" checkbox when transcribing
- Output format:
  ```
  [SPEAKER_00]:
  Hello, how are you?
  
  [SPEAKER_01]:
  I'm fine, thank you!
  ```

---

## Usage

1. Open http://localhost:8000
2. Drag & drop or select files
3. Choose action: Convert, OCR, or Transcribe
4. Track progress in History table

---

## Tools Table

| Tool | Input Formats | Output Formats | Notes |
|------|---------------|----------------|-------|
| **LibreOffice** | `.doc`, `.docx`, `.xls`, `.xlsx`, `.ppt`, `.pptx`, `.odt`, `.ods`, `.pdf`, `.rtf`, `.txt`, `.html`, `.csv` | `.pdf`, `.docx`, `.xlsx`, `.pptx`, `.odt`, `.html`, `.txt`, `.png`, `.jpg` | Office document conversion |
| **Pandoc** | `.md`, `.html`, `.tex`, `.docx`, `.odt`, `.epub`, `.rst` | `.pdf`, `.docx`, `.html`, `.epub`, `.md`, `.tex`, `.pptx` | Document conversion, requires LaTeX for PDF |
| **Ghostscript** | `.pdf`, `.ps`, `.eps` | `.pdf`, `.png`, `.jpg`, `.tiff` | PDF manipulation, rasterization |
| **Calibre** | `.epub`, `.mobi`, `.azw3`, `.fb2`, `.docx`, `.pdf`, `.html` | `.epub`, `.mobi`, `.azw3`, `.pdf`, `.docx`, `.txt` | E-book format conversion |
| **FFmpeg** | `.mp4`, `.mkv`, `.avi`, `.mov`, `.webm`, `.mp3`, `.wav`, `.flac`, `.aac` | `.mp4`, `.mkv`, `.avi`, `.mp3`, `.wav`, `.flac`, `.gif` | Audio/video transcoding |
| **libvips** | `.jpg`, `.png`, `.tiff`, `.webp`, `.avif`, `.heif` | `.jpg`, `.png`, `.webp`, `.avif`, `.tiff` | Fast image processing |
| **GraphicsMagick** | `.jpg`, `.png`, `.gif`, `.tiff`, `.bmp`, `.pdf` | `.jpg`, `.png`, `.gif`, `.tiff`, `.bmp`, `.pdf` | Image processing |
| **ImageMagick** | `.jpg`, `.png`, `.gif`, `.tiff`, `.bmp`, `.svg` | `.jpg`, `.png`, `.gif`, `.tiff`, `.bmp`, `.svg` | Image processing |
| **Inkscape** | `.svg`, `.pdf`, `.eps`, `.ai`, `.png` | `.svg`, `.pdf`, `.png`, `.eps` | Vector graphics |
| **Tesseract OCR** | `.png`, `.jpg`, `.tiff`, `.pdf` (images) | `.txt`, `.pdf` (searchable) | Text recognition |
| **faster-whisper** | `.mp3`, `.wav`, `.m4a`, `.flac`, `.ogg`, `.mp4`, `.mkv`, `.avi` | `.txt`, `.srt`, `.vtt` | Audio/video transcription |

---

## Troubleshooting

### PowerShell script execution blocked
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Error: "TesseractNotFoundError"
```powershell
choco install tesseract
```

### Error: "ffmpeg not found"
```powershell
choco install ffmpeg
```

### Port 8000 already in use
Close previous instance or change port in run.bat.

### Diarization not working
1. Ensure pyannote.audio is installed: `pip install pyannote.audio pyannote.pipeline`
2. Accept model terms on Hugging Face (see Speaker Diarization section)

---

## Security

**Warning:** Exposing this app publicly without authentication risks arbitrary code execution. Intended for local use or behind OAuth/OIDC.

---

## Additional Information

- **Original Repository:** https://github.com/LoredCast/filewizard
- **This Repository:** https://github.com/akron2/filewizard-win
- **Issues:** https://github.com/akron2/filewizard-win/issues
