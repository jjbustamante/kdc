# Multi-architecture Dockerfile - demonstrating complexity
# This showcases the pain points buildpacks solve

FROM python:3.11-slim

# Define build argument for target platform
ARG TARGETPLATFORM
ARG BUILDPLATFORM

# Install system dependencies required for native compilation
# This gets complex quickly when dealing with different architectures
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    libc6-dev \
    libffi-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Architecture-specific handling for bcrypt compilation
# This is where Dockerfile complexity explodes
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
        apt-get update && apt-get install -y \
        gcc-aarch64-linux-gnu \
        g++-aarch64-linux-gnu \
        && rm -rf /var/lib/apt/lists/*; \
    fi

# Set environment variables for cross-compilation if needed
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
        export CC=aarch64-linux-gnu-gcc && \
        export CXX=aarch64-linux-gnu-g++; \
    fi

# Create app directory
WORKDIR /app

# Copy requirements first for better layer caching
COPY requirements.txt .

# Install Python dependencies
# This often fails with native dependencies on different architectures
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .

# Create non-root user for security
RUN useradd --create-home --shell /bin/bash app \
    && chown -R app:app /app
USER app

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:5000/health')" || exit 1

# Run the application
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "app:app"]