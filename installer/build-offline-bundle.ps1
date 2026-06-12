# Produces the USB-ready offline bundle in dist\offline\:
#   ELIMS-Setup.exe  (built first if missing)
#   images.tar       (~5.5 GB - all six Docker images, exported from local Docker)
#   README.txt
# Run on a machine where the images are already pulled (this dev workstation).
$ErrorActionPreference = "Stop"
$repo = Split-Path $PSScriptRoot -Parent
$out  = Join-Path $repo "dist\offline"

$setup = Join-Path $repo "dist\ELIMS-Setup.exe"
if (-not (Test-Path $setup)) { & (Join-Path $PSScriptRoot "build-installer.ps1") }

New-Item -ItemType Directory -Force $out | Out-Null
Copy-Item $setup $out -Force

$images = @(
    "itechuw/openelis-global-2:develop",
    "itechuw/openelis-global-2-database:develop",
    "itechuw/openelis-global-2-fhir:develop",
    "itechuw/openelis-global-2-frontend:develop",
    "itechuw/openelis-global-2-proxy:develop",
    "itechuw/certgen:main"
)
$tarWin = Join-Path $out "images.tar"
$tarWsl = "/mnt/" + $tarWin.Substring(0,1).ToLower() + ($tarWin.Substring(2) -replace '\\','/')
Write-Host "Exporting $($images.Count) images to images.tar (several GB, takes a while)..."
wsl -u root -- bash -c "docker save -o '$tarWsl' $($images -join ' ')"
if (-not $? -or -not (Test-Path $tarWin)) { Write-Error "docker save failed - are all images pulled locally?" }

@"
ELIMS offline installer bundle
==============================
1. Ensure the PC has WSL2 with Ubuntu (PowerShell as Administrator):
     wsl --install -d Ubuntu-24.04
   then restart the computer. (Skip if WSL Ubuntu already exists.)
2. Keep ELIMS-Setup.exe and images.tar in the SAME folder.
3. Run ELIMS-Setup.exe. No internet connection is required.
4. After install, use the ELIMS icon in the Start Menu.
   The web address is https://localhost:9443

Project: https://github.com/DrTemesgen/ELIMS
"@ | Out-File -Encoding ascii (Join-Path $out "README.txt")

Write-Host "Offline bundle ready at $out ($("{0:N2} GB" -f ((Get-ChildItem $out | Measure-Object Length -Sum).Sum / 1GB)))" -ForegroundColor Green
