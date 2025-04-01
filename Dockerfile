FROM ubuntu:20.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install dependencies
RUN apt-get update &&    apt-get upgrade -y &&    apt-get install -y    build-essential    make    git    zlib1g-dev    libssl-dev    gperf    cmake    g++    curl    wget    && apt-get clean    && rm -rf /var/lib/apt/lists/*

# Clone the telegram-bot-api repository
WORKDIR /app
RUN git clone --recursive https://github.com/tdlib/telegram-bot-api.git

# Build the telegram-bot-api
WORKDIR /app/telegram-bot-api
RUN rm -rf build &&    mkdir build &&    cd build &&    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=.. .. &&    cmake --build . --target install &&    cd .. &&    ls -l bin/telegram-bot-api*

# Create data directories
RUN mkdir -p /app/data /app/data/temp

# Set permissions for the start script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Expose port 8081 for the Bot API server
EXPOSE 8081

# Run the start script
CMD ["/app/start.sh"]
