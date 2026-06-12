# Builds ELIMS-Setup.exe: assembles the payload, then compiles the Inno script.
$ErrorActionPreference = "Stop"
& (Join-Path $PSScriptRoot "build-package.ps1")

$iscc = @(
    "C:\Program Files (x86)\Inno Setup 6\ISCC.exe",
    "C:\Program Files\Inno Setup 6\ISCC.exe",
    "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $iscc) { Write-Error "Inno Setup not found - install with: winget install JRSoftware.InnoSetup" }

& $iscc (Join-Path $PSScriptRoot "elims.iss")
if ($LASTEXITCODE -ne 0) { Write-Error "Inno Setup compilation failed." }
$exe = Join-Path (Split-Path $PSScriptRoot -Parent) "dist\ELIMS-Setup.exe"
Write-Host ""
Write-Host "Installer built: $exe ($("{0:N2} MB" -f ((Get-Item $exe).Length / 1MB)))" -ForegroundColor Green
