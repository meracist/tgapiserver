FROM ubuntu:20.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install dependencies
RUN apt-get update &&    apt-get upgrade -y &&    apt-get install -y    build-essential    make    git    zlib1g-dev    libssl-dev    gperf    cmake    g++    python3    python3-pip    nginx    && apt-get clean    && rm -rf /var/lib/apt/lists/*

# Clone and build the telegram-bot-api
WORKDIR /app
RUN git clone --recursive https://github.com/tdlib/telegram-bot-api.git &&    cd telegram-bot-api &&    rm -rf build &&    mkdir build &&    cd build &&    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=.. .. &&    cmake --build . --target install

# Create necessary directories
RUN mkdir -p /app/data /app/data/temp

# Create a simple health check server script using cat instead of echo
RUN cat > /app/health_server.py << 'EOF'
import http.server
import socketserver

PORT = 10000

class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "application/json")
        self.end_headers()
        self.wfile.write(b'{"status":"ok","message":"Telegram Bot API Health Check"}')

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print("Health check server running at port", PORT)
    httpd.serve_forever()
EOF

# Configure nginx
RUN cat > /etc/nginx/sites-available/default << 'EOF'
server {
    listen 80;
    server_name localhost;

    location / {
        proxy_pass http://localhost:8081;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

# Expose ports
EXPOSE 80 8081 10000

# Create startup script using cat
RUN cat > /app/start.sh << 'EOF'
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
/app/telegram-bot-api/bin/telegram-bot-api  --api-id=${API_ID}  --api-hash=${API_HASH}  --local  --dir=/app/data  --temp-dir=/app/data/temp  --log=/app/data/bot-api.log  --http-port=8081
EOF

RUN chmod +x /app/start.sh

# Run the start script
CMD ["/app/start.sh"]
