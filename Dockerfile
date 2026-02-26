# Use a lightweight Linux base
FROM ubuntu:24.04

# Install base dependencies, Python, pipx, and Node.js 22 (LTS)
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    git \
    python3 \
    python3-pip \
    pipx \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install AI CLIs via npm
# codex: https://github.com/openai/codex
# opencode: https://github.com/anomalyco/opencode
# qwen-code: https://github.com/QwenLM/qwen-code
RUN npm install -g @qwen-code/qwen-code @openai/codex opencode-ai

# Install Kimi Code CLI via pipx
# kimi-cli: https://github.com/MoonshotAI/kimi-cli
RUN pipx install --python python3 kimi-cli

# Setup CLI paths/symlinks
# Note: npm -g usually installs binaries to /usr/bin or /usr/local/bin depending on setup.
# On the official Node image it is /usr/local/bin, via nodesource/apt it is often /usr/bin.
# We create symlinks to ensure they are available at the expected /usr/local/bin paths.
RUN ln -sf $(which codex) /usr/local/bin/codex \
    && ln -sf $(which opencode) /usr/local/bin/opencode \
    && ln -sf $(which qwen) /usr/local/bin/qwen \
    && ln -sf /root/.local/bin/kimi /usr/local/bin/kimi

# Configurable args for CLI locations
# These now point to the symlinks we created
ARG CODEX_PATH=/usr/local/bin/codex
ARG OPENCODE_PATH=/usr/local/bin/opencode
ARG QWEN_PATH=/usr/local/bin/qwen
ARG KIMI_PATH=/usr/local/bin/kimi

# Set environment variables for the paths so they can be found easily
ENV CODEX_PATH=${CODEX_PATH}
ENV OPENCODE_PATH=${OPENCODE_PATH}
ENV QWEN_PATH=${QWEN_PATH}
ENV KIMI_PATH=${KIMI_PATH}
ENV OPENCODE_CONFIG=/root/.config/opencode/opencode.json

# Add entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Set working directory to /app so tools that default to CWD don't run in /
WORKDIR /app

# Default entrypoint
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/bin/bash"]
