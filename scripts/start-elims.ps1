# Starts the ELIMS (OpenELIS Global 2) stack in WSL Docker.
$root = Split-Path $PSScriptRoot -Parent
$compose = if (Test-Path (Join-Path $root "docker-compose.yml")) { $root } else { Join-Path $root "OpenELIS-Global-2" }
if (-not (Test-Path (Join-Path $compose "docker-compose.yml"))) {
    Write-Error "docker-compose.yml not found under $root - see README Quick start."; exit 1
}
$wslPath = "/mnt/" + $compose.Substring(0,1).ToLower() + ($compose.Substring(2) -replace '\\','/')
wsl -u root -- bash -c "(systemctl start docker 2>/dev/null || service docker start); cd '$wslPath' && docker compose up -d"
Write-Host ""
Write-Host "ELIMS starting. First boot takes a few minutes; then open https://localhost:9443"
