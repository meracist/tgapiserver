#!/bin/bash

# Create data directories if they don't exist
mkdir -p /app/data
mkdir -p /app/data/temp

echo "Starting Nginx server..."
# Force nginx to run in foreground later

echo "Starting health check server..."
python3 /app/health_server.py &
HC_PID=$!
echo "Health check server started with PID: $HC_PID"

echo "Starting Telegram Bot API server..."
telegram-bot-api  --api-id=${API_ID}  --api-hash=${API_HASH}  --local  --dir=/app/data  --temp-dir=/app/data/temp  --log=/app/data/bot-api.log  --http-port=8081 &

BOT_API_PID=$!
echo "Telegram Bot API server started with PID: $BOT_API_PID"

# Give bot API time to start
sleep 5

# Start nginx in foreground (important for container)
echo "Starting nginx in foreground..."
nginx -g "daemon off;"
