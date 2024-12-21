#!/bin/bash

test_chargesby (){

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
    
    # csv
    elif echo "$RESPONSE" | grep -q 'tollOpID,requestTimestamp,periodFrom,periodTo,visitingOpID,n_passes,passesCost'; then
        eko $VERBOSE GREEN "Fields are present."

    # both
    elif echo "$RESPONSE" | grep -q '{"message":"Forbidden: Invalid token"}'; then
        eko $VERBOSE GREEN "[Forbidden: Invalid token]"
    elif echo "$RESPONSE" | grep -q '{"error":"Failed to fetch charges by operators"}'; then
        eko $VERBOSE GREEN "[failed to fetch charges by operators]"
    elif echo "$RESPONSE" | grep -q '{"message":"Unauthorized: No token provided"}'; then
        eko $VERBOSE GREEN "[Unauthorized: No token provided]"
    elif echo "$RESPONSE" | grep -q '{"error":"Toll operator not found"}'; then
        eko $VERBOSE GREEN "Toll operator not found"


    # json
    else

        if echo "$RESPONSE" | grep -q '"tollOpID":'; then
            eko $VERBOSE GREEN "Field 'tollOpID' is present."
        else
            eko true RED "Field 'tollOpID' is missing."
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
        if echo "$RESPONSE" | grep -q '"vOpList":'; then
            eko $VERBOSE GREEN "Field 'vOpList' is present."
        else
            eko true RED "Field 'vOpList' is missing."
            exit 1
        fi
    fi
    eko true GREEN "success\n"

}

