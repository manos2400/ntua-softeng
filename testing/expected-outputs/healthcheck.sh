#!/bin/bash

test_healthcheck (){

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
        
        if echo "$RESPONSE" | grep -q '"dbconnection"'; then
            
            eko $VERBOSE GREEN "Field 'dbconnection' is present."
            
        else
            eko true RED "Field 'dbconnection' is missing."
            exit 1
        fi

        if [ "$STATUS" = "failed" ]; then
            eko $VERBOSE YELLOW "status is FAILED"
        else
            
            if echo "$RESPONSE" | grep -q '"n_stations"'; then

                eko $VERBOSE GREEN "Field 'n_stations' is present."
                
            else
                eko true RED "Field 'n_stations' is missing."
                exit 1
            fi

            if echo "$RESPONSE" | grep -q '"n_tags"'; then

                eko $VERBOSE GREEN "Field 'n_tags' is present."
                
            else
                eko true RED "Field 'n_tags' is missing."
                exit 1
            fi

            if echo "$RESPONSE" | grep -q '"n_passes"'; then

                eko $VERBOSE GREEN "Field 'n_passes' is present."
                
            else
                eko true RED "Field 'n_passes' is missing."
                exit 1
            fi
            
        fi
    else
        eko true RED "Field 'status' is missing."
        exit 1
    fi
    eko true GREEN "success\n"

}

