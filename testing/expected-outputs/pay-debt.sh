#!/bin/bash

test_pay_debt (){

    CMD=$1
    VERBOSE=$2
    TITLE=$3
    eko true MAGENTA ">>> $TITLE"
    eko $VERBOSE MAGENTA ">>> $CMD"
    RESPONSE=$($CMD 2>&1)
    eko $VERBOSE NC ">>> $RESPONSE"

    if echo "$RESPONSE" | grep -q '{"message":"Unauthorized: No token provided"}'; then
        eko $VERBOSE GREEN "[Unauthorized: No token provided]"
    elif echo "$RESPONSE" | grep -q '{"message":"Forbidden: Invalid token"}'; then
        eko $VERBOSE GREEN "[Forbidden: Invalid token]"
    elif echo "$RESPONSE" | grep -q '{"error":"Failed to pay debt"}'; then
        eko $VERBOSE GREEN "[Failed to pay debt]"
    elif echo "$RESPONSE" | grep -q '{"error":"Toll or tag operator not found"}'; then
        eko $VERBOSE GREEN "[Toll or tag operator not found]"
    elif echo "$RESPONSE" | grep -q '{"status":"OK"'; then
        eko $VERBOSE GREEN "[OK!]"
    else
        eko true RED "Unknown"
        exit 1
    fi
    eko true GREEN "success\n"

}

