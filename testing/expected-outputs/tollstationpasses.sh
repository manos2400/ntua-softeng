#!/bin/bash

test_tollStationPasses (){

    CMD=$1
    VERBOSE=$2
    TITLE=$3
    eko true MAGENTA ">>> $TITLE"
    eko $VERBOSE MAGENTA ">>> $CMD"
    RESPONSE=$($CMD 2>&1)
    eko $VERBOSE NC ">>> $RESPONSE"

    if echo "$RESPONSE" | grep -q '{"error":"Toll station not found"}'; then
        eko $VERBOSE GREEN "[Toll station not found]"
    elif echo "$RESPONSE" | grep -q 'stationID,stationOperator,requestTimestamp,periodFrom,periodTo,n_passes,passID,timestamp,tagID,tagProvider,passType,passCharge'; then # csv
        eko $VERBOSE GREEN "CSV Fields are present."
    elif echo "$RESPONSE" | grep -q '{"message":"Forbidden: Invalid token"}'; then
        eko $VERBOSE GREEN "[Forbidden: Invalid token]"
    elif echo "$RESPONSE" | grep -q '{"message":"Unauthorized: No token provided"}'; then
        eko $VERBOSE GREEN "[No token provided]"
    else
        if echo "$RESPONSE" | grep -q '"stationID":'; then
            eko $VERBOSE GREEN "Field 'stationID' is present."
        else
            eko true RED "Field 'stationID' is missing."
            exit 1
        fi
        if echo "$RESPONSE" | grep -q '"stationOperator":'; then
            eko $VERBOSE GREEN "Field 'stationOperator' is present."
        else
            eko true RED "Field 'stationOperator' is missing."
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

}

