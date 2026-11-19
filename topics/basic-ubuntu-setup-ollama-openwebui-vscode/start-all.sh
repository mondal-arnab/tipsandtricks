#!/bin/bash

# Start Ollama service
echo "Starting Ollama service..."
sudo systemctl start ollama

# Wait for Ollama to be ready
echo "Waiting for Ollama to start..."
while ! curl -f http://localhost:11434 2>/dev/null; do
    sleep 1
done
echo "Ollama is ready!"

# Start Open WebUI container if it's not already running
echo "Starting Open WebUI..."
if ! docker ps --format '{{.Names}}' | grep -q open-webui; then
    docker run -d \
        --name open-webui \
        --restart always \
        -p 3000:8080 \
        -v open-webui:/app/backend/data \
        -e OLLAMA_BASE_URL=http://localhost:11434 \
        ghcr.io/open-webui/open-webui:main
    echo "Open WebUI started successfully!"
else
    echo "Open WebUI is already running."
fi

echo "All services started successfully!"

echo "Press any key to continue..."
read -r