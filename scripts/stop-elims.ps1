# Stops the ELIMS (OpenELIS Global 2) stack. Database data persists in the docker volume.
$root = Split-Path $PSScriptRoot -Parent
$compose = if (Test-Path (Join-Path $root "docker-compose.yml")) { $root } else { Join-Path $root "OpenELIS-Global-2" }
$wslPath = "/mnt/" + $compose.Substring(0,1).ToLower() + ($compose.Substring(2) -replace '\\','/')
wsl -u root -- bash -c "cd '$wslPath' && docker compose down"
Write-Host "ELIMS stopped."
