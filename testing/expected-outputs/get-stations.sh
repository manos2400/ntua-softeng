#!/bin/bash

test_get_stations (){

    CMD=$1
    VERBOSE=$2
    TITLE=$3
    eko true MAGENTA ">>> $TITLE"
    eko $VERBOSE MAGENTA ">>> $CMD"
    RESPONSE=$($CMD 2>&1)

    # if response is greter than 50 characters, limit to 50 and add three dots
    if [ ${#RESPONSE} -gt 50 ]; then
    RESPONSE="${RESPONSE:0:50}..."
    fi
    eko $VERBOSE NC ">>> $RESPONSE"

    if echo "$RESPONSE" | grep -q '"stations":\['; then
        eko $VERBOSE GREEN "List is present."
    elif echo "$RESPONSE" | grep -q '{"message":"Forbidden: Invalid token"}'; then
        eko $VERBOSE GREEN "[Forbidden: Invalid token]"
    elif echo "$RESPONSE" | grep -q '{"message":"Unauthorized: No token provided"}'; then
        eko $VERBOSE GREEN "[Unauthorized: No token provided]"
    else
        eko true RED "List is missing."
        exit 1
    fi
    eko true GREEN "success\n"

}

