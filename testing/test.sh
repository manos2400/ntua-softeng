#!/bin/bash

# Test the API using curl or the CLI

source ./utils.sh

usage() {
    eko true YELLOW "Usage: test.sh [-h] [-v] [api | cli]\n"
    eko true YELLOW "Options:\n"
    eko true YELLOW "  -h   Show this help message and exit\n"
    eko true YELLOW "  -v   Verbose (show more info)\n"
    eko true YELLOW "Arguments:\n"
    eko true YELLOW "  api   Test the API using curl\n"
    eko true YELLOW "  cli   Test the CLI\n"
    eko true YELLOW "Examples:\n"
    eko true YELLOW "  test.sh api\n"
    eko true YELLOW "  test.sh -v cli\n"
}

SHOW_DETAILS=false
TO_TEST=""

# parse options
while getopts ":hv" opt; do
    case ${opt} in
        h )
            usage
            exit 0
            ;;
        v )
            SHOW_DETAILS=true
            ;;
        \? )
            eko true RED "Invalid option: $OPTARG\n"
            usage
            exit 1
            ;;
        : )
            eko true RED "Invalid option: $OPTARG requires an argument\n"
            usage
            exit 1
            ;;
    esac
done

shift $((OPTIND -1))

# check if no arguments

if [ "$#" -eq 0 ]; then
    eko true RED "No arguments supplied\n"
    usage
    exit 1
fi

# check if more than one argument
if [ "$#" -gt 1 ]; then
    eko true RED "Too many arguments\n"
    usage
    exit 1
fi

# check if argument is api or cli
if [ "$1" = "api" ]; then
    TO_TEST="api"
elif [ "$1" = "cli" ]; then
    TO_TEST="cli"
else
    eko true RED "Invalid argument: $1\n"
    usage
    exit 1
fi


eko true CYAN "Testing $TO_TEST"
# if verbose print using verbose else not verbose
if [ "$SHOW_DETAILS" = true ]; then
    eko true CYAN "Using verbose mode"
else
    eko true CYAN "Not using verbose mode"
fi



# Function to check if a service is running
check_service() {
  local URL=$1
  if curl -s "$URL" > /dev/null; then
    eko $SHOW_DETAILS GREEN "Service at $URL is running."
  else
    eko true RED "Service at $URL is not running."
    exit 1
  fi
}

check_service "http://localhost:9115"
#check_service "http://localhost:8080"

# if to test api run ./api.sh
if [ "$TO_TEST" = "api" ]; then
    ./api.sh $SHOW_DETAILS
else 
    ./cli.sh $SHOW_DETAILS
fi
