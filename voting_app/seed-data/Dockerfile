# ==========================================
# STAGE 1: Builder (Generate payloads)
# ==========================================
FROM python:3.11-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Copy the Python script into the builder stage
COPY make-data.py .

# Run the script to generate 'posta' and 'postb' at build time
RUN python make-data.py


# ==========================================
# STAGE 2: Runner (Production Execution)
# ==========================================
FROM python:3.11-slim AS runner

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /seed

# Security: Create a non-root user to run the scripts safely
RUN groupadd -g 10001 appuser && \
    useradd -u 10001 -g appuser -m -s /bin/bash appuser

# 1. Copy the pre-generated data files from the builder stage
COPY --from=builder --chown=appuser:appuser /app/posta ./
COPY --from=builder --chown=appuser:appuser /app/postb ./

# 2. Copy your execution shell script into the /seed directory
COPY --chown=appuser:appuser generate-votes.sh ./generate-votes.sh

# Give execution permissions to the shell script
RUN chmod +x ./generate-votes.sh

# Switch to the non-root user
USER appuser

# Execute the shell script when the container launches
CMD ["./generate-votes.sh"]