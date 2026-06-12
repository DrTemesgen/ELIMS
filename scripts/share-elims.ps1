# Exposes the local ELIMS to the internet via a Cloudflare quick tunnel.
# A random https://*.trycloudflare.com URL is printed below - share it; it works
# as long as this window stays open and the local stack is running.
# NOTE: anyone with the URL can reach the login page. Do not use default passwords.
$cf = "C:\Program Files (x86)\cloudflared\cloudflared.exe"
if (-not (Test-Path $cf)) { Write-Error "cloudflared not found - install with: winget install Cloudflare.cloudflared"; exit 1 }
& $cf tunnel --url https://localhost:9443 --no-tls-verify
