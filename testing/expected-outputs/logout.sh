#!/bin/bash

test_logout (){

    CMD=$1
    VERBOSE=$2
    TITLE=$3
    eko true MAGENTA ">>> $TITLE"
    eko $VERBOSE MAGENTA ">>> $CMD"
    RESPONSE=$($CMD 2>&1)
    eko $VERBOSE NC ">>> $RESPONSE"

    # cli
    if echo "$RESPONSE" | grep -q '???'; then
        eko $VERBOSE GREEN "[???]"

    # curl
    elif echo "$RESPONSE" | grep -q '{"message":"Internal server error"}'; then
        eko $VERBOSE YELLOW "Field 'message' is present. [Internal server error (Probably DB is disconnected)]"
    elif echo "$RESPONSE" | grep -q '{"message":"Forbidden: Invalid token"}'; then
        eko $VERBOSE GREEN "[Forbidden: Invalid token]"
    elif echo "$RESPONSE" | grep -q '{"message":"Unauthorized: No token provided"}'; then
        eko $VERBOSE GREEN "[Unauthorized: No token provided]"
    elif [ -z "$RESPONSE" ]; then
        eko $VERBOSE GREEN "Response is empty."
    else
        eko true RED "Bad response"
        exit 1
    fi

    eko true GREEN "success\n"

}

