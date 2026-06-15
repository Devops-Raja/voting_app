# ==========================================
# STAGE 1: Builder (Compile & Install   )
# ==========================================
FROM python:3.11-slim AS builder

# Prevent Python from writing .pyc files and enable unbuffered logging
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install system dependencies needed for compiling certain Python packages (e.g., gcc, psycopg2)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy only the dependency files to leverage Docker caching
COPY requirements.txt .

# Install dependencies into a specific local directory instead of global system site-packages
RUN pip install --no-cache-dir --user -r requirements.txt


# ==========================================
# STAGE 2: Runner (Final Production Image)
# ==========================================
FROM python:3.11-slim AS runner

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/home/appuser/.local/bin:${PATH}"

WORKDIR /app

# Create a non-root user for security compliance
RUN groupadd -g 10001 appuser && \
    useradd -u 10001 -g appuser -m -s /bin/bash appuser

# Copy the installed python packages from the builder stage
COPY --from=builder --chown=appuser:appuser /root/.local /home/appuser/.local

# Copy the application source code
COPY --chown=appuser:appuser . .

# Switch to the non-root user
USER appuser

# Expose the port your application listens on
EXPOSE 80

CMD ["gunicorn", "app:app", "-b", "0.0.0.0:80", "--log-file", "-", "--access-logfile", "-", "--workers", "4", "--keep-alive", "0"]