#!/bin/bash
# List tests for serum (2) and whole blood (4)
BASE="https://localhost:9443/api/OpenELIS-Global"
C=/tmp/elims-cookies.txt
echo "=== SERUM (2):"
curl -sk "$BASE/rest/sample-type-tests?sampleType=2" -b $C | jq -r '.tests[]? | "\(.id) \(.name)"' | head -30
echo "=== WHOLE BLOOD (4):"
curl -sk "$BASE/rest/sample-type-tests?sampleType=4" -b $C | jq -r '.tests[]? | "\(.id) \(.name)"' | head -30
echo "=== raw shape (serum, first 300):"
curl -sk "$BASE/rest/sample-type-tests?sampleType=2" -b $C | head -c 300
