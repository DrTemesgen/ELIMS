#!/bin/bash
BASE="https://localhost:9443/api/OpenELIS-Global"
C=/tmp/elims-cookies.txt
ACC="DEV01260000000000002"
curl -sk "$BASE/rest/LogbookResults?labNumber=$ACC&doRange=false&finished=true" -b $C > /tmp/results.json
echo "top keys:"; jq -r 'keys[]' /tmp/results.json | tr '\n' ' '; echo
echo "testResult count: $(jq '.testResult | length' /tmp/results.json)"
echo "--- first row (selected fields):"
jq '.testResult[0] | {id, testName, accessionNumber, analysisId: .analysisId, resultValue, resultType, units, testId, reportable, lowNormal: .lowerNormalRange, upperNormalRange, resultId: .resultId, sequenceNumber: .analysisSequenceNumber}' /tmp/results.json
echo "--- all row keys:"
jq -r '.testResult[0] | keys[]' /tmp/results.json | tr '\n' ' '; echo
echo "--- all tests in this order:"
jq -r '.testResult[] | "\(.testName) [\(.resultType)] units=\(.units)"' /tmp/results.json
