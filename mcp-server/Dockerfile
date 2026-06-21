# SearXNG MCP Server - Custom Build
# Based on OvertliDS/mcp-searxng-enhanced with HTTP mode enabled

FROM python:3.11-slim

# Set metadata
LABEL maintainer="searxng-docker"
LABEL description="MCP Server for SearXNG with HTTP/SSE transport"

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

# Clone the MCP server repository
RUN git clone https://github.com/OvertliDS/mcp-searxng-enhanced.git .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Create config directory
RUN mkdir -p /config

# Expose HTTP port
EXPOSE 8000

# Set environment variables
ENV SEARXNG_ENGINE_API_BASE_URL="http://searxng-core:8080/search"
ENV DESIRED_TIMEZONE="America/New_York"
ENV ODS_CONFIG_PATH="/config/ods_config.json"
ENV MCP_HTTP_HOST="0.0.0.0"
ENV MCP_HTTP_PORT="8000"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import httpx; httpx.get('http://localhost:8000/mcp').raise_for_status()" || exit 1

# Run in HTTP mode
CMD ["python", "mcp_server.py", "--http"]
