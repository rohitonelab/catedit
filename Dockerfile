# STAGE 1: Builder
FROM node:20-slim AS builder

WORKDIR /app

# Install build dependencies
COPY package*.json ./
RUN npm install --omit=dev --legacy-peer-deps

# Copy source
COPY . .

# Remove unnecessary dev files before copying to runtime
RUN rm -rf .git .github .vscode tests doc

# STAGE 2: Runtime (The Lean Image)
FROM node:20-slim AS runtime

WORKDIR /app

# Install FFmpeg and Chromium dependencies
# We install ONLY the shared libraries Chromium needs, not the full browser if possible,
# but 'chromium' is the safest way to get all the right libs for Remotion.
RUN apt-get update && apt-get install -y \
    ffmpeg \
    chromium \
    --no-install-recommends \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set Environment for Remotion to find the system Chromium
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# Copy production node_modules and app files from builder
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/scripts ./scripts
COPY --from=builder /app/.agents ./.agents

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3333
ENV TEMP_DIR=/tmp/hyperedit

# Ensure temp directory exists
RUN mkdir -p /tmp/hyperedit

# Expose the port
EXPOSE 3333

# Start the server
CMD ["node", "scripts/local-ffmpeg-server.js"]
