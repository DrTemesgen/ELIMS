#!/bin/bash
# Enter results for all seeded orders: value = midpoint of normal range (+ per-order jitter)
BASE="https://localhost:9443/api/OpenELIS-Global"
C=/tmp/elims-cookies.txt
rm -f $C
curl -sk -X POST "$BASE/ValidateLogin?apiCall=true" -H "Content-Type: application/x-www-form-urlencoded" -c $C -d "loginName=admin&password=${ELIMS_ADMIN_PW:-adminADMIN!}" > /dev/null
CSRF=$(curl -sk "$BASE/session" -b $C | jq -r '.csrf')

for N in 2 3 4 5 6 7 8 9; do
  ACC="DEV0126000000000000$N"
  curl -sk "$BASE/rest/LogbookResults?labNumber=$ACC&doRange=false&finished=true" -b $C > /tmp/r.json
  CNT=$(jq '.testResult | length' /tmp/r.json)
  if [ "$CNT" = "0" ] || [ "$CNT" = "null" ]; then echo "$ACC: no rows, skipping"; continue; fi
  jq --argjson j "$N" '
    .testResult |= map(
      .resultValue = (
        if (.lowerNormalRange != null and .upperNormalRange != null
            and (.upperNormalRange | type) == "number" and (.lowerNormalRange | type) == "number"
            and .upperNormalRange > .lowerNormalRange and .upperNormalRange < 1000000)
        then ((((.lowerNormalRange + .upperNormalRange) / 2) + (($j - 5) * (.upperNormalRange - .lowerNormalRange) / 20)) * 10 | round / 10 | tostring)
        else "12"
        end)
      | .shadowResultValue = .resultValue
      | .isModified = true
      | .reportable = true
    )' /tmp/r.json > /tmp/rsave.json
  CODE=$(curl -sk -o /tmp/rresp.json -w "%{http_code}" -X POST "$BASE/rest/LogbookResults" \
    -H "Content-Type: application/json" -H "X-CSRF-Token: $CSRF" -b $C -d @/tmp/rsave.json)
  VALS=$(jq -r '[.testResult[].resultValue] | join(",")' /tmp/rsave.json)
  echo "$ACC: $CNT results [$VALS] -> http:$CODE $(head -c 80 /tmp/rresp.json)"
done
