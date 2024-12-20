#!/bin/bash

# Utility functions for testing

# printing to terminal

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
LIME='\033[0;92m'
YELLOW='\033[0;93m'
NC='\033[0m' # No Color

eko() {
    # eg eko RED "Hello, World!"
    if [ "$1" = true ]; then
        echo -e "${!2}${3}${NC}"
    fi
}

