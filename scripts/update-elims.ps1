# Updates ELIMS to the latest published images (requires internet).
# Lab data is preserved - it lives in the database volume, not the images.
$root = Split-Path $PSScriptRoot -Parent
$compose = if (Test-Path (Join-Path $root "docker-compose.yml")) { $root } else { Join-Path $root "OpenELIS-Global-2" }
$wslPath = "/mnt/" + $compose.Substring(0,1).ToLower() + ($compose.Substring(2) -replace '\\','/')

Write-Host "Checking for ELIMS updates (this downloads only what changed)..." -ForegroundColor Cyan
wsl -u root -- bash -c "cd '$wslPath' && docker compose pull && docker compose up -d && docker image prune -f"
if ($?) { Write-Host "ELIMS is up to date." -ForegroundColor Green } else { Write-Warning "Update failed - check your internet connection and try again." }
