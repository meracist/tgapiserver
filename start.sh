#!/bin/bash

# Start health check server
python3 /app/health_server.py &

# Create data directories if they don't exist
mkdir -p /app/data
mkdir -p /app/data/temp

echo "Starting Nginx server..."
service nginx start

echo "Starting Telegram Bot API server..."

# Start the Telegram Bot API server
telegram-bot-api  --api-id=${API_ID}  --api-hash=${API_HASH}  --local  --dir=/app/data  --temp-dir=/app/data/temp  --log=/app/data/bot-api.log  --http-port=8081
