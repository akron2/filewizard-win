# File Wizard - Docker на Windows

## Запуск Docker на Windows

File Wizard поддерживает запуск в Docker на Windows через **Docker Desktop**.

### Предварительные требования

1. **Docker Desktop для Windows**
   - Скачайте с https://www.docker.com/products/docker-desktop/
   - Установите и запустите Docker Desktop
   - Убедитесь, что Docker работает (в статусе должно быть "Docker Desktop is running")

2. **WSL2 (рекомендуется)**
   - Docker Desktop использует WSL2 для лучшей производительности
   - Установите WSL2: https://learn.microsoft.com/ru-us/windows/wsl/install

## Быстрый старт

### 1. Подготовка
```powershell
# Клонируйте репозиторий
git clone https://github.com/akron2/filewizard-win.git
cd filewizard-win

# Создайте директорию для конфигурации
mkdir config
```

### 2. Запуск с готовым образом (рекомендуется)
```powershell
docker compose up -d
```

Приложение будет доступно по адресу: http://localhost:6969

### 3. Сборка локально (если нужно)
```powershell
# Полная версия (без CUDA)
docker build --target full-final -t filewizard:local .

# Малая версия (меньше зависимостей)
docker build --target small-final -t filewizard:small .

# CUDA версия (требуется NVIDIA GPU)
docker build --target cuda-final -t filewizard:cuda .
```

## Настройка для Windows

### Томa и пути

В `docker-compose.yml` используются именованные тома для данных:
```yaml
volumes:
  - ./config:/app/config
  - ./uploads_data:/app/uploads
  - ./processed_data:/app/processed
```

**Преимущества именованных томов на Windows:**
- Лучшая производительность чем bind mounts
- Нет проблем с правами доступа
- Данные сохраняются между перезапусками

### Проблемы с путями

Если возникают проблемы с монтированием томов, используйте абсолютные пути:

```yaml
volumes:
  - C:\filewizard\config:/app/config
  - C:\filewizard\uploads:/app/uploads
  - C:\filewizard\processed:/app/processed
```

Или используйте forward slashes:
```yaml
volumes:
  - /c/filewizard/config:/app/config
  - /c/filewizard/uploads:/app/uploads
```

## CUDA на Windows

Для работы с GPU на Windows:

1. Установите **NVIDIA драйверы** для Windows
2. Установите **NVIDIA Container Toolkit** (входит в Docker Desktop)
3. В `docker-compose.yml` раскомментируйте секцию GPU:

```yaml
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: all
          capabilities: [gpu]
```

4. Запустите CUDA версию:
```powershell
docker compose --profile cuda up -d
```

## Управление контейнером

```powershell
# Запуск
docker compose up -d

# Остановка
docker compose down

# Просмотр логов
docker compose logs -f

# Перезапуск
docker compose restart

# Очистка (данные сохранятся в томах)
docker compose down --volumes  # Удалит тома!
```

## Обновление

```powershell
# Остановить текущую версию
docker compose down

# Pull новой версии
docker pull loredcast/filewizard:latest

# Запустить новую версию
docker compose up -d

# Или пересобрать локально
docker compose build --no-cache
docker compose up -d
```

## Решение проблем

### Ошибка "Bind for 0.0.0.0:6969 failed: port is already allocated"
Порт 6969 уже занят. Измените порт в `docker-compose.yml`:
```yaml
ports:
  - "8080:8000"  # Используйте другой порт
```

### Ошибка монтирования томов
Убедитесь, что Docker Desktop имеет доступ к диску:
1. Откройте Docker Desktop Settings
2. Перейдите в Resources → File Sharing
3. Добавьте диск (обычно C:)

### Контейнер не запускается
Проверьте логи:
```powershell
docker compose logs web
```

### Проблемы с памятью
Увеличьте лимит памяти в Docker Desktop:
1. Settings → Resources
2. Увеличьте Memory (рекомендуется 4GB+)

### Медленная работа с файлами
Используйте именованные тома вместо bind mounts:
```yaml
volumes:
  - uploads_data:/app/uploads
  - processed_data:/app/processed

volumes:
  uploads_data: {}
  processed_data: {}
```

## Отличия от Linux

| Функция | Windows | Linux |
|---------|---------|-------|
| Docker Engine | Docker Desktop (WSL2/Hyper-V) | Нативный |
| Монтирование томов | Требует настройки File Sharing | Работает из коробки |
| Производительность | Немного ниже из-за виртуализации | Нативная |
| GPU/CUDA | Требуется NVIDIA Container Toolkit | Требуется nvidia-docker2 |

## Альтернатива: WSL2

Для лучшей производительности можно запускать File Wizard напрямую в WSL2:

```powershell
# Откройте WSL2 терминал
wsl

# Внутри WSL2
cd /mnt/c/Users/yourname/filewizard-win
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
./run.sh
```

Это даст производительность близкую к нативному Linux.

## Дополнительные ресурсы

- Docker Desktop: https://docs.docker.com/desktop/
- Docker на Windows: https://docs.docker.com/desktop/wsl/
- WSL2: https://learn.microsoft.com/ru-us/windows/wsl/
