# ELIMS launcher - starts the stack and opens the browser when the UI is ready.
# Works both in the dev repo (compose lives in OpenELIS-Global-2\) and in an
# installed payload (compose lives next to this script's parent folder).
$root = Split-Path $PSScriptRoot -Parent
$compose = if (Test-Path (Join-Path $root "docker-compose.yml")) { $root } else { Join-Path $root "OpenELIS-Global-2" }
if (-not (Test-Path (Join-Path $compose "docker-compose.yml"))) {
    Write-Error "docker-compose.yml not found under $root"; exit 1
}
$wslPath = "/mnt/" + $compose.Substring(0,1).ToLower() + ($compose.Substring(2) -replace '\\','/')

Write-Host "Starting ELIMS..." -ForegroundColor Cyan
wsl -u root -- bash -c "(systemctl start docker 2>/dev/null || service docker start); cd '$wslPath' && docker compose up -d"
if (-not $?) { Write-Error "Failed to start the ELIMS containers."; exit 1 }

Write-Host "Waiting for the user interface (first start can take several minutes)..."
$up = $false
for ($i = 0; $i -lt 90; $i++) {
    $code = & curl.exe -sk -o NUL -w "%{http_code}" https://localhost:9443/
    if ($code -eq "200") { $up = $true; break }
    Start-Sleep -Seconds 5
}
if ($up) {
    Write-Host "ELIMS is ready - opening https://localhost:9443" -ForegroundColor Green
    Start-Process "https://localhost:9443"
} else {
    Write-Warning "UI did not respond yet. Containers may still be initializing - try https://localhost:9443 in a few minutes, or run scripts\status-elims.ps1"
}
