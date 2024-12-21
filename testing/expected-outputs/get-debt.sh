#!/bin/bash

test_get_debt (){

    CMD=$1
    VERBOSE=$2
    TITLE=$3
    eko true MAGENTA ">>> $TITLE"
    eko $VERBOSE MAGENTA ">>> $CMD"
    RESPONSE=$($CMD 2>&1)
    eko $VERBOSE NC ">>> $RESPONSE"

    if echo "$RESPONSE" | grep -q '{"message":"Unauthorized: No token provided"}'; then
        eko $VERBOSE GREEN "[Unauthorized: No token provided]"
    elif echo "$RESPONSE" | grep -q 'tagOpID,requestTimestamp,periodFrom,periodTo,homeOpID,n_passes,passesCost'; then
        eko $VERBOSE GREEN "Fields are present."
    elif echo "$RESPONSE" | grep -q '{"message":"Forbidden: Invalid token"}'; then
        eko $VERBOSE GREEN "[Forbidden: Invalid token]"
    elif echo "$RESPONSE" | grep -q '{"error":"Failed to calculate debt"}'; then
        eko $VERBOSE GREEN "[Failed to calculate debt]"
    elif echo "$RESPONSE" | grep -q '{"error":"Tag operator not found"}'; then
        eko $VERBOSE GREEN "[Tag operator not found]"
    else
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
        if echo "$RESPONSE" | grep -q '"hOpList":'; then
            eko $VERBOSE GREEN "Field 'hOpList' is present."
        else
            eko true RED "Field 'hOpList' is missing."
            exit 1
        fi
    fi
    eko true GREEN "success\n"

}

