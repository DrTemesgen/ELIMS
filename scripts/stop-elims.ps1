# Stops the ELIMS (OpenELIS Global 2) stack. Database data persists in the docker volume.
$repo = Join-Path (Split-Path $PSScriptRoot -Parent) "OpenELIS-Global-2"
$wslPath = ("/mnt/" + $repo.Substring(0,1).ToLower() + ($repo.Substring(2) -replace '\\','/'))
wsl -u root -- bash -c "cd '$wslPath' && docker compose down"
Write-Host "ELIMS stopped."
