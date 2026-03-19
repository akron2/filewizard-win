# File Wizard - Установка на Windows

> **🇬🇧 English version:** [WINDOWS_SETUP.md](WINDOWS_SETUP.md)

## Быстрая установка на Windows

### 1. Установка зависимостей

#### Python и виртуальное окружение
```powershell
# Убедитесь, что Python 3.10-3.12 установлен (3.13+ может иметь проблемы совместимости)
python --version

# Создайте виртуальное окружение
python -m venv venv

# Разрешите выполнение скриптов (требуется один раз)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Активируйте виртуальное окружение
.\venv\Scripts\Activate.ps1
```

Если видите ошибку о выполнении скриптов, выполните:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### Установка Python-зависимостей

**Основная установка (рекомендуется)**
```powershell
pip install --upgrade pip
pip install -r requirements_windows.txt
```

**Опционально: Если нужен html5_parser**
```powershell
# Установите pkg-config через Chocolatey
choco install pkgconfiglite

# Затем установите зависимости
pip install --upgrade pip
pip install -r requirements_windows.txt
```

### 2. Установка внешних инструментов (опционально)

Для полной функциональности установите следующие инструменты:

#### Через Chocolatey (рекомендуется)
```powershell
# Установите Chocolatey, если ещё не установлен
# Запустите PowerShell от имени администратора и выполните:
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Установите инструменты
choco install ffmpeg
choco install tesseract
choco install libreeoffice
choco install pandoc
choco install poppler
choco install pkgconfiglite  # для html5_parser
```

#### Вручную
- **Tesseract OCR:** https://github.com/UB-Mannheim/tesseract/wiki
- **FFmpeg:** https://ffmpeg.org/download.html
- **LibreOffice:** https://www.libreoffice.org/download/
- **Pandoc:** https://pandoc.org/installing.html
- **Poppler** (для PDF): https://github.com/oschwartz10612/poppler-windows/releases

После установки добавьте пути к инструментам в системную переменную PATH.

### Опционально: Разделение по спикерам

Для включения определения собеседников (диаризация):

```powershell
# Установите pyannote.audio для диаризации
pip install pyannote.audio pyannote.pipeline

# Примечание: может потребоваться токен Hugging Face
# Получить токен: https://huggingface.co/settings/tokens
```

Затем примите условия использования моделей:
- https://huggingface.co/pyannote/speaker-diarization-3.1

### 3. Настройка окружения

Скопируйте файл окружения:
```powershell
copy .env.example .env
```

При необходимости отредактируйте `.env` файл.

### 4. Запуск приложения

```powershell
.\run.bat
```

Откройте http://localhost:8000 в браузере.

## Устранение проблем

### Ошибка "TesseractNotFoundError"
Установите Tesseract OCR и добавьте его в PATH:
```powershell
choco install tesseract
```

### Ошибка "ffmpeg not found"
Установите FFmpeg:
```powershell
choco install ffmpeg
```

### Ошибка при импорте resource
Эта ошибка исправлена в версии для Windows. Модуль `resource` недоступен на Windows, приложение теперь обрабатывает это корректно.

### Блокировка PowerShell скриптов
Если видите ошибку о выполнении скриптов:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### CUDA/GPU проблемы
Для работы с CUDA на Windows:
1. Установите NVIDIA драйверы
2. Установите CUDA Toolkit
3. Используйте `requirements_cuda.txt` вместо `requirements.txt`

### Порт 8000 уже занят
Закройте предыдущий экземпляр или измените порт в run.bat.

## Остановка приложения

Нажмите `Ctrl+C` в окне терминала для остановки сервера.

## Дополнительная информация

- **Оригинальный репозиторий:** https://github.com/LoredCast/filewizard
- **Issues (оригинал):** https://github.com/LoredCast/filewizard/issues
- **Этот репозиторий:** https://github.com/akron2/filewizard-win
