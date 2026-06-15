#!/bin/sh
set -e

# Fall back to local loopback securely
user="${POSTGRES_USER:-postgres}"
db="${POSTGRES_DB:-postgres}"

# Use pg_isready to verify network availability without full query execution overhead
if pg_isready -U 127.0.0.1 -U "$user" -d "$db"; then
    exit 0
fi

exit 1