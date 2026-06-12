#!/bin/bash
# Create ONE demo patient + order end-to-end, verbose, to validate the payload.
BASE="https://localhost:9443/api/OpenELIS-Global"
C=/tmp/elims-cookies.txt

# fresh login
rm -f $C
curl -sk -X POST "$BASE/ValidateLogin?apiCall=true" -H "Content-Type: application/x-www-form-urlencoded" -c $C -d "loginName=admin&password=${ELIMS_ADMIN_PW:-adminADMIN!}" > /dev/null
CSRF=$(curl -sk "$BASE/session" -b $C | jq -r '.csrf')
TODAY=$(date +%d/%m/%Y)

LABNO=$(curl -sk "$BASE/rest/SampleEntryGenerateScanProvider" -b $C | jq -r '.body')
echo "labNo: $LABNO  date: $TODAY"

XML="<?xml version=\"1.0\" encoding=\"utf-8\"?><samples><sample sampleID='2' date='$TODAY' time='09:15' collector='' quantity='' uom='' tests='1,2,4,7' testSectionMap='' testSampleTypeMap='' panels='' rejected='false' rejectReasonId='' initialConditionIds='' storageLocationId='' storageLocationType='' storagePositionCoordinate='' gpsLatitude='' gpsLongitude='' gpsAccuracy='' gpsCaptureMethod='' collectionMethod='' sampleTemperature='' specimenOrigin='' numOrderLabels='1' numSpecimenLabels='1'/></samples>"

jq -n --arg xml "$XML" --arg labno "$LABNO" --arg today "$TODAY" '{
  patientUpdateStatus: "ADD",
  currentDate: $today,
  sampleXML: $xml,
  useReferral: false,
  referralItems: [],
  patientProperties: {
    currentDate: $today,
    patientLastUpdated: "", personLastUpdated: "",
    patientUpdateStatus: "ADD",
    patientPK: "", subjectNumber: "", nationalId: "ETH-1990-100001",
    guid: "", lastName: "Bekele", firstName: "Abebe",
    streetAddress: "Bole Road 12", city: "Addis Ababa", commune: "",
    gender: "M", birthDateForDisplay: "15/03/1985",
    patientType: "", insuranceNumber: "", occupation: "",
    primaryPhone: "+251911100001", email: "",
    healthRegion: "", education: "", maritialStatus: "", nationality: "",
    healthDistrict: "", otherNationality: "",
    patientContact: { person: { lastName: "", firstName: "", email: "", primaryPhone: "" } },
    readOnly: false
  },
  sampleOrderItems: {
    newRequesterName: "", orderTypes: [], orderType: "", externalOrderNumber: "",
    labNo: $labno,
    requestDate: $today, receivedDateForDisplay: $today, receivedTime: "09:20",
    nextVisitDate: "", requesterSampleID: "", referringPatientNumber: "",
    referringSiteId: "", referringSiteDepartmentId: "", referringSiteCode: "",
    referringSiteName: "", referringSiteDepartmentName: "",
    referringSiteList: [], referringSiteDepartmentList: [], providersList: [],
    providerId: "", providerPersonId: "", providerFirstName: "Demo", providerLastName: "Clinician",
    providerWorkPhone: "", providerFax: "", providerEmail: "",
    facilityAddressStreet: "", facilityAddressCommune: "", facilityPhone: "", facilityFax: "",
    paymentOptionSelection: "", paymentOptions: [], modified: true, sampleId: "",
    readOnly: false, billingReferenceNumber: "", testLocationCode: "", otherLocationCode: "",
    testLocationCodeList: [], program: "", programList: [],
    contactTracingIndexName: "", contactTracingIndexRecordNumber: "",
    priorityList: [], priority: "ROUTINE", programId: "",
    isEQASample: false
  }
}' > /tmp/order1.json

echo "--- POST response:"
curl -sk -X POST "$BASE/rest/SamplePatientEntry" \
  -H "Content-Type: application/json" -H "X-CSRF-Token: $CSRF" \
  -b $C -d @/tmp/order1.json
echo
