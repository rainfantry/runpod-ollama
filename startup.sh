#!/bin/bash

# RunPod Startup Script - Ollama Server
# Auto-installs and starts Ollama on port 11434

set -e

# Auto-install Ollama if not present
if ! command -v ollama &>/dev/null; then
    echo "Installing Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
fi

# Bind to all interfaces for external access
export OLLAMA_HOST="0.0.0.0:11434"

# Start Ollama server in the background
ollama serve &
OLLAMA_PID=$!

# Wait for server to be ready
echo "Waiting for Ollama server to start..."
for i in $(seq 1 30); do
    if curl -sf http://localhost:11434 &>/dev/null; then
        echo "Ollama server is running on port 11434"
        echo "API endpoint: http://0.0.0.0:11434"
        break
    fi
    sleep 1
done

# Keep the container alive
wait $OLLAMA_PID
