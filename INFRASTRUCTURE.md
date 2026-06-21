# Infrastructure Documentation

Complete endpoint map and service documentation for SearXNG Docker setup.

## Service Overview

| Service | Container | Port | Status | Purpose |
|---------|-----------|------|--------|---------|
| **SearXNG** | `searxng-core` | 8080 | ✅ Public | Search engine with web UI |
| **Valkey** | `searxng-valkey` | 6379 | 🔒 Internal | Redis-compatible cache |
| **MCP Server** | `searxng-mcp` | 8000 | ✅ Public | Model Context Protocol API |

---

## Endpoints Map

### SearXNG Search Engine (Port 8080)

**Base URL:** `http://localhost:8080`

| Endpoint | Method | Description | Example |
|----------|--------|-------------|---------|
| `/` | GET | Web search interface | `http://localhost:8080/` |
| `/search` | GET/POST | Search API | `http://localhost:8080/search?q=rust&format=json` |
| `/healthz` | GET | Health check | `http://localhost:8080/healthz` |
| `/stats` | GET | Usage statistics | `http://localhost:8080/stats` |
| `/preferences` | GET | User preferences UI | `http://localhost:8080/preferences` |

#### Search API Parameters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `q` | string | Search query (required) | `q=rust programming` |
| `format` | string | Output format: `json`, `csv`, `rss` | `format=json` |
| `categories` | string | Search categories | `categories=general,images` |
| `engines` | string | Specific engines | `engines=google,duckduckgo` |
| `language` | string | Language code | `language=en` |
| `pageno` | integer | Page number | `pageno=2` |
| `time_range` | string | Time filter: `day`, `month`, `year` | `time_range=week` |
| `safesearch` | integer | Safe search level: 0, 1, 2 | `safesearch=1` |

#### Quick Test Commands

```bash
# Basic search
curl "http://localhost:8080/search?q=rust&format=json" | jq '.results[0]'

# Search with categories
curl "http://localhost:8080/search?q=python&categories=it&format=json" | jq

# Health check
curl -I http://localhost:8080/healthz
```

---

### MCP Server (Port 8000)

**Base URL:** `http://localhost:8000`

| Endpoint | Method | Description | Example |
|----------|--------|-------------|---------|
| `/mcp` | POST | MCP protocol endpoint | See examples below |

#### Available MCP Tools

| Tool | Description | Parameters |
|------|-------------|------------|
| `search_web` | Web search via SearXNG | `query`, `category?`, `safesearch?`, `time_range?` |
| `get_website` | Scrape website content | `url` |
| `get_current_datetime` | Get current date/time | None |

#### MCP Protocol Examples

**List available tools:**
```bash
curl -X POST http://localhost:8000/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/list"
  }' | jq
```

**Search the web:**
```bash
curl -X POST http://localhost:8000/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 2,
    "method": "tools/call",
    "params": {
      "name": "search_web",
      "arguments": {
        "query": "rust programming",
        "category": "general"
      }
    }
  }' | jq
```

**Scrape a website:**
```bash
curl -X POST http://localhost:8000/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 3,
    "method": "tools/call",
    "params": {
      "name": "get_website",
      "arguments": {
        "url": "https://example.com"
      }
    }
  }' | jq
```

**Get current datetime:**
```bash
curl -X POST http://localhost:8000/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 4,
    "method": "tools/call",
    "params": {
      "name": "get_current_datetime",
      "arguments": {}
    }
  }' | jq
```

---

### Valkey Cache (Internal Only)

**Internal URL:** `redis://searxng-valkey:6379` (not exposed to host)

Valkey is used internally by SearXNG for caching. No direct access required.

---

## LLM Client Configuration

### Claude Desktop

Add to `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS) or `%APPDATA%\Claude\claude_desktop_config.json` (Windows):

```json
{
  "mcpServers": {
    "searxng": {
      "command": "docker",
      "args": ["exec", "-i", "searxng-mcp", "python", "mcp_server.py"]
    }
  }
}
```

### Cursor

Add to `.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "searxng": {
      "url": "http://localhost:8000/mcp"
    }
  }
}
```

### Generic MCP Client

```json
{
  "mcpServers": {
    "searxng": {
      "url": "http://localhost:8000/mcp"
    }
  }
}
```

---

## Infrastructure Commands

### Start Services

```bash
# Build and start all services
docker compose up -d --build

# Check status
docker compose ps

# View logs
docker compose logs -f
```

### Stop Services

```bash
# Stop all services
docker compose down

# Stop and remove volumes (WARNING: deletes cache)
docker compose down -v
```

### Health Checks

```bash
# Check all container health
docker compose ps

# SearXNG health
curl http://localhost:8080/healthz

# MCP server health
curl http://localhost:8000/mcp \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

### Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f core
docker compose logs -f valkey
docker compose logs -f mcp

# Last 100 lines
docker compose logs --tail=100 core
```

### Update

```bash
# Pull latest images
docker compose pull

# Rebuild MCP server
docker compose build mcp

# Restart services
docker compose up -d
```

---

## Network Architecture

```
┌─────────────────────────────────────────────────────┐
│              Host Machine (localhost)                │
├─────────────────────────────────────────────────────┤
│                                                      │
│  Port 8080 ──┐                                      │
│              ├─> searxng-core (SearXNG)             │
│              │     │                                 │
│              │     └─> searxng-valkey (Cache)       │
│              │           (Internal: 6379)           │
│              │                                       │
│  Port 8000 ──┴─> searxng-mcp (MCP Server)          │
│                    │                                 │
│                    └─> searxng-core (via network)   │
│                                                      │
└─────────────────────────────────────────────────────┘
```

All containers communicate via the `searxng-network` bridge network.

---

## Volumes

| Volume | Mount Point | Purpose |
|--------|-------------|---------|
| `core-data` | `/var/cache/searxng` | SearXNG cache and data |
| `valkey-data` | `/data` | Valkey persistence |

### Backup Volumes

```bash
# Backup SearXNG data
docker run --rm -v searxng_core-data:/data -v $(pwd):/backup alpine tar czf /backup/searxng-backup.tar.gz /data

# Restore
docker run --rm -v searxng_core-data:/data -v $(pwd):/backup alpine tar xzf /backup/searxng-backup.tar.gz -C /
```

---

## Environment Variables

### SearXNG Core

See `core-config/settings.yml` for all configuration options.

### MCP Server

| Variable | Default | Description |
|----------|---------|-------------|
| `SEARXNG_ENGINE_API_BASE_URL` | `http://searxng-core:8080/search` | SearXNG API endpoint |
| `DESIRED_TIMEZONE` | `America/New_York` | Timezone for datetime tool |
| `MCP_HTTP_HOST` | `0.0.0.0` | HTTP server bind address |
| `MCP_HTTP_PORT` | `8000` | HTTP server port |
| `RETURNED_SCRAPPED_PAGES_NO` | `3` | Max pages to return |
| `SCRAPPED_PAGES_NO` | `5` | Max pages to scrape |
| `PAGE_CONTENT_WORDS_LIMIT` | `5000` | Max words per page |
| `CITATION_LINKS` | `True` | Enable citation links |
| `MAX_IMAGE_RESULTS` | `10` | Max image results |
| `MAX_VIDEO_RESULTS` | `10` | Max video results |
| `MAX_FILE_RESULTS` | `5` | Max file results |
| `MAX_MAP_RESULTS` | `5` | Max map results |
| `MAX_SOCIAL_RESULTS` | `5` | Max social results |
| `TRAFILATURA_TIMEOUT` | `15` | Trafilatura timeout (seconds) |
| `SCRAPING_TIMEOUT` | `20` | Scraping timeout (seconds) |
| `CACHE_MAXSIZE` | `100` | Max cache entries |
| `CACHE_TTL_MINUTES` | `5` | Cache TTL (minutes) |
| `CACHE_MAX_AGE_MINUTES` | `30` | Max cache age (minutes) |
| `RATE_LIMIT_REQUESTS_PER_MINUTE` | `10` | Rate limit |
| `RATE_LIMIT_TIMEOUT_SECONDS` | `60` | Rate limit window |

---

## Troubleshooting

### Services Won't Start

```bash
# Check logs
docker compose logs

# Verify configuration
docker compose config

# Rebuild
docker compose up -d --build
```

### Port Already in Use

```bash
# Find process using port
lsof -i :8080
lsof -i :8000

# Stop process or change ports in docker-compose.yml
```

### MCP Server Connection Issues

```bash
# Test MCP endpoint
curl -X POST http://localhost:8000/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'

# Check MCP logs
docker compose logs mcp

# Restart MCP server
docker compose restart mcp
```

### SearXNG Not Responding

```bash
# Check SearXNG logs
docker compose logs core

# Test health endpoint
curl http://localhost:8080/healthz

# Restart SearXNG
docker compose restart core
```

---

## Security Notes

- **No Authentication**: This setup is designed for local/private use. No authentication is configured.
- **Network Isolation**: Services communicate via isolated Docker network.
- **Read-Only Configs**: SearXNG config mounted as read-only for security.
- **Resource Limits**: Valkey memory limited to 256MB with LRU eviction.

For public deployments, add:
- Reverse proxy (nginx/caddy) with SSL
- Authentication layer
- Rate limiting
- Firewall rules
