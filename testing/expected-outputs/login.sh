#!/bin/bash

test_login (){

    CMD=$1
    VERBOSE=$2
    TITLE=$3
    eko true MAGENTA ">>> $TITLE"
    eko $VERBOSE MAGENTA ">>> $CMD"
    RESPONSE=$($CMD 2>&1)
    eko $VERBOSE NC ">>> $RESPONSE"

    # cli
    if echo "$RESPONSE" | grep -q 'not specified'; then
        eko $VERBOSE GREEN "[not specified]"
    elif echo "$RESPONSE" | grep -q 'Error: 401 - Invalid username or password'; then
        eko $VERBOSE GREEN "[Invalid username or password]"
    elif echo "$RESPONSE" | grep -q 'Error: 500 - Internal server error'; then
        eko $VERBOSE YELLOW "[Error: 500 - Internal server error - DB not active]"
    elif echo "$RESPONSE" | grep -q 'argument missing'; then
        eko $VERBOSE GREEN "[argument missing]"
    
    
    # curl
    elif echo "$RESPONSE" | grep -q '{"message":"Internal server error"}'; then
        eko $VERBOSE YELLOW "Field 'message' is present. [Internal server error (Probably DB is disconnected)]"
    elif echo "$RESPONSE" | grep -q '{"message":"Invalid username or password"}'; then
        eko $VERBOSE GREEN "Field 'message' is present. [Invalid username or password]"
    elif echo "$RESPONSE" | grep -q '{"message":"Username and password are required"}'; then
        eko $VERBOSE GREEN "Field 'message' is present. [Username and password are required]"
    else
        if echo "$RESPONSE" | grep -q '"token"'; then
            eko $VERBOSE GREEN "Field 'token' is present."
            TOKEN=$(echo "$RESPONSE" | grep -oP '(?<="token":")[^"]*')
            # set AUTH_HEADER to token
            AUTH_HEADER_GOOD="X-OBSERVATORY-AUTH:$TOKEN"
        else
            eko true RED "Field 'token' is missing."
            exit 1
        fi
    fi

    eko true GREEN "success\n"

}

