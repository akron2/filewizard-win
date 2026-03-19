# File Wizard - Windows Edition

[![PayPal](https://img.shields.io/badge/PayPal-Donate-blue?logo=paypal&logoColor=white)](https://www.paypal.me/unterrikermanu)

**Windows-совместимая версия [LoredCast/filewizard](https://github.com/LoredCast/filewizard)**

> **🇬🇧 English version:** [README.md](README.md)

Веб-утилита для конвертации файлов, OCR и транскрибации аудио/видео. Поддерживает FFmpeg, LibreOffice, Pandoc, ImageMagick, `faster-whisper` и Tesseract OCR.

![Screenshot](screenshot.png)

> **💡 Для Windows:** Подробная инструкция в [WINDOWS_SETUP_RU.md](WINDOWS_SETUP_RU.md). Быстрый старт: запустите `.\run.bat` после установки зависимостей.

---

## Возможности
- Конвертация между множеством форматов; расширяемо через `settings.yml`.
- OCR для PDF и изображений (`tesseract` / `ocrmypdf`).
- **Транскрибация аудио и видео** с помощью Whisper (MP4, MKV, AVI, MOV и другие).
- Простой тёмный интерфейс с drag-and-drop.
- Фоновая обработка задач с обновлением статуса в реальном времени.
- Страница `/settings` для настройки инструментов и OAuth.
- Работа на CPU по умолчанию; доступна поддержка GPU.

## Безопасность
**Внимание:** публикация этого приложения без аутентификации создаёт риск выполнения произвольного кода. Предназначен для локального использования или за обратным прокси с OAuth/OIDC.

#### Технологии
FastAPI, vanilla HTML/JS/CSS frontend.

## Установка

### Быстрый старт — Windows

```powershell
# Клонировать репозиторий
git clone https://github.com/akron2/filewizard-win.git
cd filewizard-win

# Рекомендуется Python 3.10-3.12 (3.13+ может иметь проблемы совместимости)
python --version

# Создать и активировать виртуальное окружение
python -m venv venv

# Разрешить выполнение скриптов (требуется один раз)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

.\venv\Scripts\Activate.ps1

# Установить зависимости (для Windows)
pip install -r requirements_windows.txt

# Запустить приложение
.\run.bat
```

Откройте http://localhost:8000 в браузере.

### Оригинальный репозиторий

Это Windows-совместимая версия. Оригинальная Linux/Docker версия:
https://github.com/LoredCast/filewizard

## Документация

- **Установка на Windows:** [WINDOWS_SETUP_RU.md](WINDOWS_SETUP_RU.md)
- **Оригинальная Wiki:** https://github.com/LoredCast/filewizard/wiki

## Использование
1. Откройте `http://127.0.0.1:8000`.
2. Перетащите или выберите файлы.
3. Выберите действие: Конвертация, OCR или Транскрибация.
4. Отслеживайте прогресс в таблице History (обновляется автоматически).

## Таблица инструментов

| Инструмент | Входные форматы | Выходные форматы | Примечания |
|---|---|---|---|
| **LibreOffice** | `.doc`, `.docx`, `.xls`, `.xlsx`, `.ppt`, `.pptx`, `.odt`, `.ods`, `.odp`, `.rtf`, `.txt`, `.html`, `.csv` | `.pdf`, `.docx`, `.xlsx`, `.pptx`, `.odt`, `.html`, `.txt`, `.png`, `.jpg` | Конвертация офисных документов |
| **Pandoc** | `.md`, `.html`, `.tex`, `.docx`, `.odt`, `.epub`, `.rst` | `.pdf`, `.docx`, `.html`, `.epub`, `.md`, `.tex`, `.pptx` | Конвертация документов, требует LaTeX для PDF |
| **Ghostscript** | `.pdf`, `.ps`, `.eps` | `.pdf`, `.png`, `.jpg`, `.tiff` | Манипуляции с PDF, растеризация |
| **Calibre** | `.epub`, `.mobi`, `.azw3`, `.fb2`, `.docx`, `.pdf`, `.html` | `.epub`, `.mobi`, `.azw3`, `.pdf`, `.docx`, `.txt` | Конвертация электронных книг |
| **FFmpeg** | `.mp4`, `.mkv`, `.avi`, `.mov`, `.webm`, `.mp3`, `.wav`, `.flac`, `.aac` | `.mp4`, `.mkv`, `.avi`, `.mp3`, `.wav`, `.flac`, `.gif` | Аудио/видео конвертация |
| **libvips** | `.jpg`, `.png`, `.tiff`, `.webp`, `.avif`, `.heif` | `.jpg`, `.png`, `.webp`, `.avif`, `.tiff` | Быстрая обработка изображений |
| **GraphicsMagick** | `.jpg`, `.png`, `.gif`, `.tiff`, `.bmp`, `.pdf` | `.jpg`, `.png`, `.gif`, `.tiff`, `.bmp`, `.pdf` | Обработка изображений |
| **ImageMagick** | `.jpg`, `.png`, `.gif`, `.tiff`, `.bmp`, `.svg` | `.jpg`, `.png`, `.gif`, `.tiff`, `.bmp`, `.svg` | Обработка изображений |
| **Inkscape** | `.svg`, `.pdf`, `.eps`, `.ai`, `.png` | `.svg`, `.pdf`, `.png`, `.eps` | Векторная графика |
| **Tesseract OCR** | `.png`, `.jpg`, `.tiff`, `.pdf` (изображения) | `.txt`, `.pdf` (с текстовым слоем) | Распознавание текста |
| **faster-whisper** | `.mp3`, `.wav`, `.m4a`, `.flac`, `.ogg`, `.mp4`, `.mkv`, `.avi` | `.txt`, `.srt`, `.vtt` | Транскрибация аудио и видео |

---

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/loredcast)
