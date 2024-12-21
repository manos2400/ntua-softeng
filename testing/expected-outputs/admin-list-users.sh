#!/bin/bash

test_admin_list_users (){

    CMD=$1
    VERBOSE=$2
    TITLE=$3
    eko true MAGENTA ">>> $TITLE"
    eko $VERBOSE MAGENTA ">>> $CMD"
    RESPONSE=$($CMD 2>&1)
    eko $VERBOSE NC ">>> $RESPONSE"

    if echo "$RESPONSE" | grep -q '{"status":"failed","info":"Error retrieving users."}'; then
        eko $VERBOSE GREEN "[Error retrieving users]"
    elif echo "$RESPONSE" | grep -q 'Error: No token found. Please log in first.'; then
        eko $VERBOSE YELLOW "[Error: No token found. Please log in first.]"
    elif echo "$RESPONSE" | grep -q '\['; then
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

