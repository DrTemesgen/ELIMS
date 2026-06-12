#!/bin/bash
# Seed remaining demo patients + orders. Patient 1 (Abebe Bekele) already created.
BASE="https://localhost:9443/api/OpenELIS-Global"
C=/tmp/elims-cookies.txt
rm -f $C
curl -sk -X POST "$BASE/ValidateLogin?apiCall=true" -H "Content-Type: application/x-www-form-urlencoded" -c $C -d "loginName=admin&password=${ELIMS_ADMIN_PW:-adminADMIN!}" > /dev/null
CSRF=$(curl -sk "$BASE/session" -b $C | jq -r '.csrf')
TODAY=$(date +%d/%m/%Y)

seed() { # first last gender dob natId phone sampleTypeId tests time
  local FIRST=$1 LAST=$2 GENDER=$3 DOB=$4 NATID=$5 PHONE=$6 STYPE=$7 TESTS=$8 TIME=$9
  local LABNO=$(curl -sk "$BASE/rest/SampleEntryGenerateScanProvider" -b $C | jq -r '.body')
  local XML="<?xml version=\"1.0\" encoding=\"utf-8\"?><samples><sample sampleID='$STYPE' date='$TODAY' time='$TIME' collector='' quantity='' uom='' tests='$TESTS' testSectionMap='' testSampleTypeMap='' panels='' rejected='false' rejectReasonId='' initialConditionIds='' storageLocationId='' storageLocationType='' storagePositionCoordinate='' gpsLatitude='' gpsLongitude='' gpsAccuracy='' gpsCaptureMethod='' collectionMethod='' sampleTemperature='' specimenOrigin='' numOrderLabels='1' numSpecimenLabels='1'/></samples>"
  jq -n --arg xml "$XML" --arg labno "$LABNO" --arg today "$TODAY" \
        --arg first "$FIRST" --arg last "$LAST" --arg gender "$GENDER" \
        --arg dob "$DOB" --arg natid "$NATID" --arg phone "$PHONE" --arg time "$TIME" '{
    rememberSiteAndRequester: false,
    patientUpdateStatus: "ADD",
    currentDate: $today,
    sampleXML: $xml,
    useReferral: false,
    referralItems: [],
    patientProperties: {
      currentDate: $today, patientLastUpdated: "", personLastUpdated: "",
      patientUpdateStatus: "ADD",
      patientPK: "", subjectNumber: "", nationalId: $natid, guid: "",
      lastName: $last, firstName: $first,
      streetAddress: "", city: "Addis Ababa", commune: "",
      gender: $gender, birthDateForDisplay: $dob,
      patientType: "", insuranceNumber: "", occupation: "",
      primaryPhone: $phone, email: "",
      healthRegion: "", education: "", maritialStatus: "", nationality: "",
      healthDistrict: "", otherNationality: "",
      patientContact: { person: { lastName: "", firstName: "", email: "", primaryPhone: "" } },
      readOnly: false
    },
    sampleOrderItems: {
      newRequesterName: "", orderTypes: [], orderType: "", externalOrderNumber: "",
      labNo: $labno, requestDate: $today, receivedDateForDisplay: $today, receivedTime: $time,
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
      priorityList: [], priority: "ROUTINE", programId: "", isEQASample: false
    }
  }' > /tmp/order.json
  local CODE=$(curl -sk -o /tmp/orderresp.json -w "%{http_code}" -X POST "$BASE/rest/SamplePatientEntry" \
    -H "Content-Type: application/json" -H "X-CSRF-Token: $CSRF" -b $C -d @/tmp/order.json)
  echo "$FIRST $LAST -> $LABNO http:$CODE $(head -c 120 /tmp/orderresp.json)"
}

# Serum chemistry: ALAT(1), ASAT(2), Creatinine(4), Cholesterol(7) | Whole blood CBC: WBC(13), Hgb(15), Hct(16), Plt(20)
seed Almaz   Tesfaye  F 22/07/1992 ETH-1992-100002 +251911100002 2 "1,2,4,7"   08:42
seed Kebede  Alemu    M 03/01/1958 ETH-1958-100003 +251911100003 2 "1,2,4,7"   09:05
seed Hiwot   Girma    F 11/11/2001 ETH-2001-100004 +251911100004 4 "13,15,16,20" 09:18
seed Mulu    Haile    F 09/05/1976 ETH-1976-100005 +251911100005 4 "13,15,16,20" 09:47
seed Tadesse Lemma    M 28/02/1969 ETH-1969-100006 +251911100006 2 "1,2,4,7"   10:11
seed Sara    Mohammed F 14/09/1995 ETH-1995-100007 +251911100007 4 "13,15,16,20" 10:32
seed Yonas   Worku    M 30/12/1988 ETH-1988-100008 +251911100008 2 "1,2,4"     10:55
