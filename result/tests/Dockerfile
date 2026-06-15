# ==========================================
# STAGE 1: Builder (Install Node dependencies)
# ==========================================
FROM node:20-slim AS builder
WORKDIR /app

# Copy package files first if you have them to leverage Docker caching.
# If you don't have external npm dependencies yet, these lines can be safely ignored.
COPY package*.json ./
RUN if [ -f package.json ]; then npm ci; fi


# ==========================================
# STAGE 2: Runner (Production Execution)
# ==========================================
FROM node:20-slim AS runner
WORKDIR /app

# Security: Create a non-root system user for application execution
RUN groupadd -g 10001 appuser && \
    useradd -u 10001 -g appuser -m -s /bin/bash appuser

# 1. Copy dependencies from the builder stage
COPY --from=builder --chown=appuser:appuser /app ./

# 2. Copy your local scripts (render.js and test.sh)
COPY --chown=appuser:appuser render.js ./
COPY --chown=appuser:appuser test.sh ./

# Make sure the shell script has execution permissions
RUN chmod +x ./test.sh

# Switch to the non-root user
USER appuser

# Execute the shell script when the container boots up
CMD ["./test.sh"]