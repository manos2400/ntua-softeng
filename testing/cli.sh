#!/bin/bash

# Test the API using curl

source ./utils.sh

eko NC "Testing API...\n====================\n TIP: use option -d to view more details\n"

SHOW_DETAILS=false

# look for option d
while getopts ":d" opt; do
    case ${opt} in
        d )
            SHOW_DETAILS=true
            ;;
        \? )
            eko RED "Invalid option: $OPTARG\n"
            ;;
    esac
done

# if details, print hello:
if [ "$SHOW_DETAILS" = true ]; then
    eko GREEN "Hello, World!\n"
fi