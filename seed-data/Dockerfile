FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /seed

# 1. Install ApacheBench (ab)
RUN apt-get update && \
    apt-get install -y apache2-utils && \
    rm -rf /var/lib/apt/lists/*

# 2. Copy code files into the working directory
COPY . .

# 3. Give execution rights to the shell script
RUN chmod +x generate-votes.sh

# 4. RUN python script first to generate files, THEN launch the load testing script
CMD ["sh", "-c", "python make-data.py && ./generate-votes.sh"]