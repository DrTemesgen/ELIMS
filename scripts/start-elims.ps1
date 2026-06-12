# Starts the ELIMS (OpenELIS Global 2) stack in WSL Docker.
$repo = Join-Path (Split-Path $PSScriptRoot -Parent) "OpenELIS-Global-2"
if (-not (Test-Path (Join-Path $repo "docker-compose.yml"))) {
    Write-Error "OpenELIS-Global-2 clone not found at $repo — see README Quick start."
    exit 1
}
$wslPath = ("/mnt/" + $repo.Substring(0,1).ToLower() + ($repo.Substring(2) -replace '\\','/'))
wsl -u root -- bash -c "cd '$wslPath' && docker compose up -d"
Write-Host ""
Write-Host "ELIMS starting. First boot takes a few minutes; then open https://localhost:9443"
