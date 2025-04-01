FROM ubuntu:20.04 AS builder

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install dependencies
RUN apt-get update &&    apt-get upgrade -y &&    apt-get install -y    build-essential    make    git    zlib1g-dev    libssl-dev    gperf    cmake    g++    python3    python3-pip    && apt-get clean    && rm -rf /var/lib/apt/lists/*

# Clone and build the telegram-bot-api
WORKDIR /app
RUN git clone --recursive https://github.com/tdlib/telegram-bot-api.git &&    cd telegram-bot-api &&    rm -rf build &&    mkdir build &&    cd build &&    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=.. .. &&    cmake --build . --target install

# Second stage to create a smaller image
FROM ubuntu:20.04

# Install runtime dependencies only
RUN apt-get update &&    apt-get install -y    libssl1.1    python3    python3-pip    && apt-get clean    && rm -rf /var/lib/apt/lists/*

# Copy the built binary from the builder stage
COPY --from=builder /app/telegram-bot-api/bin/telegram-bot-api /usr/local/bin/

# Create necessary directories
RUN mkdir -p /app/data /app/data/temp /app/health

# Create health check endpoint
RUN echo '{"status":"ok"}' > /app/health/index.html

# Copy startup scripts
COPY start.sh /app/start.sh
COPY health_server.py /app/health_server.py
RUN chmod +x /app/start.sh

# Expose ports
EXPOSE 8081 10000

# Run the start script
CMD ["/app/start.sh"]
