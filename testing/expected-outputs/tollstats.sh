#!/bin/bash

test_tollstats (){

    CMD=$1
    VERBOSE=$2
    TITLE=$3
    eko true MAGENTA ">>> $TITLE"
    eko $VERBOSE MAGENTA ">>> $CMD"
    RESPONSE=$($CMD 2>&1)
    eko $VERBOSE NC ">>> $RESPONSE"

    # cli
    if echo "$RESPONSE" | grep -q '{"error":"Toll operator not found"}'; then
        eko $VERBOSE GREEN "[Toll operator not found]"
    elif echo "$RESPONSE" | grep -q 'tollOpID,requestTimestamp,periodFrom,periodTo,totalPasses,totalRevenue,mostPasses,mostRevenue,mostPassesWithHomeTag,mostRevenueWithHomeTag'; then # csv
        eko $VERBOSE GREEN "CSV Fields are present."
    elif echo "$RESPONSE" | grep -q '{"message":"Forbidden: Invalid token"}'; then
        eko $VERBOSE GREEN "[Forbidden: Invalid token]"
    elif echo "$RESPONSE" | grep -q '{"message":"Unauthorized: No token provided"}'; then
        eko $VERBOSE GREEN "[No token provided]"
    elif echo "$RESPONSE" | grep -q '{"error":"Failed to fetch toll stats"}'; then
        eko $VERBOSE GREEN "[Failed to fetch toll stats]"
    elif echo "$RESPONSE" | grep -q '{"error":"No passes found in that time period"}'; then
        eko $VERBOSE GREEN "[No passes found in that time period]"
    else

        if echo "$RESPONSE" | grep -q '"tollOpID":'; then
            eko $VERBOSE GREEN "Field 'tollOpID' is present."
        else
            eko true RED "Field 'tollOpID' is missing."
            exit 1
        fi
        if echo "$RESPONSE" | grep -q '"requestTimestamp":'; then
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
        if echo "$RESPONSE" | grep -q '"stats":'; then
            eko $VERBOSE GREEN "Field 'stats' is present."
        else
            eko true RED "Field 'stats' is missing."
            exit 1
        fi
        if echo "$RESPONSE" | grep -q '"totalPasses":'; then
            eko $VERBOSE GREEN "Field 'totalPasses' is present."
        else
            eko true RED "Field 'totalPasses' is missing."
            exit 1
        fi
        if echo "$RESPONSE" | grep -q '"totalRevenue":'; then
            eko $VERBOSE GREEN "Field 'totalRevenue' is present."
        else
            eko true RED "Field 'totalRevenue' is missing."
            exit 1
        fi
        if echo "$RESPONSE" | grep -q '"mostPasses":'; then
            eko $VERBOSE GREEN "Field 'mostPasses' is present."
        else
            eko true RED "Field 'mostPasses' is missing."
            exit 1
        fi
        if echo "$RESPONSE" | grep -q '"mostRevenue":'; then
            eko $VERBOSE GREEN "Field 'mostRevenue' is present."
        else
            eko true RED "Field 'mostRevenue' is missing."
            exit 1
        fi
        if echo "$RESPONSE" | grep -q '"mostPassesWithHomeTag":'; then
            eko $VERBOSE GREEN "Field 'mostPassesWithHomeTag' is present."
        else
            eko true RED "Field 'mostPassesWithHomeTag' is missing."
            exit 1
        fi
        if echo "$RESPONSE" | grep -q '"mostRevenueWithHomeTag":'; then
            eko $VERBOSE GREEN "Field 'mostRevenueWithHomeTag' is present."
        else
            eko true RED "Field 'mostRevenueWithHomeTag' is missing."
            exit 1
        fi
    fi
    eko true GREEN "success\n"

}

