#!/bin/bash

test_admin_add_passes (){

    CMD=$1
    VERBOSE=$2
    TITLE=$3
    eko true MAGENTA ">>> $TITLE"
    eko $VERBOSE MAGENTA ">>> $CMD"
    RESPONSE=$($CMD 2>&1)
    eko $VERBOSE NC ">>> $RESPONSE"

    if echo "$RESPONSE" | grep -q '{"status":"OK"}'; then
        eko $VERBOSE GREEN "Field 'status' is present."
    elif echo "$RESPONSE" | grep -q '{"status":"failed","info":"No file uploaded."}'; then
        eko $VERBOSE GREEN "Field 'status' and 'info' are present."
        eko $VERBOSE YELLOW "No file uploaded."
    elif echo "$RESPONSE" | grep -q '{"status":"failed","info":"Error adding passes."}'; then
        eko $VERBOSE GREEN "Field 'status' and 'info' are present."
        eko $VERBOSE YELLOW "Error adding passes."
    elif echo "$RESPONSE" | grep -q '{"message":"Forbidden: Invalid token"}'; then
        eko $VERBOSE GREEN "[Forbidden: Invalid token]"
    elif echo "$RESPONSE" | grep -q '{"message":"Unauthorized: No token provided"}'; then
        eko $VERBOSE GREEN "[Unauthorized: No token provided]"
    else
        eko true RED "Unknown error."
        exit 1
    fi
    eko true GREEN "success\n"

}

