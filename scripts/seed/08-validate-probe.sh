#!/bin/bash
BASE="https://localhost:9443/api/OpenELIS-Global"
C=/tmp/elims-cookies.txt
ACC="DEV01260000000000002"
curl -sk "$BASE/rest/AccessionValidation?accessionNumber=$ACC&unitType=&date=&doRange=false" -b $C > /tmp/v.json
echo "top keys:"; jq -r 'keys[]' /tmp/v.json | tr '\n' ' '; echo
echo "resultList count: $(jq '.resultList | length' /tmp/v.json)"
echo "--- first row keys:"
jq -r '.resultList[0] | keys[]' /tmp/v.json 2>/dev/null | tr '\n' ' '; echo
echo "--- first row selected:"
jq '.resultList[0] | {testName, result, accepted: .accepted, isAccepted: .isAccepted, rejected: .rejected, isRejected: .isRejected, valid: .valid, id, analysisId: .analysisId}' /tmp/v.json 2>/dev/null
