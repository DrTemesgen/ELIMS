# ELIMS — Electronic Laboratory Information Management System

An open-source laboratory information management system built on
[OpenELIS Global 2](https://github.com/DIGI-UW/OpenELIS-Global-2) — the open-source,
enterprise-grade LIS used by public health laboratories worldwide.

> **Status:** 🟢 Active development — running as a local deployment (demo/evaluation phase).
> The live system is hosted on the project workstation and is available when it is online.
> Cloud hosting for a public showcase is planned.

## What this is

| Layer | Technology |
|---|---|
| LIS core | OpenELIS Global 2 (`develop` images) — Java 21 / Spring / Tomcat |
| Frontend | React + IBM Carbon |
| Database | PostgreSQL |
| Interoperability | HL7 FHIR R4 (HAPI FHIR server) |
| Deployment | Docker Compose (6 services) on WSL2 Ubuntu / Linux |

This repository holds the **project-specific configuration, deployment scripts, and
documentation** — not the OpenELIS source itself, which is tracked separately against
the upstream repo (cloned into `OpenELIS-Global-2/`, git-ignored here).

## Repository layout

```
ELIMS/
├── OpenELIS-Global-2/    ← upstream clone (git-ignored; clone it yourself, see below)
├── deployment/           ← our compose overrides & deployment config
├── scripts/              ← start / stop / status helpers (Windows + WSL)
├── docs/                 ← setup notes and project documentation
└── README.md
```

## Quick start

1. Clone the upstream LIS next to this README:
   ```
   git clone --depth 1 --recurse-submodules --shallow-submodules https://github.com/DIGI-UW/OpenELIS-Global-2.git
   ```
2. Copy our override into it:
   ```
   copy deployment\docker-compose.override.yml OpenELIS-Global-2\
   ```
3. Start (requires Docker in WSL2 — see [docs/SETUP.md](docs/SETUP.md)):
   ```
   scripts\start-elims.ps1
   ```
4. Open **https://localhost:9443** (self-signed certificate — accept the warning).

Default credentials are OpenELIS defaults — change them before any real use.

## 📥 Download

| Flavor | Size | Internet during install | Get it |
|---|---|---|---|
| **Lean installer** | 2 MB | Yes — downloads ~1.9 GB | [GitHub release v0.1.0](https://github.com/DrTemesgen/ELIMS/releases/tag/v0.1.0) |
| **Offline / USB bundle** | 1.9 GB | **None** | [Google Drive folder](https://drive.google.com/drive/folders/1sDvfEBUW4uRrJWk_jAm-BZUIYgX7rZ2j?usp=sharing) |

Access to the offline bundle follows the project's sharing policy on the Drive
folder. Prerequisite on every target PC: WSL2 with Ubuntu — one command + reboot,
see [docs/INSTALLER.md](docs/INSTALLER.md).

## Windows installer

ELIMS packages as a normal Windows application: `ELIMS-Setup.exe` installs the
whole system (Docker-based) with Start Menu icons, runs fully offline, and
updates itself when internet is available. An offline USB bundle carries the
~5.5 GB of images for zero-internet installs. See [docs/INSTALLER.md](docs/INSTALLER.md).

```powershell
installer\build-installer.ps1        # build dist\ELIMS-Setup.exe (~2 MB)
installer\build-offline-bundle.ps1   # build dist\offline\ USB bundle (~5.5 GB)
```

## Roadmap

- [x] Stand up OpenELIS Global 2 locally (Docker-in-WSL2)
- [x] Windows installer (lean + offline USB bundle), update mechanism
- [ ] Demo dataset (fictional patients, realistic results)
- [ ] Test catalog & lab sections for the target laboratory profile
- [ ] Branding, report formats, localization
- [ ] Analyzer interfacing (via OpenELIS plugins / analyzer bridge)
- [ ] Cloud hosting + domain + TLS for the public showcase

## License

Configuration and scripts in this repo: MIT. OpenELIS Global 2 itself is
[MPL-2.0](https://github.com/DIGI-UW/OpenELIS-Global-2/blob/develop/LICENSE.md),
© the OpenELIS Global project / University of Washington DIGI.
