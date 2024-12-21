#!/bin/bash

test_passanalysis (){

    CMD=$1
    VERBOSE=$2
    TITLE=$3
    eko true MAGENTA ">>> $TITLE"
    eko $VERBOSE MAGENTA ">>> $CMD"
    RESPONSE=$($CMD 2>&1)
    eko $VERBOSE NC ">>> $RESPONSE"

    # cli
    if echo "$RESPONSE" | grep -q 'Error: 500 - undefined'; then
        eko $VERBOSE GREEN "[Error: 500 - undefined]"
    elif echo "$RESPONSE" | grep -q 'Error: 400 - undefined'; then
        eko $VERBOSE GREEN "[Error: 400 - undefined]"
    elif echo "$RESPONSE" | grep -q 'Error: No token found. Please log in first.'; then
        eko $VERBOSE YELLOW "[Error: No token found. Please log in first.]"

    # both
    elif echo "$RESPONSE" | grep -q '{"error":"Failed to analyze passes"}'; then
        eko $VERBOSE GREEN "[Failed to analyze passes]"
    elif echo "$RESPONSE" | grep -q 'stationOpID,tagOpID,requestTimestamp,periodFrom,periodTo,n_passes,passID,stationID,timestamp,tagID,passCharge'; then # csv
        eko $VERBOSE GREEN "CSV Fields are present."
    elif echo "$RESPONSE" | grep -q 'Station or tag operator not found'; then
        eko $VERBOSE GREEN "[Station or tag operator not found]"
    elif echo "$RESPONSE" | grep -q '{"message":"Forbidden: Invalid token"}'; then
        eko $VERBOSE GREEN "[Forbidden: Invalid token]"
    elif echo "$RESPONSE" | grep -q '{"message":"Unauthorized: No token provided"}'; then
        eko $VERBOSE GREEN "[No token provided]"
    else
        if echo "$RESPONSE" | grep -q '"stationOpID":'; then
            eko $VERBOSE GREEN "Field 'stationOpID' is present."
        else
            eko true RED "Field 'stationOpID' is missing."
            exit 1
        fi
        if echo "$RESPONSE" | grep -q '"tagOpID":'; then
            eko $VERBOSE GREEN "Field 'tagOpID' is present."
        else
            eko true RED "Field 'tagOpID' is missing."
            exit 1
        fi
        if echo "$RESPONSE" | grep -q '"requestTimestamp"'; then
            eko $VERBOSE GREEN "Field 'requestTimestamp' is present."
        else
            eko true RED "Field 'requestTimestamp' is missing."
            exit 1
        fi
        if echo "$RESPONSE" | grep -q '"periodFrom":'; then
            eko $VERBOSE GREEN "Field 'periodFrom' is present."
        else
            eko true RED "Field 'periodFrom' is missing."
            exit 1
        fi
        if echo "$RESPONSE" | grep -q '"periodTo":'; then
            eko $VERBOSE GREEN "Field 'periodTo' is present."
        else
            eko true RED "Field 'periodTo' is missing."
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
    fi
    eko true GREEN "success\n"

}

