# =============================================================================
# SearXNG MCP Server - Production Build
# =============================================================================
# Based on: OvertliDS/mcp-searxng-enhanced (53 stars, actively maintained)
# Features: HTTP/SSE transport, web scraping, PDF parsing, rate limiting
# Standards: Multi-stage build, non-root user, health checks
# =============================================================================

# Stage 1: Builder
FROM python:3.11-slim as builder

WORKDIR /build

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Clone and prepare
RUN git clone --depth 1 https://github.com/OvertliDS/mcp-searxng-enhanced.git .

# Install dependencies in virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Stage 2: Runtime
FROM python:3.11-slim as runtime

LABEL maintainer="searxng-docker" \
      description="Production MCP Server for SearXNG with HTTP/SSE transport" \
      version="1.0.0"

# Install runtime dependencies only
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -r mcp \
    && useradd -r -g mcp -d /app -s /sbin/nologin mcp

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy application code
WORKDIR /app
COPY --from=builder /build /app

# Create config directory with proper permissions
RUN mkdir -p /config && chown -R mcp:mcp /app /config

# Switch to non-root user
USER mcp

# Environment defaults (can be overridden)
ENV SEARXNG_ENGINE_API_BASE_URL="http://searxng-core:8080/search" \
    DESIRED_TIMEZONE="Europe/Moscow" \
    ODS_CONFIG_PATH="/config/ods_config.json" \
    MCP_HTTP_HOST="0.0.0.0" \
    MCP_HTTP_PORT="8000" \
    PYTHONUNBUFFERED="1" \
    PYTHONDONTWRITEBYTECODE="1"

# Expose HTTP port
EXPOSE 8000

# Health check endpoint
HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
    CMD python -c "import httpx; r = httpx.get('http://localhost:8000/health', timeout=5.0); r.raise_for_status()" || exit 1

# Run in HTTP mode
CMD ["python", "mcp_server.py", "--http"]
