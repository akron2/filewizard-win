# File Wizard Windows Launcher (PowerShell)
# This script starts the FastAPI server and Huey task queue worker

Write-Host "========================================"
Write-Host "File Wizard - Windows Launcher"
Write-Host "========================================"
Write-Host ""

# Load environment variables from .env file if it exists
$envFile = ".env"
if (Test-Path $envFile) {
    Write-Host "Loading environment variables from $envFile..."
    Get-Content $envFile | ForEach-Object {
        $line = $_.Trim()
        if ($line -and $line -notmatch "^#") {
            $key, $value = $line.Split("=", 2)
            if ($key -and $value) {
                $value = $value.Trim('"').Trim("'")
                [Environment]::SetEnvironmentVariable($key, $value, "Process")
            }
        }
    }
    Write-Host "Environment loaded."
    Write-Host ""
}

# Set default values if not already set
if (-not $env:SECRET_KEY) {
    Write-Host "Generating random SECRET_KEY..."
    $bytes = New-Object byte[] 32
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $rng.GetBytes($bytes)
    $env:SECRET_KEY = [System.BitConverter]::ToString($bytes).Replace("-","").ToLower()
}

if (-not $env:UPLOADS_DIR) { $env:UPLOADS_DIR = ".\uploads" }
if (-not $env:PROCESSED_DIR) { $env:PROCESSED_DIR = ".\processed" }
if (-not $env:CHUNK_TMP_DIR) { $env:CHUNK_TMP_DIR = ".\uploads\tmp" }
if (-not $env:LOCAL_ONLY) { $env:LOCAL_ONLY = "True" }

Write-Host "Starting File Wizard with configuration:"
Write-Host "  UPLOADS_DIR=$($env:UPLOADS_DIR)"
Write-Host "  PROCESSED_DIR=$($env:PROCESSED_DIR)"
Write-Host "  CHUNK_TMP_DIR=$($env:CHUNK_TMP_DIR)"
Write-Host "  LOCAL_ONLY=$($env:LOCAL_ONLY)"
Write-Host ""

# Create necessary directories
$dirs = @($env:UPLOADS_DIR, $env:PROCESSED_DIR, $env:CHUNK_TMP_DIR)
foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) {
        Write-Host "Creating directory: $dir"
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
}

Write-Host "========================================"
Write-Host "Starting File Wizard..."
Write-Host "========================================"
Write-Host ""

# Start Uvicorn server in a separate process
Write-Host "Starting Uvicorn web server on port 8000..."
$uvicornArgs = @{
    ScriptBlock = {
        param($localOnly, $secretKey, $uploadsDir, $processedDir, $chunkTmpDir)
        $env:LOCAL_ONLY = $localOnly
        $env:SECRET_KEY = $secretKey
        $env:UPLOADS_DIR = $uploadsDir
        $env:PROCESSED_DIR = $processedDir
        $env:CHUNK_TMP_DIR = $chunkTmpDir
        uvicorn main:app --host 0.0.0.0 --port 8000 --reload
    }
    ArgumentList = @($env:LOCAL_ONLY, $env:SECRET_KEY, $env:UPLOADS_DIR, $env:PROCESSED_DIR, $env:CHUNK_TMP_DIR)
    WindowStyle = "Normal"
}
Start-Process powershell -ArgumentList "-NoExit", "-Command", @"
`$env:LOCAL_ONLY='$($env:LOCAL_ONLY)'
`$env:SECRET_KEY='$($env:SECRET_KEY)'
`$env:UPLOADS_DIR='$($env:UPLOADS_DIR)'
`$env:PROCESSED_DIR='$($env:PROCESSED_DIR)'
`$env:CHUNK_TMP_DIR='$($env:CHUNK_TMP_DIR)'
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
"@

# Wait a moment for server to start
Start-Sleep -Seconds 3

Write-Host "Starting Huey task queue worker..."
Write-Host ""
Write-Host "========================================"
Write-Host "File Wizard is starting..."
Write-Host "Web interface: http://localhost:8000"
Write-Host "========================================"
Write-Host ""
Write-Host "Press Ctrl+C to stop the Huey worker."
Write-Host "The web server will continue running in a separate window."
Write-Host ""

# Start Huey consumer in the current process
python -c "from main import huey; from huey.consumer import Consumer; Consumer(huey, workers=4).run()"
