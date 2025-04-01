FROM ubuntu:20.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install dependencies
RUN apt-get update &&    apt-get upgrade -y &&    apt-get install -y    build-essential    make    git    zlib1g-dev    libssl-dev    gperf    cmake    g++    nginx    && apt-get clean    && rm -rf /var/lib/apt/lists/*

# Clone and build the telegram-bot-api
WORKDIR /app
RUN git clone --recursive https://github.com/tdlib/telegram-bot-api.git &&    cd telegram-bot-api &&    rm -rf build &&    mkdir build &&    cd build &&    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=.. .. &&    cmake --build . --target install

# Create necessary directories
RUN mkdir -p /app/data /app/data/temp

# Create health check file
RUN echo '{"status":"ok"}' > /app/health.json

# Configure nginx 
RUN echo 'server {\n    listen 8080;\n    location = / {\n        root /app;\n        try_files /health.json =404;\n    }\n    location / {\n        proxy_pass http://localhost:8081;\n        proxy_set_header Host $host;\n        proxy_set_header X-Real-IP $remote_addr;\n    }\n}' > /etc/nginx/sites-available/default

# Expose ports
EXPOSE 8080 8081

# Set the entrypoint command
CMD service nginx start &&    /app/telegram-bot-api/bin/telegram-bot-api    --api-id=${API_ID}    --api-hash=${API_HASH}    --local    --dir=/app/data    --temp-dir=/app/data/temp    --log=/app/data/bot-api.log    --http-port=8081
