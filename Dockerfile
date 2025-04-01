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

# Create a simple health check server script
RUN echo 'import http.server\nimport socketserver\n\nPORT = 10000\n\nclass Handler(http.server.SimpleHTTPRequestHandler):\n    def do_GET(self):\n        self.send_response(200)\n        self.send_header("Content-type", "application/json")\n        self.end_headers()\n        self.wfile.write(b\'{"status":"ok","message":"Telegram Bot API Health Check"}\');\n\nwith socketserver.TCPServer(("", PORT), Handler) as httpd:\n    print("Health check server running at port", PORT)\n    httpd.serve_forever()' > /app/health_server.py

# Configure nginx
RUN echo 'server {\n    listen 80;\n    server_name localhost;\n\n    location / {\n        proxy_pass http://localhost:8081;\n        proxy_set_header Host $host;\n        proxy_set_header X-Real-IP $remote_addr;\n    }\n}' > /etc/nginx/sites-available/default

# Expose ports
EXPOSE 80 8081 10000

# Create startup script
RUN echo '#!/bin/bash\n\n# Start health check server\npython3 /app/health_server.py &\n\n# Create data directories if they don\'t exist\nmkdir -p /app/data\nmkdir -p /app/data/temp\n\necho "Starting Nginx server..."\nservice nginx start\n\necho "Starting Telegram Bot API server..."\n\n# Start the Telegram Bot API server\n/app/telegram-bot-api/bin/telegram-bot-api \\\n  --api-id=${API_ID} \\\n  --api-hash=${API_HASH} \\\n  --local \\\n  --dir=/app/data \\\n  --temp-dir=/app/data/temp \\\n  --log=/app/data/bot-api.log \\\n  --http-port=8081' > /app/start.sh &&    chmod +x /app/start.sh

# Run the start script
CMD ["/app/start.sh"]
