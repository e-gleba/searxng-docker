#!/usr/bin/env python3
"""
SearXNG MCP Server with SSE transport wrapper.
Provides HTTP health endpoint and SSE transport for MCP protocol.
"""

import os
import sys
import asyncio
from contextlib import asynccontextmanager

import httpx
from fastmcp import FastMCP
from starlette.applications import Starlette
from starlette.responses import JSONResponse
from starlette.routing import Route
import uvicorn

# Import MCP server from mcp-searxng
from mcp_searxng import mcp as mcp_server

# Configuration
SEARXNG_URL = os.getenv("SEARXNG_URL", "http://searxng:8080")
MCP_HOST = os.getenv("MCP_HOST", "0.0.0.0")
MCP_PORT = int(os.getenv("MCP_PORT", "8080"))

# Health check endpoint
async def health_check(request):
    """Health check endpoint for Docker healthcheck."""
    try:
        async with httpx.AsyncClient() as client:
            # Check if SearXNG is reachable
            response = await client.get(f"{SEARXNG_URL}/healthz", timeout=5.0)
            if response.status_code == 200:
                return JSONResponse({
                    "status": "healthy",
                    "searxng": "connected",
                    "transport": "sse",
                    "url": SEARXNG_URL
                })
            else:
                return JSONResponse({
                    "status": "degraded",
                    "searxng": "unreachable",
                    "transport": "sse"
                }, status_code=503)
    except Exception as e:
        return JSONResponse({
            "status": "unhealthy",
            "error": str(e),
            "transport": "sse"
        }, status_code=503)

# Info endpoint
async def info(request):
    """Info endpoint showing server configuration."""
    return JSONResponse({
        "name": "searxng-mcp-server",
        "version": "1.0.0",
        "transport": "sse",
        "searxng_url": SEARXNG_URL,
        "mcp_endpoint": f"http://{MCP_HOST}:{MCP_PORT}/sse",
        "tools": [
            {
                "name": "searxng_search",
                "description": "Search the web using SearXNG",
                "parameters": {
                    "query": "string (required)",
                    "categories": "string (optional, comma-separated)",
                    "engines": "string (optional, comma-separated)",
                    "language": "string (optional)",
                    "time_range": "string (optional: day, week, month, year)"
                }
            }
        ]
    })

# Create Starlette app with health and info routes
app = Starlette(
    routes=[
        Route("/health", health_check),
        Route("/info", info),
    ]
)

@asynccontextmanager
async def lifespan(app):
    """Lifespan context manager for startup/shutdown."""
    # Mount MCP SSE server
    mcp_app = mcp_server.sse_app()
    app.mount("/sse", mcp_app)
    print(f"🚀 SearXNG MCP Server started")
    print(f"   Health: http://{MCP_HOST}:{MCP_PORT}/health")
    print(f"   Info:   http://{MCP_HOST}:{MCP_PORT}/info")
    print(f"   MCP:    http://{MCP_HOST}:{MCP_PORT}/sse")
    print(f"   SearXNG: {SEARXNG_URL}")
    yield

app.router.lifespan_context = lifespan

def main():
    """Main entry point."""
    uvicorn.run(
        app,
        host=MCP_HOST,
        port=MCP_PORT,
        log_level="info",
        access_log=True
    )

if __name__ == "__main__":
    main()
