#!/bin/bash
# Validate (accept) all results on the seeded orders
BASE="https://localhost:9443/api/OpenELIS-Global"
C=/tmp/elims-cookies.txt
rm -f $C
curl -sk -X POST "$BASE/ValidateLogin?apiCall=true" -H "Content-Type: application/x-www-form-urlencoded" -c $C -d "loginName=admin&password=${ELIMS_ADMIN_PW:-adminADMIN!}" > /dev/null
CSRF=$(curl -sk "$BASE/session" -b $C | jq -r '.csrf')

for N in 2 3 4 5 6 7 8 9; do
  ACC="DEV0126000000000000$N"
  curl -sk "$BASE/rest/AccessionValidation?accessionNumber=$ACC&unitType=&date=&doRange=false" -b $C > /tmp/v.json
  CNT=$(jq '.resultList | length' /tmp/v.json)
  if [ "$CNT" = "0" ] || [ "$CNT" = "null" ]; then echo "$ACC: nothing to validate"; continue; fi
  jq '.resultList |= map(.isAccepted = true)' /tmp/v.json > /tmp/vsave.json
  CODE=$(curl -sk -o /tmp/vresp.json -w "%{http_code}" -X POST "$BASE/rest/AccessionValidation" \
    -H "Content-Type: application/json" -H "X-CSRF-Token: $CSRF" -b $C -d @/tmp/vsave.json)
  echo "$ACC: $CNT validated -> http:$CODE $(head -c 80 /tmp/vresp.json)"
done
