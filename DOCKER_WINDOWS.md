# File Wizard - Docker on Windows

> **🇷🇺 Русская версия:** [DOCKER_WINDOWS_RU.md](DOCKER_WINDOWS_RU.md)

**Windows-compatible fork of [LoredCast/filewizard](https://github.com/LoredCast/filewizard)**

## Quick Docker Setup for Windows

File Wizard supports running in Docker on Windows via **Docker Desktop**.

### Prerequisites

1. **Docker Desktop for Windows**
   - Download from https://www.docker.com/products/docker-desktop/
   - Install and launch Docker Desktop
   - Ensure Docker is running (status should show "Docker Desktop is running")

2. **WSL2 (recommended)**
   - Docker Desktop uses WSL2 for better performance
   - Install WSL2: https://learn.microsoft.com/en-us/windows/wsl/install

## Quick Start

### 1. Prepare
```powershell
# Clone this repository
git clone https://github.com/akron2/filewizard-win.git
cd filewizard-win

# Create config directory
mkdir config
```

### 2. Run with Pre-built Image

> **Note:** The pre-built image `loredcast/filewizard:latest` may be outdated. Local build is recommended (step 3).

```powershell
docker compose up -d
```

The application will be available at http://localhost:6969

### 3. Build Locally (recommended)
```powershell
# Full build (includes all dependencies but no CUDA)
docker build --target full-final -t filewizard:local .

# Small build (excludes TeX and some large dependencies)
docker build --target small-final -t filewizard:small .

# CUDA build (requires NVIDIA GPU)
docker build --target cuda-final -t filewizard:cuda .
```

## Windows Configuration

### Volumes and Paths

The `docker-compose.yml` uses named volumes for data:
```yaml
volumes:
  - ./config:/app/config
  - ./uploads_data:/app/uploads
  - ./processed_data:/app/processed
```

**Benefits of named volumes on Windows:**
- Better performance than bind mounts
- No permission issues
- Data persists between restarts

### Path Issues

If you have trouble mounting volumes, use absolute paths:

```yaml
volumes:
  - C:\filewizard\config:/app/config
  - C:\filewizard\uploads:/app/uploads
  - C:\filewizard\processed:/app/processed
```

Or use forward slashes:
```yaml
volumes:
  - /c/filewizard/config:/app/config
  - /c/filewizard/uploads:/app/uploads
```

## CUDA on Windows

For GPU support on Windows:

1. Install **NVIDIA drivers** for Windows
2. **NVIDIA Container Toolkit** is included with Docker Desktop
3. In `docker-compose.yml`, uncomment the GPU section:

```yaml
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: all
          capabilities: [gpu]
```

4. Run the CUDA version:
```powershell
docker compose --profile cuda up -d
```

## Container Management

```powershell
# Start
docker compose up -d

# Stop
docker compose down

# View logs
docker compose logs -f

# Restart
docker compose restart

# Cleanup (data will be preserved in volumes)
docker compose down --volumes  # This will delete volumes!
```

## Update

```powershell
# Stop current version
docker compose down

# Pull new version
docker pull loredcast/filewizard:latest

# Run new version
docker compose up -d

# Or rebuild locally
docker compose build --no-cache
docker compose up -d
```

## Troubleshooting

### Error: "Bind for 0.0.0.0:6969 failed: port is already allocated"
Port 6969 is already in use. Change the port in `docker-compose.yml`:
```yaml
ports:
  - "8080:8000"  # Use a different port
```

### Volume mounting errors
Ensure Docker Desktop has access to the drive:
1. Open Docker Desktop Settings
2. Go to Resources → File Sharing
3. Add the drive (usually C:)

### Container won't start
Check logs:
```powershell
docker compose logs web
```

### Memory issues
Increase memory limit in Docker Desktop:
1. Settings → Resources
2. Increase Memory (4GB+ recommended)

### Slow file operations
Use named volumes instead of bind mounts:
```yaml
volumes:
  - uploads_data:/app/uploads
  - processed_data:/app/processed

volumes:
  uploads_data: {}
  processed_data: {}
```

## Differences from Linux

| Feature | Windows | Linux |
|---------|---------|-------|
| Docker Engine | Docker Desktop (WSL2/Hyper-V) | Native |
| Volume Mounting | Requires File Sharing setup | Works out of the box |
| Performance | Slightly lower due to virtualization | Native |
| GPU/CUDA | Requires NVIDIA Container Toolkit | Requires nvidia-docker2 |

## Alternative: WSL2

For better performance, you can run File Wizard directly in WSL2:

```powershell
# Open WSL2 terminal
wsl

# Inside WSL2
cd /mnt/c/Users/yourname/filewizard-win
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
./run.sh
```

This gives near-native Linux performance.

## Additional Resources

- Docker Desktop: https://docs.docker.com/desktop/
- Docker on Windows: https://docs.docker.com/desktop/wsl/
- WSL2: https://learn.microsoft.com/en-us/windows/wsl/
