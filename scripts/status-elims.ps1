# Shows ELIMS container status and checks the UI.
wsl -u root -- docker ps --format "{{.Names}}: {{.Status}}"
$code = & curl.exe -sk -o NUL -w "%{http_code}" https://localhost:9443/
Write-Host "UI https://localhost:9443 -> HTTP $code"
