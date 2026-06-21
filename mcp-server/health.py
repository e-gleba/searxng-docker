"""
Health check endpoint for MCP server.
Provides /health endpoint for Docker health checks and monitoring.
"""

from fastapi import FastAPI
from fastapi.responses import JSONResponse
import httpx
import os
from datetime import datetime, timezone

app = FastAPI()

@app.get("/health")
async def health_check():
    """
    Health check endpoint for Docker and monitoring systems.
    Returns service status and connectivity information.
    """
    health_status = {
        "status": "healthy",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "service": "searxng-mcp",
        "version": "1.0.0"
    }
    
    # Check SearXNG connectivity
    searxng_url = os.getenv("SEARXNG_ENGINE_API_BASE_URL", "http://searxng-core:8080/search")
    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            response = await client.get(f"{searxng_url}?q=test&format=json")
            response.raise_for_status()
            health_status["searxng"] = {
                "status": "connected",
                "url": searxng_url,
                "response_time_ms": response.elapsed.total_seconds() * 1000
            }
    except Exception as e:
        health_status["status"] = "degraded"
        health_status["searxng"] = {
            "status": "error",
            "error": str(e)
        }
    
    return JSONResponse(content=health_status)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
