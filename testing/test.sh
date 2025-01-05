#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <api|cli>"
    exit 1
fi

TEST_TYPE=$1

if [ "$TEST_TYPE" == "api" ]; then
    
    echo "Part 1 Testing (no passes in database):"
    PYTHONWARNINGS="ignore" python3 -m unittest tests/api_1.py
    if [ $? -ne 0 ]; then
        echo "tests/api_1.py failed."
        exit 1
    fi

    echo "Part 2 Testing (database populated with passes):"
    PYTHONWARNINGS="ignore" python3 -m unittest tests/api_2.py
    if [ $? -ne 0 ]; then
        echo "tests/api_2.py failed."
        exit 1
    fi

elif [ "$TEST_TYPE" == "cli" ]; then
    
    echo "Part 1 Testing (no passes in database):"
    PYTHONWARNINGS="ignore" python3 -m unittest tests.cli_1
    if [ $? -ne 0 ]; then
        echo "tests/cli_1.py failed."
        exit 1
    fi

    echo "Part 2 Testing (database populated with passes):"
    PYTHONWARNINGS="ignore" python3 -m unittest tests/cli_2.py
    if [ $? -ne 0 ]; then
        echo "tests/cli_2.py failed."
        exit 1
    fi

    echo "Part 3 Testing (logout tests):"
    PYTHONWARNINGS="ignore" python3 -m unittest tests/cli_3.py
    if [ $? -ne 0 ]; then
        echo "tests/cli_3.py failed."
        exit 1
    fi

else
    echo "Invalid parameter. Use 'api' or 'cli'."
    exit 1
fi

echo "All tests passed!"
