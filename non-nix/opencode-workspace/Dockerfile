# Single stage Dockerfile for opencode
FROM ubuntu:24.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install opencode using official script
RUN curl -fsSL https://opencode.ai/install | bash && \
    ln -sf /root/.opencode/bin/opencode /usr/local/bin/opencode

RUN mkdir -p /workspace/serve

# Set working directory
WORKDIR /workspace

# Copy opencode.json
COPY opencode.json /workspace/

# CMD ["opencode", "serve", "--port", "4096", "--hostname", "0.0.0.0"]

CMD ["tail", "-f", "/dev/null"]
