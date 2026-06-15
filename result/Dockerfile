# ==========================================
# STAGE 1: Builder (Install & Clean)
# ==========================================
FROM node:18-slim AS builder
WORKDIR /app

COPY package*.json ./
# Clean production-only install (keeps devDependencies out of the image)
RUN npm ci --only=production && npm cache clean --force


# ==========================================
# STAGE 2: Runner (Production-Hardened)
# ==========================================
FROM node:18-slim AS runner

ENV NODE_ENV=production \
    PORT=80

WORKDIR /usr/local/app

# 1. Install production system utilities (curl for healthcheck, tini for signal management)
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl tini && \
    rm -rf /var/lib/apt/lists/*

# 2. Security: Create a non-root system user
RUN groupadd -g 10001 appuser && \
    useradd -u 10001 -g appuser -m -s /bin/bash appuser

# 3. Copy only production node_modules from builder
COPY --from=builder --chown=appuser:appuser /app/node_modules ./node_modules
COPY --chown=appuser:appuser package.json server.js ./
COPY --chown=appuser:appuser . .

# Switch to the secure non-root user
USER appuser

EXPOSE 80

# Use tini to handle PID 1 gracefully, passing signals directly to Node
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "server.js"]