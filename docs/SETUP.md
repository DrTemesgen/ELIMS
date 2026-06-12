# Workstation setup notes

How the ELIMS dev/demo environment was set up on the project workstation
(Windows 11 Pro + WSL2 Ubuntu 24.04), June 2026.

## Docker (no Docker Desktop)

Docker Engine runs **inside WSL Ubuntu**, installed from the Ubuntu archive:

```bash
# inside WSL as root
apt-get update
apt-get install -y docker.io docker-compose-v2
```

systemd starts `dockerd` automatically whenever WSL is running. From Windows,
manage it as:

```powershell
wsl -u root -- docker ps
```

## Port conflicts

The WSL Ubuntu instance also runs Apache, which occupies host ports
**80, 443, 8080, 8443**. OpenELIS is therefore remapped via
[`deployment/docker-compose.override.yml`](../deployment/docker-compose.override.yml):

| Service | Default | Here |
|---|---|---|
| nginx proxy HTTPS (main UI) | 443 | **9443** |
| nginx proxy HTTP redirect | 80 | 8090 |
| webapp direct | 8080 / 8443 | 8082 / 8445 |

## Operating the stack

```powershell
scripts\start-elims.ps1    # start everything
scripts\stop-elims.ps1     # stop (data persists in volume openelis-global-2_db-data)
scripts\status-elims.ps1   # container status + UI health check
```

UI: **https://localhost:9443** (self-signed cert). First boot after a fresh
database runs schema migrations and takes several minutes.

## Gotchas learned the hard way

- A `docker compose up` aborted by a port conflict can leave a container
  created but **attached to no network** (nginx then fails with
  "host not found in upstream"). Fix: `docker compose down && docker compose up -d --force-recreate`.
- Shell scripts edited on Windows carry CRLF line endings; run them in WSL as
  `tr -d '\r' < script.sh | bash`.
- On unreliable networks, prefer `git clone --depth 1` and `docker compose pull`
  (resumable per layer) over full clones.
