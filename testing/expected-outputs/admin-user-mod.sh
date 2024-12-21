#!/bin/bash

test_admin_user_mod (){

    CMD=$1
    VERBOSE=$2
    TITLE=$3
    eko true MAGENTA ">>> $TITLE"
    eko $VERBOSE MAGENTA ">>> $CMD"
    RESPONSE=$($CMD 2>&1)
    eko $VERBOSE NC ">>> $RESPONSE"

    if echo "$RESPONSE" | grep -q '{"status":"OK"}'; then
        eko $VERBOSE GREEN "Field 'status' is present."
    elif echo "$RESPONSE" | grep -q '{"message":"Forbidden: Invalid token"}'; then
        eko $VERBOSE GREEN "[Forbidden: Invalid token]"
    elif echo "$RESPONSE" | grep -q '{"message":"Unauthorized: No token provided"}'; then
        eko $VERBOSE GREEN "[Unauthorized: No token provided]"
    elif echo "$RESPONSE" | grep -q '{"message":"Username and password are required"}'; then
        eko $VERBOSE GREEN "[Username and password are required]"
    else
        eko true RED "Bad response"
        exit 1
    fi
    eko true GREEN "success\n"

}

