# ELIMS Windows installer

ELIMS ships as a normal Windows installer (`ELIMS-Setup.exe`) that turns any
Windows 10/11 PC into a self-contained lab system: it runs fully offline and
picks up software updates whenever internet is available.

## What the installer does

1. Verifies **WSL2 + Ubuntu** is present (the one prerequisite — see below)
2. Installs Docker Engine inside WSL (skipped if already there)
3. Loads the six OpenELIS Docker images — from `images.tar` if present
   (offline mode), otherwise downloaded from Docker Hub
4. Installs the runtime payload to `C:\ELIMS` and creates Start Menu icons:
   **ELIMS** (start + open browser), **Stop ELIMS**, **Update ELIMS**, **ELIMS Status**
5. Starts the system — UI at **https://localhost:9443**

## Prerequisite on target PCs (one-time)

In PowerShell **as Administrator**:

```powershell
wsl --install -d Ubuntu-24.04
```

…then restart the computer. (Requires hardware virtualization, which any
PC from the last ~10 years has.)

## Two distribution flavors

| | Lean installer | Offline bundle |
|---|---|---|
| Contents | `ELIMS-Setup.exe` (~2 MB) | `ELIMS-Setup.exe` + `images.tar` (~5.5 GB) |
| Internet needed | Yes — downloads ~5.5 GB during install | **None** |
| Best for | Well-connected sites | USB-stick deployment, poor connectivity |
| Build with | `installer\build-installer.ps1` | `installer\build-offline-bundle.ps1` |

The same `ELIMS-Setup.exe` powers both: it automatically uses `images.tar`
when the file sits next to it.

## Updates

Start Menu → **Update ELIMS** runs `docker compose pull` + restart. Only
changed image layers download, lab data is untouched (it lives in a Docker
volume, not in the images). No internet → the lab simply keeps running on
its current version.

## Data sync (prepared, not yet active)

OpenELIS Global 2 includes a FHIR R4 layer designed for exactly our target
architecture: each lab instance queues results locally and pushes them to a
central server when connectivity allows. Activation requires a central FHIR
endpoint (the planned cloud VPS) and configuration in
`volume\properties\common.properties` — to be wired up once the central
server exists.

## Building from this repo

```powershell
installer\build-installer.ps1        # -> dist\ELIMS-Setup.exe
installer\build-offline-bundle.ps1   # -> dist\offline\  (USB-ready folder)
```

Requirements on the build machine: the `OpenELIS-Global-2` clone (payload
source), Inno Setup 6 (`winget install JRSoftware.InnoSetup`), and for the
offline bundle, the Docker images pulled locally.

## Known limitations (v0.1)

- WSL2/Ubuntu must be installed manually first (one command + reboot)
- Images track the upstream `develop` tag; pinning to a tested release tag
  is planned before real lab rollout
- The default OpenELIS admin password must be changed at first login
- Installer is unsigned — Windows SmartScreen will warn; click "More info →
  Run anyway" (code signing planned)
