#!/bin/bash

# Create directories if they don't exist
mkdir -p /app/data
mkdir -p /app/data/temp

echo "Starting Telegram Bot API server..."
echo "API_ID: ${API_ID}"
echo "API_HASH: ${API_HASH} (hidden for security)"
echo "Data directory: /app/data"

# Start the Telegram Bot API server with persistent storage
exec /app/telegram-bot-api/bin/telegram-bot-api  --api-id=${API_ID}  --api-hash=${API_HASH}  --local  --dir=/app/data  --temp-dir=/app/data/temp  --log=/app/data/bot-api.log  --verbosity=2  --max-webhook-connections=100  --http-port=8081
