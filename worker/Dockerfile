# ==========================================
# STAGE 1: SDK Image (Build & Publish)
# ==========================================
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS builder
WORKDIR /source

# 1. Copy only the project file and restore dependencies (Optimizes Docker Caching)
COPY Worker.csproj .
RUN dotnet restore

# 2. Copy the remaining source files (Program.cs, etc.) and build
COPY . .
RUN dotnet publish Worker.csproj -c Release -o /app/publish --no-restore


# ==========================================
# STAGE 2: Runtime Image (Production Execution)
# ==========================================
FROM mcr.microsoft.com/dotnet/runtime:8.0 AS runner
WORKDIR /app

# Security: Create a non-root system user for application execution
RUN groupadd -g 10001 appuser && \
    useradd -u 10001 -g appuser -m -s /bin/bash appuser

# Copy the compiled binaries from the builder stage
COPY --from=builder --chown=appuser:appuser /app/publish .



# Explicitly invoke using the absolute path
ENTRYPOINT ["dotnet", "Worker.dll"]