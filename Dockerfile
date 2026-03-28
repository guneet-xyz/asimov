FROM node:22-slim AS builder

WORKDIR /app

# Copy package files first for better layer caching
COPY package.json package-lock.json ./
RUN npm ci --ignore-scripts

# Copy TypeScript source and config
COPY src/ src/
COPY tsconfig.json ./

# Build TypeScript
RUN npx tsc

# --- Production image ---
FROM node:22-slim

# Install Docker CLI (for spawning agent containers via host Docker socket)
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y docker-ce-cli \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy package files and install production dependencies only
COPY package.json package-lock.json ./
RUN npm ci --omit=dev --ignore-scripts

# Copy compiled output from builder
COPY --from=builder /app/dist/ dist/

# Copy container assets (skills + agent-runner source, read at runtime)
COPY container/skills/ container/skills/
COPY container/agent-runner/ container/agent-runner/

# Create directories that may not exist yet on a fresh deployment
RUN mkdir -p store groups data logs

CMD ["node", "dist/index.js"]
