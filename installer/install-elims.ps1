# ELIMS target-PC installer logic. Idempotent - safe to re-run.
# Called by the Inno Setup installer after files are copied, or run manually:
#   powershell -ExecutionPolicy Bypass -File install-elims.ps1 [-ImagesTar <path>]
param(
    [string]$ImagesTar = ""
)
$ErrorActionPreference = "Stop"
$app = Split-Path $PSScriptRoot -Parent   # payload root (contains docker-compose.yml)

function Fail($msg) { Write-Host ""; Write-Host "INSTALL BLOCKED: $msg" -ForegroundColor Red; exit 1 }

Write-Host "=== ELIMS installer ===" -ForegroundColor Cyan

# 1. WSL2 present with a distro?
$distros = @()
try { $distros = (wsl -l -q) -replace "`0", "" | Where-Object { $_ -and $_.Trim() } } catch {}
if (-not $distros) {
    Fail @"
WSL2 with a Linux distribution is required but was not found.
Open PowerShell AS ADMINISTRATOR, run:  wsl --install -d Ubuntu-24.04
restart the computer, then run this installer again.
"@
}
Write-Host "[1/5] WSL distro found: $($distros[0])"

# 2. Docker Engine inside WSL
Write-Host "[2/5] Ensuring Docker Engine in WSL (installs on first run)..."
wsl -u root -- bash -c "command -v docker >/dev/null || (apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y docker.io docker-compose-v2)"
if (-not $?) { Fail "Could not install Docker inside WSL. Check the internet connection and re-run." }
wsl -u root -- bash -c "systemctl start docker 2>/dev/null || service docker start; docker info >/dev/null"
if (-not $?) { Fail "Docker daemon did not start inside WSL." }

# 3. Images: load from offline bundle if available, else pull online
$wslApp = "/mnt/" + $app.Substring(0,1).ToLower() + ($app.Substring(2) -replace '\\','/')
if (-not $ImagesTar) {
    # offline bundle convention: images.tar sitting next to the setup exe / payload
    $candidate = Join-Path $app "images.tar"
    if (Test-Path $candidate) { $ImagesTar = $candidate }
}
if ($ImagesTar -and (Test-Path $ImagesTar)) {
    Write-Host "[3/5] Loading Docker images from offline bundle (no internet needed)..."
    $wslTar = "/mnt/" + $ImagesTar.Substring(0,1).ToLower() + ($ImagesTar.Substring(2) -replace '\\','/')
    wsl -u root -- bash -c "docker load -i '$wslTar'"
    if (-not $?) { Fail "Failed to load images from $ImagesTar" }
} else {
    Write-Host "[3/5] No offline bundle found - pulling images from Docker Hub (several GB)..."
    wsl -u root -- bash -c "cd '$wslApp' && docker compose pull"
    if (-not $?) { Fail "Image download failed. Use the offline bundle on slow connections." }
}

# 4. Start the stack
Write-Host "[4/5] Starting ELIMS..."
wsl -u root -- bash -c "cd '$wslApp' && docker compose up -d"
if (-not $?) { Fail "docker compose up failed." }

# 5. Done
Write-Host "[5/5] ELIMS installed. First start initializes the database (several minutes)." -ForegroundColor Green
Write-Host "      Open https://localhost:9443 - or use the ELIMS icon in the Start Menu."
exit 0
