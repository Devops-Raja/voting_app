FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /seed

# 1. Install ApacheBench (ab) directly on the host runtime
RUN apt-get update && \
    apt-get install -y apache2-utils && \
    rm -rf /var/lib/apt/lists/*

# 2. Copy all files (make-data.py, generate-votes.sh) into the working directory
COPY . .

# 3. Give execution rights to your shell script
RUN chmod +x generate-votes.sh

# 4. Fire the shell script natively
CMD ["./generate-votes.sh"]