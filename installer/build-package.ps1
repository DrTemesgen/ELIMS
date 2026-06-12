# Assembles the deployable runtime payload into dist\payload from the
# OpenELIS-Global-2 clone + this repo's config and scripts.
# Target PCs get only this payload (~1 MB) - never the full source tree.
$ErrorActionPreference = "Stop"
$repo  = Split-Path $PSScriptRoot -Parent
$clone = Join-Path $repo "OpenELIS-Global-2"
$dist  = Join-Path $repo "dist\payload"

if (-not (Test-Path (Join-Path $clone "docker-compose.yml"))) {
    Write-Error "OpenELIS-Global-2 clone not found - see README Quick start."
}

if (Test-Path $dist) { Remove-Item $dist -Recurse -Force }
New-Item -ItemType Directory -Force $dist | Out-Null

# Compose files: upstream as-is + our port override
Copy-Item (Join-Path $clone "docker-compose.yml") $dist
Copy-Item (Join-Path $repo "deployment\docker-compose.override.yml") $dist

# Runtime config tree referenced by the compose file
Copy-Item (Join-Path $clone "volume") (Join-Path $dist "volume") -Recurse
New-Item -ItemType Directory -Force (Join-Path $dist "configuration") | Out-Null
"" | Out-File -Encoding ascii (Join-Path $dist "configuration\.keep")

# License/attribution notice ships with every installed copy
Copy-Item (Join-Path $repo "NOTICE.md") $dist

# Operating scripts + installer logic
Copy-Item (Join-Path $repo "scripts") (Join-Path $dist "scripts") -Recurse
New-Item -ItemType Directory -Force (Join-Path $dist "installer") | Out-Null
Copy-Item (Join-Path $repo "installer\install-elims.ps1") (Join-Path $dist "installer")

$size = "{0:N2} MB" -f ((Get-ChildItem $dist -Recurse -File | Measure-Object Length -Sum).Sum / 1MB)
Write-Host "Payload assembled at $dist ($size)"
