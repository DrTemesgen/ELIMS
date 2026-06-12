#!/bin/bash
# Probe: wait for webapp, login, fetch CSRF, list sample types
BASE="https://localhost:9443/api/OpenELIS-Global"
C=/tmp/elims-cookies.txt
rm -f $C

for i in $(seq 1 60); do
  code=$(curl -sk -o /dev/null -w "%{http_code}" "$BASE/LoginPage")
  if [ "$code" = "200" ]; then echo "webapp ready (waited $((i*5))s)"; break; fi
  sleep 5
done
[ "$code" != "200" ] && echo "webapp not ready, last code $code" && exit 1

echo "--- login:"
curl -sk -X POST "$BASE/ValidateLogin?apiCall=true" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -c $C -d "loginName=admin&password=${ELIMS_ADMIN_PW:-adminADMIN!}" | head -c 300
echo

echo "--- session:"
curl -sk "$BASE/session" -b $C -c $C | head -c 400
echo

CSRF=$(curl -sk "$BASE/session" -b $C | jq -r '.csrf // empty')
echo "--- csrf: $CSRF"

echo "--- user sample types (first 600 chars):"
curl -sk "$BASE/rest/user-sample-types" -b $C | head -c 600
echo
