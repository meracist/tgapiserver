#!/bin/bash

# Start health check server in background
echo "Starting health check server on port 10000..."
python3 /app/health_server.py &
HEALTH_PID=$!

# Create directories if they don't exist
mkdir -p /app/data
mkdir -p /app/data/temp

echo "Starting Telegram Bot API server..."
echo "API_ID: ${API_ID}"
echo "API_HASH: ${API_HASH} (hidden for security)"
echo "Data directory: /app/data"

# Start the Telegram Bot API server with persistent storage
# Using nohup to ensure it doesn't get killed
nohup /usr/local/bin/telegram-bot-api  --api-id=${API_ID}  --api-hash=${API_HASH}  --local  --dir=/app/data  --temp-dir=/app/data/temp  --log=/app/data/bot-api.log  --verbosity=2  --max-webhook-connections=100  > /app/data/telegram-bot-api.out 2>&1 &

BOT_API_PID=$!

echo "Telegram Bot API server started with PID: $BOT_API_PID"
echo "Health check server running with PID: $HEALTH_PID"

# Monitor log file to check for successful startup
echo "Waiting for Telegram Bot API server to initialize..."
timeout 180 tail -f /app/data/bot-api.log | grep -q "Telegram Bot API server started"
API_SERVER_STARTED=$?

if [ $API_SERVER_STARTED -eq 0 ]; then
  echo "Telegram Bot API server successfully started!"
else
  echo "WARNING: Did not detect successful startup message, but continuing..."
fi

echo "Service is now running. Monitoring logs..."

# Keep the container running and monitor both processes
while kill -0 $BOT_API_PID 2>/dev/null && kill -0 $HEALTH_PID 2>/dev/null; do
  sleep 10
  echo "Service health check: $(date)"
done

# If we get here, one of the processes died
echo "Service stopped. Checking which process died..."

if ! kill -0 $BOT_API_PID 2>/dev/null; then
  echo "ERROR: Bot API server process died. Checking logs..."
  tail -n 50 /app/data/bot-api.log
fi

if ! kill -0 $HEALTH_PID 2>/dev/null; then
  echo "ERROR: Health check server process died."
fi

echo "Exiting container..."
exit 1
