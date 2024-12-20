#!/bin/bash

# Test the API using curl

source ./utils.sh

eko true YELLOW "Testing the API\n"

VERBOSE=$1

API_URL="http://localhost:9115/api"
AUTH_HEADER_BAD="X-OBSERVATORY-AUTH: 11111111111111"
AUTH_HEADER_GOOD="set later in the script (after login)"




# ======================= Healthcheck ======================= #
URL="$API_URL/admin/healthcheck"
eko true MAGENTA ">>> Healthcheck: $URL"
RESPONSE=$(curl -s -X GET "$URL")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '"status"'; then

    eko $VERBOSE GREEN "Field 'status' is present."

    STATUS=$(echo "$RESPONSE" | grep -oP '(?<="status":")[^"]*')
    
    if echo "$RESPONSE" | grep -q '"dbconnection"'; then
        
        eko $VERBOSE GREEN "Field 'dbconnection' is present."
        
    else
        eko true RED "Field 'dbconnection' is missing."
        exit 1
    fi

    if [ "$STATUS" = "failed" ]; then
        eko $VERBOSE YELLOW "status is FAILED"
    else
        
        if echo "$RESPONSE" | grep -q '"n_stations"'; then

            eko $VERBOSE GREEN "Field 'n_stations' is present."
            
        else
            eko true RED "Field 'n_stations' is missing."
            exit 1
        fi

        if echo "$RESPONSE" | grep -q '"n_tags"'; then

            eko $VERBOSE GREEN "Field 'n_tags' is present."
            
        else
            eko true RED "Field 'n_tags' is missing."
            exit 1
        fi

        if echo "$RESPONSE" | grep -q '"n_passes"'; then

            eko $VERBOSE GREEN "Field 'n_passes' is present."
            
        else
            eko true RED "Field 'n_passes' is missing."
            exit 1
        fi
        
    fi
else
    eko true RED "Field 'status' is missing."
    exit 1
fi
eko true GREEN "success\n"





# ======================= reset passes ======================= #
URL="$API_URL/admin/resetpasses"
eko true MAGENTA ">>> Reset Passes: $URL"
RESPONSE=$(curl -s -X POST "$URL")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '"status"'; then

    eko $VERBOSE GREEN "Field 'status' is present."

    STATUS=$(echo "$RESPONSE" | grep -oP '(?<="status":")[^"]*')

    if [ "$STATUS" = "failed" ]; then
        eko $VERBOSE YELLOW "status is FAILED"

        if echo "$RESPONSE" | grep -q '"info"'; then
            eko $VERBOSE GREEN "Field 'info' is present."            
        else
            eko true RED "Field 'info' is missing."
            exit 1
        fi        
    fi
else
    eko true RED "Field 'status' is missing."
    exit 1
fi
eko true GREEN "success\n"








# ======================= resetstations ======================= #
URL="$API_URL/admin/resetstations"
eko true MAGENTA ">>> resetstations: $URL"
RESPONSE=$(curl -s -X POST "$URL")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '"status"'; then

    eko $VERBOSE GREEN "Field 'status' is present."

    STATUS=$(echo "$RESPONSE" | grep -oP '(?<="status":")[^"]*')

    if [ "$STATUS" = "failed" ]; then
        eko $VERBOSE YELLOW "status is FAILED"

        if echo "$RESPONSE" | grep -q '"info"'; then

            eko $VERBOSE GREEN "Field 'info' is present."
            
        else
            eko true RED "Field 'info' is missing."
            exit 1
        fi

        
    fi
else
    eko true RED "Field 'status' is missing."
    exit 1
fi
eko true GREEN "success\n"





# ======================= login (bad creds) ======================= #
URL="$API_URL/login"
eko true MAGENTA ">>> login (wrong username and password): $URL"
RESPONSE=$(curl -s -X POST "$URL" -H "Content-Type: application/json" -d "{\"username\":\"Wrong Username\", \"password\":\"Wrong Password\"}")
eko $VERBOSE NC "$RESPONSE"

# if {"message":"Internal server error"} (DB Down)
if echo "$RESPONSE" | grep -q '{"message":"Internal server error"}'; then
    eko $VERBOSE GREEN "Field 'message' is present."
    eko $VERBOSE YELLOW "Internal server error (Probably DB is disconnected)"
elif echo "$RESPONSE" | grep -q '{"message":"Invalid username or password"}'; then
    eko $VERBOSE GREEN "Field 'message' is present."
    eko $VERBOSE YELLOW "Invalid username or password"
else
    eko true RED "Bad response"
    exit 1
fi

eko true GREEN "success\n"




# ======================= login (good creds) ======================= #
URL="$API_URL/login"
eko true MAGENTA ">>> login (admin/freepasses4all) - must reset stations first: $URL"
RESPONSE=$(curl -s -X POST "$URL" -H "Content-Type: application/json" -d "{\"username\":\"admin\", \"password\":\"freepasses4all\"}")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '"token"'; then
    eko $VERBOSE GREEN "Field 'token' is present."
    TOKEN=$(echo "$RESPONSE" | grep -oP '(?<="token":")[^"]*')
    # set AUTH_HEADER to token
    AUTH_HEADER_GOOD="X-OBSERVATORY-AUTH: $TOKEN"
else
    eko true RED "Field 'token' is missing."
    exit 1
fi
eko true GREEN "success\n"






# ======================= tollStationPasses json ======================= #
URL="$API_URL/tollStationPasses/AM03/20220101/20230101?format=json"
eko true MAGENTA ">>> tollStationPasses (JSON): $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_GOOD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"error":"Toll station not found"}'; then
    eko $VERBOSE GREEN "Field 'error' is present."
    eko $VERBOSE YELLOW "Toll station not found"
else
    if echo "$RESPONSE" | grep -q '"stationID":"AM03"'; then
        eko $VERBOSE GREEN "Field 'stationID' is present and correct."
    else
        eko true RED "Field 'stationID' is missing or has bad value."
        exit 1
    fi
    if echo "$RESPONSE" | grep -q '"stationOperator":"aegeanmotorway"'; then
        eko $VERBOSE GREEN "Field 'stationOperator' is present and correct."
    else
        eko true RED "Field 'stationOperator' is missing or has bad value."
        exit 1
    fi
    if echo "$RESPONSE" | grep -q '"requestTimestamp"'; then
        eko $VERBOSE GREEN "Field 'requestTimestamp' is present."
    else
        eko true RED "Field 'requestTimestamp' is missing."
        exit 1
    fi
    if echo "$RESPONSE" | grep -q '"periodFrom":"2022-01-01 00:00"'; then
        eko $VERBOSE GREEN "Field 'periodFrom' is present and correct."
    else
        eko true RED "Field 'periodFrom' is missing or has bad value."
        exit 1
    fi
    if echo "$RESPONSE" | grep -q '"periodTo":"2023-01-01 23:59"'; then
        eko $VERBOSE GREEN "Field 'periodTo' is present and correct."
    else
        eko true RED "Field 'periodTo' is missing or has bad value."
        exit 1
    fi
    if echo "$RESPONSE" | grep -q '"n_passes":'; then
        eko $VERBOSE GREEN "Field 'n_passes' is present."
    else
        eko true RED "Field 'n_passes' is missing."
        exit 1
    fi
    if echo "$RESPONSE" | grep -q '"passList":'; then
        eko $VERBOSE GREEN "Field 'passList' is present."
    else
        eko true RED "Field 'passList' is missing."
        exit 1
    fi
fi
eko true GREEN "success\n"

# ======================= tollStationPasses csv ======================= #
URL="$API_URL/tollStationPasses/AM03/20220101/20230101?format=csv"
eko true MAGENTA ">>> tollStationPasses (CSV): $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_GOOD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"error":"Toll station not found"}'; then
    eko $VERBOSE GREEN "Field 'error' is present."
    eko $VERBOSE YELLOW "Toll station not found"
else
    if echo "$RESPONSE" | grep -q 'stationID,stationOperator,requestTimestamp,periodFrom,periodTo,n_passes,passID,timestamp,tagID,tagProvider,passType,passCharge'; then
        eko $VERBOSE GREEN "Fields are present."
    else
        eko true RED "Fields are is missing."
        exit 1
    fi
fi
eko true GREEN "success\n"

# ======================= tollStationPasses json bad token ======================= #
URL="$API_URL/tollStationPasses/AM03/20220101/20230101?format=json"
eko true MAGENTA ">>> tollStationPasses (JSON, Bad token): $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_BAD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"message":"Forbidden: Invalid token"}'; then
    eko $VERBOSE GREEN "Field 'error' is present."
    eko $VERBOSE YELLOW "Forbidden: Invalid token"
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"

# ======================= tollStationPasses csv bad token ======================= #
URL="$API_URL/tollStationPasses/AM03/20220101/20230101?format=csv"
eko true MAGENTA ">>> tollStationPasses (CSV, Bad token): $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_BAD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"message":"Forbidden: Invalid token"}'; then
    eko $VERBOSE GREEN "Field 'error' is present."
    eko $VERBOSE YELLOW "Forbidden: Invalid token"
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"






# ======================= chargesBy json ======================= #
URL="$API_URL/chargesBy/AM/20220101/20230101?format=json"
eko true MAGENTA ">>> chargesBy (JSON): $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_GOOD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '"tollOpID":"AM"'; then
    eko $VERBOSE GREEN "Field 'tollOpID' is present and correct."
else
    eko true RED "Field 'tollOpID' is missing or wrong."
    exit 1
fi
if echo "$RESPONSE" | grep -q '"requestTimestamp"'; then
    eko $VERBOSE GREEN "Field 'requestTimestamp' is present."
else
    eko true RED "Field 'requestTimestamp' is missing."
    exit 1
fi
if echo "$RESPONSE" | grep -q '"periodFrom":"2022-01-01 00:00"'; then
    eko $VERBOSE GREEN "Field 'periodFrom' is present and correct."
else
    eko true RED "Field 'periodFrom' is missing or wrong."
    exit 1
fi
if echo "$RESPONSE" | grep -q '"periodTo":"2023-01-01 23:59"'; then
    eko $VERBOSE GREEN "Field 'periodTo' is present and correct."
else
    eko true RED "Field 'periodTo' is missing or wrong."
    exit 1
fi
if echo "$RESPONSE" | grep -q '"vOpList":'; then
    eko $VERBOSE GREEN "Field 'vOpList' is present."
else
    eko true RED "Field 'vOpList' is missing."
    exit 1
fi
eko true GREEN "success\n"

# ======================= chargesBy csv ======================= #
URL="$API_URL/chargesBy/AM/20220101/20230101?format=csv"
eko true MAGENTA ">>> chargesBy (CSV): $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_GOOD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q 'tollOpID,requestTimestamp,periodFrom,periodTo,visitingOpID,n_passes,passesCost'; then
    eko $VERBOSE GREEN "Fields are present."
else
    eko true RED "Fields are missing."
    exit 1
fi
eko true GREEN "success\n"

# ======================= chargesBy json bad token ======================= #
URL="$API_URL/chargesBy/AM/20220101/20230101?format=json"
eko true MAGENTA ">>> chargesBy (JSON, Bad token): $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_BAD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"message":"Forbidden: Invalid token"}'; then
    eko $VERBOSE GREEN "Field 'error' is present."
    eko $VERBOSE YELLOW "Forbidden: Invalid token"
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"

# ======================= chargesBy csv bad token ======================= #
URL="$API_URL/chargesBy/AM/20220101/20230101?format=csv"
eko true MAGENTA ">>> chargesBy (CSV, Bad token): $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_BAD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"message":"Forbidden: Invalid token"}'; then
    eko $VERBOSE GREEN "Field 'error' is present."
    eko $VERBOSE YELLOW "Forbidden: Invalid token"
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"

# ======================= chargesBy corner cases ======================= #
URL="$API_URL/chargesBy/AM/202401/2023?format=json"
eko true MAGENTA ">>> chargesBy: $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_GOOD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"error":"Failed to fetch charges by operators"}'; then
    eko $VERBOSE GREEN "Field 'error' is present."
    eko $VERBOSE YELLOW "Caught error."
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"

URL="$API_URL/chargesBy/AM/202401/2023?format=csv"
eko true MAGENTA ">>> chargesBy: $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_GOOD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"error":"Failed to fetch charges by operators"}'; then
    eko $VERBOSE GREEN "Field 'error' is present."
    eko $VERBOSE YELLOW "Caught error."
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"

URL="$API_URL/chargesBy/AM/1/1?format=json"
eko true MAGENTA ">>> chargesBy: $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_GOOD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"error":"Failed to fetch charges by operators"}'; then
    eko $VERBOSE GREEN "Field 'error' is present."
    eko $VERBOSE YELLOW "Caught error."
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"

URL="$API_URL/chargesBy/AA/202401/202301?format=json"
eko true MAGENTA ">>> chargesBy: $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_GOOD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"error":"Toll operator not found"}'; then
    eko $VERBOSE GREEN "Field 'error' is present."
    eko $VERBOSE YELLOW "Caught error."
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"




# ======================= passesCost ======================= #
URL="$API_URL/passesCost/AM/AM/20220101/20230101?format=json"
eko true MAGENTA ">>> passesCost: $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_GOOD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '"tollOpID":"AM"'; then
    eko $VERBOSE GREEN "Field 'tollOpID' is present and correct."
else
    eko true RED "Field 'tollOpID' is missing or wrong."
    exit 1
fi
if echo "$RESPONSE" | grep -q '"tagOpID":"AM"'; then
    eko $VERBOSE GREEN "Field 'tagOpID' is present and correct."
else
    eko true RED "Field 'tagOpID' is missing or wrong."
    exit 1
fi
if echo "$RESPONSE" | grep -q '"requestTimestamp"'; then
    eko $VERBOSE GREEN "Field 'requestTimestamp' is present."
else
    eko true RED "Field 'requestTimestamp' is missing."
    exit 1
fi
if echo "$RESPONSE" | grep -q '"periodFrom":"2022-01-01"'; then
    eko $VERBOSE GREEN "Field 'periodFrom' is present and correct."
else
    eko true RED "Field 'periodFrom' is missing or wrong."
    exit 1
fi
if echo "$RESPONSE" | grep -q '"periodTo":"2023-01-01"'; then
    eko $VERBOSE GREEN "Field 'periodTo' is present and correct."
else
    eko true RED "Field 'periodTo' is missing or wrong."
    exit 1
fi
if echo "$RESPONSE" | grep -q '"n_passes"'; then
    eko $VERBOSE GREEN "Field 'n_passes' is present ."
else
    eko true RED "Field 'n_passes' is missing."
    exit 1
fi
if echo "$RESPONSE" | grep -q '"passesCost"'; then
    eko $VERBOSE GREEN "Field 'passesCost' is present."
else
    eko true RED "Field 'passesCost' is missing."
    exit 1
fi
eko true GREEN "success\n"

# ======================= passesCost csv ======================= #
URL="$API_URL/passesCost/AM/AM/20220101/20230101?format=csv"
eko true MAGENTA ">>> passesCost: $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_GOOD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q 'tollOpID,tagOpID,requestTimestamp,periodFrom,periodTo,n_passes,passesCost'; then
    eko $VERBOSE GREEN "Fields are present."
else
    eko true RED "Fields are missing."
    exit 1
fi
eko true GREEN "success\n"

# ======================= passesCost json bad token ======================= #
URL="$API_URL/passesCost/AM/AM/20220101/20230101?format=json"
eko true MAGENTA ">>> passesCost (JSON, Bad token): $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_BAD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"message":"Forbidden: Invalid token"}'; then
    eko $VERBOSE GREEN "Field 'error' is present."
    eko $VERBOSE YELLOW "Forbidden: Invalid token"
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"

# ======================= passesCost csv bad token ======================= #
URL="$API_URL/passesCost/AM/AM/20220101/20230101?format=csv"
eko true MAGENTA ">>> passesCost (CSV, Bad token): $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_BAD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"message":"Forbidden: Invalid token"}'; then
    eko $VERBOSE GREEN "Field 'error' is present."
    eko $VERBOSE YELLOW "Forbidden: Invalid token"
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"

# ======================= passesCost corner cases ======================= #
URL="$API_URL/passesCost/AM/AM/202401/2023?format=json"
eko true MAGENTA ">>> passesCost: $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_GOOD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"error":"Failed to analyze passes"}'; then
    eko $VERBOSE GREEN "Field 'error' is present."
    eko $VERBOSE YELLOW "Caught error."
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"

URL="$API_URL/passesCost/AM/AM/1/1?format=json"
eko true MAGENTA ">>> passesCost: $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_GOOD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"error":"Failed to analyze passes"}'; then
    eko $VERBOSE GREEN "Field 'error' is present."
    eko $VERBOSE YELLOW "Caught error."
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"

URL="$API_URL/passesCost/AA/AM/202401/202301?format=json"
eko true MAGENTA ">>> passesCost: $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_GOOD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"error":"Toll or tag operator not found"}'; then
    eko $VERBOSE GREEN "Field 'error' is present."
    eko $VERBOSE YELLOW "Caught error."
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"




# ======================= passAnalysis ======================= #
URL="$API_URL/passAnalysis/AM/AM/20220101/20230101?format=json"
eko true MAGENTA ">>> passAnalysis: $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_GOOD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '"stationOpID":"AM"'; then
    eko $VERBOSE GREEN "Field 'stationOpID' is present and correct."
else
    eko true RED "Field 'stationOpID' is missing or wrong."
    exit 1
fi
if echo "$RESPONSE" | grep -q '"tagOpID":"AM"'; then
    eko $VERBOSE GREEN "Field 'tagOpID' is present and correct."
else
    eko true RED "Field 'tagOpID' is missing or wrong."
    exit 1
fi
if echo "$RESPONSE" | grep -q '"requestTimestamp"'; then
    eko $VERBOSE GREEN "Field 'requestTimestamp' is present."
else
    eko true RED "Field 'requestTimestamp' is missing."
    exit 1
fi
if echo "$RESPONSE" | grep -q '"periodFrom":"2022-01-01 00:00"'; then
    eko $VERBOSE GREEN "Field 'periodFrom' is present and correct."
else
    eko true RED "Field 'periodFrom' is missing or wrong."
    exit 1
fi
if echo "$RESPONSE" | grep -q '"periodTo":"2023-01-01 23:59"'; then
    eko $VERBOSE GREEN "Field 'periodTo' is present and correct."
else
    eko true RED "Field 'periodTo' is missing or wrong."
    exit 1
fi
if echo "$RESPONSE" | grep -q '"n_passes"'; then
    eko $VERBOSE GREEN "Field 'n_passes' is present ."
else
    eko true RED "Field 'n_passes' is missing."
    exit 1
fi
if echo "$RESPONSE" | grep -q '"passList":'; then
    eko $VERBOSE GREEN "Field 'passList' is present."
else
    eko true RED "Field 'passList' is missing."
    exit 1
fi
eko true GREEN "success\n"

# ======================= passAnalysis csv ======================= #
URL="$API_URL/passAnalysis/AM/AM/20220101/20230101?format=csv"
eko true MAGENTA ">>> passAnalysis: $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_GOOD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q 'stationOpID,tagOpID,requestTimestamp,periodFrom,periodTo,n_passes,passID,stationID,timestamp,tagID,passCharge'; then
    eko $VERBOSE GREEN "Fields are present."
else
    eko true RED "Fields are missing."
    exit 1
fi
eko true GREEN "success\n"

# ======================= passAnalysis json bad token ======================= #
URL="$API_URL/passAnalysis/AM/AM/20220101/20230101?format=json"
eko true MAGENTA ">>> passAnalysis (JSON, Bad token): $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_BAD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"message":"Forbidden: Invalid token"}'; then
    eko $VERBOSE GREEN "Field 'error' is present."
    eko $VERBOSE YELLOW "Forbidden: Invalid token"
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"

# ======================= passAnalysis csv bad token ======================= #
URL="$API_URL/passAnalysis/AM/AM/20220101/20230101?format=csv"
eko true MAGENTA ">>> passAnalysis (CSV, Bad token): $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_BAD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"message":"Forbidden: Invalid token"}'; then
    eko $VERBOSE GREEN "Field 'error' is present."
    eko $VERBOSE YELLOW "Forbidden: Invalid token"
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"

# ======================= passAnalysis corner cases ======================= #
URL="$API_URL/passAnalysis/AM/AM/202401/2023?format=json"
eko true MAGENTA ">>> passAnalysis: $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_GOOD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"error":"Failed to analyze passes"}'; then
    eko $VERBOSE GREEN "Field 'error' is present."
    eko $VERBOSE YELLOW "Caught error."
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"

URL="$API_URL/passAnalysis/AM/AM/1/1?format=json"
eko true MAGENTA ">>> passAnalysis: $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_GOOD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"error":"Failed to analyze passes"}'; then
    eko $VERBOSE GREEN "Field 'error' is present."
    eko $VERBOSE YELLOW "Caught error."
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"

URL="$API_URL/passAnalysis/AA/AM/202401/202301?format=json"
eko true MAGENTA ">>> passAnalysis: $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_GOOD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"error":"Station or tag operator not found"}'; then
    eko $VERBOSE GREEN "Field 'error' is present."
    eko $VERBOSE YELLOW "Caught error."
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"





# ======================= Admin: User Modification ======================= #
URL="$API_URL/admin/users"
eko true MAGENTA ">>> Admin: User Modification: $URL"
RESPONSE=$(curl -s -X POST "$URL" -H "$AUTH_HEADER_GOOD" -H "Content-Type: application/json" -d "{\"username\":\"new_username\", \"password\":\"new_password\"}")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"status":"OK"}'; then
    eko $VERBOSE GREEN "Field 'status' is present."
    eko $VERBOSE YELLOW "User modified successfully."
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"

# ======================= Admin: User Modification Bad token ======================= #
URL="$API_URL/admin/users"
eko true MAGENTA ">>> Admin: User Modification (Bad token): $URL"
RESPONSE=$(curl -s -X POST "$URL" -H "$AUTH_HEADER_BAD" -H "Content-Type: application/json" -d "{\"username\":\"new_username\", \"password\":\"new_password\"}")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"message":"Forbidden: Invalid token"}'; then
    eko $VERBOSE GREEN "Field 'message' is present."
    eko $VERBOSE YELLOW "Forbidden: Invalid token"
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"

# ======================= Admin: User Modification Corner cases ======================= #
URL="$API_URL/admin/users"
eko true MAGENTA ">>> Admin: User Modification: $URL"
RESPONSE=$(curl -s -X POST "$URL" -H "$AUTH_HEADER_GOOD" -H "Content-Type: application/json" -d "{\"username\":\"\", \"password\":\"pass\"}")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"message":"Username and password are required"}'; then
    eko $VERBOSE GREEN "Field 'message' is present."
    eko $VERBOSE YELLOW "Caught error."
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"
URL="$API_URL/admin/users"
eko true MAGENTA ">>> Admin: User Modification: $URL"
RESPONSE=$(curl -s -X POST "$URL" -H "$AUTH_HEADER_GOOD" -H "Content-Type: application/json" -d "{\"username\":\"\", \"password\":\"\"}")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"message":"Username and password are required"}'; then
    eko $VERBOSE GREEN "Field 'message' is present."
    eko $VERBOSE YELLOW "Caught error."
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"
URL="$API_URL/admin/users"
eko true MAGENTA ">>> Admin: User Modification: $URL"
RESPONSE=$(curl -s -X POST "$URL" -H "$AUTH_HEADER_GOOD" -H "Content-Type: application/json" -d "{\"username\":\"user\", \"password\":\"\"}")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"message":"Username and password are required"}'; then
    eko $VERBOSE GREEN "Field 'message' is present."
    eko $VERBOSE YELLOW "Caught error."
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"



# ======================= Admin: List Users ======================= #
URL="$API_URL/admin/users"
eko true MAGENTA ">>> Admin: List Users: $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_GOOD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"status":"failed","info":"Error retrieving users."}'; then
    eko $VERBOSE GREEN "Field 'status' and 'info' are present."
    eko $VERBOSE YELLOW "Error retrieving users."
elif echo "$RESPONSE" | grep -q '\['; then
    eko $VERBOSE GREEN "List is present."
else
    eko true RED "List is missing."
    exit 1
fi
eko true GREEN "success\n"


# ======================= Admin: List Users Bad token ======================= #
URL="$API_URL/admin/users"
eko true MAGENTA ">>> Admin: List Users (Bad token): $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_BAD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"message":"Forbidden: Invalid token"}'; then
    eko $VERBOSE GREEN "Field 'message' is present."
    eko $VERBOSE YELLOW "Forbidden: Invalid token"
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"



# ======================= Admin: Add Passes ======================= #
CSV_PATH="../back-end/src/data/passes-sample.csv"

# check if file exists
if [ ! -f "$CSV_PATH" ]; then
    eko true RED "File not found: $CSV_PATH"
    exit 1
fi

URL="$API_URL/admin/addpasses"
eko true MAGENTA ">>> Admin: Add Passes: $URL"
RESPONSE=$(curl -s -X POST "$URL" -H "$AUTH_HEADER_GOOD" -H "Content-Type: multipart/form-data" -F "file=@$CSV_PATH;type=text/csv")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"status":"OK"}'; then
    eko $VERBOSE GREEN "Field 'status' is present."
elif echo "$RESPONSE" | grep -q '{"status":"failed","info":"No file uploaded."}'; then
    eko $VERBOSE GREEN "Field 'status' and 'info' are present."
    eko $VERBOSE YELLOW "No file uploaded."
elif echo "$RESPONSE" | grep -q '{"status":"failed","info":"Error adding passes."}'; then
    eko $VERBOSE GREEN "Field 'status' and 'info' are present."
    eko $VERBOSE YELLOW "Error adding passes."
else
    eko true RED "Unknown error."
    exit 1
fi
eko true GREEN "success\n"



# ======================= Get Stations ======================= #
URL="$API_URL/stations"
eko true MAGENTA ">>> Get Stations: $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_GOOD")

# if response is greter than 50 characters, limi to 50 and add three dots
if [ ${#RESPONSE} -gt 50 ]; then
  RESPONSE="${RESPONSE:0:50}..."
fi
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '"stations":\['; then
    eko $VERBOSE GREEN "List is present."
else
    eko true RED "List is missing."
    exit 1
fi
eko true GREEN "success\n"



# ======================= Get Operators ======================= #
URL="$API_URL/operators"
eko true MAGENTA ">>> Get Operators: $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_GOOD")

if [ ${#RESPONSE} -gt 50 ]; then
  RESPONSE="${RESPONSE:0:50}..."
fi
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '"operators":\['; then
    eko $VERBOSE GREEN "List is present."
else
    eko true RED "List is missing."
    exit 1
fi



# ======================= Get Debt json ======================= #
URL="$API_URL/getDebt/AM/20220101/20220101?format=json"
eko true MAGENTA ">>> Get Debt: $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_GOOD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"message":"Unauthorized: No token provided"}'; then
    eko $VERBOSE YELLOW "Bad token."
else
    #{"tagOpID":"AM","requestTimestamp":"2024-12-20T15:41:04.819Z","periodFrom":"2022-01-01 00:00","periodTo":"2022-01-01 23:59","hOpList":[]}
    if echo "$RESPONSE" | grep -q '"tagOpID":"AM"'; then
        eko $VERBOSE GREEN "Field 'tagOpID' is present and correct."
    else
        eko true RED "Field 'tagOpID' is missing or wrong."
        exit 1
    fi
    if echo "$RESPONSE" | grep -q '"requestTimestamp"'; then
        eko $VERBOSE GREEN "Field 'requestTimestamp' is present."
    else
        eko true RED "Field 'requestTimestamp' is missing."
        exit 1
    fi
    if echo "$RESPONSE" | grep -q '"periodFrom":"2022-01-01 00:00"'; then
        eko $VERBOSE GREEN "Field 'periodFrom' is present and correct."
    else
        eko true RED "Field 'periodFrom' is missing or has bad value."
        exit 1
    fi
    if echo "$RESPONSE" | grep -q '"periodTo":"2022-01-01 23:59"'; then
        eko $VERBOSE GREEN "Field 'periodTo' is present and correct."
    else
        eko true RED "Field 'periodTo' is missing or has bad value."
        exit 1
    fi
    if echo "$RESPONSE" | grep -q '"hOpList":'; then
        eko $VERBOSE GREEN "Field 'hOpList' is present."
    else
        eko true RED "Field 'hOpList' is missing."
        exit 1
    fi
fi
eko true GREEN "success\n"

# ======================= Get Debt csv ======================= #
URL="$API_URL/getDebt/AM/20220101/20220101?format=csv"
eko true MAGENTA ">>> Get Debt: $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_GOOD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q 'tagOpID,requestTimestamp,periodFrom,periodTo,homeOpID,n_passes,passesCost'; then
    eko $VERBOSE GREEN "Fields are present."
else
    eko true RED "Fields are missing."
    exit 1
fi
eko true GREEN "success\n"

# ======================= Get Debt json bad token ======================= #
URL="$API_URL/getDebt/AM/20220101/20220101?format=json"
eko true MAGENTA ">>> Get Debt (Bad token): $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_BAD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"message":"Forbidden: Invalid token"}'; then
    eko $VERBOSE GREEN "Field 'message' is present."
    eko $VERBOSE YELLOW "Forbidden: Invalid token"
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"

# ======================= Get Debt csv bad token ======================= #
URL="$API_URL/getDebt/AM/20220101/20220101?format=csv"
eko true MAGENTA ">>> Get Debt (Bad token): $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_BAD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"message":"Forbidden: Invalid token"}'; then
    eko $VERBOSE GREEN "Field 'message' is present."
    eko $VERBOSE YELLOW "Forbidden: Invalid token"
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"

# ======================= Get Debt corner cases ======================= #
URL="$API_URL/getDebt/AM/202401/2023?format=json"
eko true MAGENTA ">>> Get Debt: $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_GOOD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"error":"Failed to calculate debt"}'; then
    eko $VERBOSE GREEN "Field 'error' is present."
    eko $VERBOSE YELLOW "Caught error."
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"

URL="$API_URL/getDebt/AM/1/1?format=json"
eko true MAGENTA ">>> Get Debt: $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_GOOD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"error":"Failed to calculate debt"}'; then
    eko $VERBOSE GREEN "Field 'error' is present."
    eko $VERBOSE YELLOW "Caught error."
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"

URL="$API_URL/getDebt/AA/202401/202301?format=json"
eko true MAGENTA ">>> Get Debt: $URL"
RESPONSE=$(curl -s -X GET "$URL" -H "$AUTH_HEADER_GOOD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"error":"Tag operator not found"}'; then
    eko $VERBOSE GREEN "Field 'error' is present."
    eko $VERBOSE YELLOW "Caught error."
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"




# ======================= Pay Debt ======================= #
URL="$API_URL/payDebt/AM/AM/20220101/20220101?format=json"
eko true MAGENTA ">>> Pay Debt: $URL"
RESPONSE=$(curl -s -X PUT "$URL" -H "$AUTH_HEADER_GOOD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"message":"Unauthorized: No token provided"}'; then
    eko $VERBOSE YELLOW "Bad token."
else
    if echo "$RESPONSE" | grep -q '{"status":"OK",'; then
        eko $VERBOSE GREEN "Field 'status' is present."
        eko $VERBOSE YELLOW "Debt paid successfully."
    else
        eko true RED "Bad response"
        exit 1
    fi
fi
eko true GREEN "success\n"

# ======================= Pay Debt bad token ======================= #
URL="$API_URL/payDebt/AM/AM/20220101/20220101?format=json"
eko true MAGENTA ">>> Pay Debt (Bad token): $URL"
RESPONSE=$(curl -s -X PUT "$URL" -H "$AUTH_HEADER_BAD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"message":"Forbidden: Invalid token"}'; then
    eko $VERBOSE GREEN "Field 'message' is present."
    eko $VERBOSE YELLOW "Forbidden: Invalid token"
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"

# ======================= Pay Debt corner cases ======================= #
URL="$API_URL/payDebt/AM/AM/202401/2023?format=json"
eko true MAGENTA ">>> Pay Debt: $URL"
RESPONSE=$(curl -s -X PUT "$URL" -H "$AUTH_HEADER_GOOD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"error":"Failed to pay debt"}'; then
    eko $VERBOSE GREEN "Field 'error' is present."
    eko $VERBOSE YELLOW "Caught error."
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"

URL="$API_URL/payDebt/AM/AM/1/1?format=json"
eko true MAGENTA ">>> Pay Debt: $URL"
RESPONSE=$(curl -s -X PUT "$URL" -H "$AUTH_HEADER_GOOD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"error":"Failed to pay debt"}'; then
    eko $VERBOSE GREEN "Field 'error' is present."
    eko $VERBOSE YELLOW "Caught error."
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"

URL="$API_URL/payDebt/AA/AM/202401/202301?format=json"
eko true MAGENTA ">>> Pay Debt: $URL"
RESPONSE=$(curl -s -X PUT "$URL" -H "$AUTH_HEADER_GOOD")
eko $VERBOSE NC "$RESPONSE"

if echo "$RESPONSE" | grep -q '{"error":"Toll or tag operator not found"}'; then
    eko $VERBOSE GREEN "Field 'error' is present."
    eko $VERBOSE YELLOW "Caught error."
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"





# ======================= logout bad token ======================= #
URL="$API_URL/logout"
eko true MAGENTA ">>> logout (Bad token): $URL"
RESPONSE=$(curl -s -X POST "$URL" -H "$AUTH_HEADER_BAD")
eko $VERBOSE NC "$RESPONSE"

# {"message":"Forbidden: Invalid token"}
if echo "$RESPONSE" | grep -q '{"message":"Forbidden: Invalid token"}'; then
    eko $VERBOSE GREEN "Field 'message' is present."
    eko $VERBOSE YELLOW "Forbidden: Invalid token"
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"

# ======================= logout good token ======================= #
URL="$API_URL/logout"
eko true MAGENTA ">>> logout (Good token): $URL"
RESPONSE=$(curl -s -X POST "$URL" -H "$AUTH_HEADER_GOOD")

if [ -z "$RESPONSE" ]; then
    eko $VERBOSE GREEN "Response is empty."
else
    eko $VERBOSE NC "$RESPONSE"
    eko true RED "Response is not empty."
    exit 1
fi
eko true GREEN "success\n"

# ======================= logout no token ======================= #
URL="$API_URL/logout"
eko true MAGENTA ">>> logout (No token): $URL"
RESPONSE=$(curl -s -X POST "$URL")

# {"message":"Unauthorized: No token provided"}
if echo "$RESPONSE" | grep -q '{"message":"Unauthorized: No token provided"}'; then
    eko $VERBOSE GREEN "Field 'message' is present."
    eko $VERBOSE YELLOW "Unauthorized: No token provided"
else
    eko true RED "Bad response"
    exit 1
fi
eko true GREEN "success\n"

# ======================= logout again ======================= #
URL="$API_URL/logout"
eko true MAGENTA ">>> logout (Again): $URL"
RESPONSE=$(curl -s -X POST "$URL" -H "$AUTH_HEADER_GOOD")

if [ -z "$RESPONSE" ]; then
    eko $VERBOSE GREEN "Response is empty."
else
    eko $VERBOSE NC "$RESPONSE"
    eko true RED "Response is not empty."
    exit 1
fi
eko true GREEN "success\n"





eko true GREEN "===================\nAll tests completed successfully\n"
