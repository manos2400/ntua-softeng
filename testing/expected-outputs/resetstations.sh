#!/bin/bash

test_resetstations (){

    CMD=$1
    VERBOSE=$2
    TITLE=$3
    eko true MAGENTA ">>> $TITLE"
    eko $VERBOSE MAGENTA ">>> $CMD"
    RESPONSE=$($CMD 2>&1)
    eko $VERBOSE NC ">>> $RESPONSE"

    if echo "$RESPONSE" | grep -q 'Error: 500 - undefined'; then # cli
        eko $VERBOSE YELLOW "[Error: 500 - undefined]"
    elif echo "$RESPONSE" | grep -q '"status"'; then

        eko $VERBOSE GREEN "Field 'status' is present."

        STATUS=$(echo "$RESPONSE" | grep -oP '(?<="status":")[^"]*')

        if [ "$STATUS" = "failed" ]; then
            eko $VERBOSE YELLOW "status is FAILED"

            if echo "$RESPONSE" | grep -q '"info"'; then

                eko $VERBOSE GREEN "Field 'info' is present."
                
            else
                eko true RED "Field 'info' is missing."
                exit 1
            fi

            
        fi
    else
        eko true RED "Field 'status' is missing."
        exit 1
    fi
    eko true GREEN "success\n"

}

