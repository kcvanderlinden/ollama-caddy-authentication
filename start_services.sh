#!/bin/bash

# Print the environment variable for debugging
# echo "OLLAMA_API_KEY: '$OLLAMA_API_KEY'"

# Ensure required environment variables are set
if [ -z "$OLLAMA_API_KEY" ]; then
    echo "OLLAMA_API_KEY is not set. Exiting."
    exit 1
fi

if [ -z "$OLLAMA_ENDPOINT" ]; then
    echo "OLLAMA_ENDPOINT is not set. Exiting."
    exit 1
fi

# Start caddy in the background
caddy run --config /etc/caddy/Caddyfile &
CADDY_PID=$!

# Function to check process status
check_process() {
    wait $1
    STATUS=$?
    if [ $STATUS -ne 0 ]; then
        echo "Process $2 ($1) has exited with status $STATUS"
        exit $STATUS
    fi
}