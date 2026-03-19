# File Wizard - Windows Quick Start Guide

## Быстрая установка на Windows

### 1. Установка зависимостей

#### Python и виртуальное окружение
```powershell
# Убедитесь, что Python 3.10+ установлен
python --version

# Создайте виртуальное окружение
python -m venv venv

# Активируйте виртуальное окружение
.\venv\Scripts\Activate.ps1
```

Если PowerShell блокирует выполнение скриптов, выполните:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### Установка Python-зависимостей

**Вариант 1: Основная установка (рекомендуется)**
```powershell
pip install --upgrade pip
pip install -r requirements_windows.txt
```

**Вариант 2: Если нужен html5_parser**
```powershell
# Установите pkg-config через Chocolatey
choco install pkgconfiglite

# Затем установите зависимости
pip install --upgrade pip
pip install -r requirements.txt
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
- **Poppler:** https://github.com/oschwartz10612/poppler-windows/releases

После установки добавьте пути к инструментам в системную переменную PATH.

### 3. Настройка окружения

Скопируйте файл окружения:
```powershell
copy .env.example .env
```

При необходимости отредактируйте `.env` файл.

### 4. Запуск приложения

#### Вариант 1: Batch-скрипт (рекомендуется)
```powershell
.\run.bat
```

#### Вариант 2: PowerShell-скрипт
```powershell
.\run.ps1
```

#### Вариант 3: Ручной запуск
```powershell
# В одном окне терминала запустите веб-сервер
python -m uvicorn main:app --host 0.0.0.0 --port 8000

# В другом окне запустите worker задач
python -m huey_consumer main.huey -w 4
```

### 5. Доступ к приложению

Откройте браузер и перейдите по адресу:
```
http://localhost:8000
```

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

### Проблемы с CUDA/GPU
Для работы с CUDA на Windows:
1. Установите NVIDIA драйверы
2. Установите CUDA Toolkit
3. Используйте `requirements_cuda.txt` вместо `requirements.txt`

## Остановка приложения

- При использовании `.bat` или `.ps1`: нажмите `Ctrl+C` в окне терминала
- Веб-сервер остановится автоматически при закрытии окна
- Worker задач остановится при нажатии `Ctrl+C`

## Дополнительная информация

- Документация: https://github.com/LoredCast/filewizard/wiki
- Issues: https://github.com/LoredCast/filewizard/issues
