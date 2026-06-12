#!/bin/bash
BASE="https://localhost:9443/api/OpenELIS-Global"
C=/tmp/elims-cookies.txt
curl -sk "$BASE/rest/SamplePatientEntry" -b $C > /tmp/form.json
echo "=== top-level keys:"
jq -r 'keys[]' /tmp/form.json
echo "=== patientProperties keys:"
jq -r '.patientProperties | keys[]' /tmp/form.json | tr '\n' ' '
echo
echo "=== patientProperties defaults (non-empty):"
jq -r '.patientProperties | to_entries[] | select((.value != "" and .value != null and .value != []) ) | "\(.key)=\(.value)"' /tmp/form.json 2>/dev/null | head -20
echo "=== sampleOrderItems selected:"
jq -r '.sampleOrderItems | {labNo, requestDate, receivedDateForDisplay, receivedTime, currentDate, priority, newRequesterName}' /tmp/form.json
echo "=== currentDate/time at top:"
jq -r '{currentDate: .currentDate, currentTime: .currentTime}' /tmp/form.json
echo "=== generate accession:"
curl -sk "$BASE/rest/SampleEntryGenerateScanProvider" -b $C
echo
