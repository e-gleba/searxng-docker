# =============================================================================
# SearXNG Docker Stack - Endpoint Map
# =============================================================================
# Complete reference of all available endpoints, health checks, and APIs
# =============================================================================

## 🌐 Public Endpoints (Browser Access)

### SearXNG Core (Port 8080)
| Endpoint | Method | Description | Auth |
|----------|--------|-------------|------|
| `http://localhost:8080/` | GET | Web UI - Search interface | No |
| `http://localhost:8080/search?q={query}` | GET | Search with query | No |
| `http://localhost:8080/search?q={query}&format=json` | GET | JSON API response | No |
| `http://localhost:8080/preferences` | GET | User preferences page | No |
| `http://localhost:8080/about` | GET | About page | No |

### MCP Server (Port 8000)
| Endpoint | Method | Description | Auth |
|----------|--------|-------------|------|
| `http://localhost:8000/health` | GET | Health check endpoint | No |
| `http://localhost:8000/mcp` | POST | MCP protocol endpoint | No |
| `http://localhost:8000/sse` | GET | Server-Sent Events stream | No |

---

## 🔧 Health Check Endpoints (Docker/Monitoring)

### Valkey Cache
```bash
# Internal health check (used by Docker)
docker exec searxng-valkey valkey-cli ping
# Expected: PONG

# From host
docker exec searxng-valkey valkey-cli INFO server | grep -E "redis_version|uptime"
```

### SearXNG Core
```bash
# Docker health check
curl -f http://localhost:8080/healthz
# Expected: HTTP 200

# Detailed status
curl -s http://localhost:8080/search?q=test&format=json | jq '.results | length'
# Expected: number > 0
```

### MCP Server
```bash
# Docker health check
curl -f http://localhost:8000/health
# Expected: {"status": "healthy", "timestamp": "..."}

# MCP tools list
curl -X POST http://localhost:8000/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

---

## 📊 Monitoring Commands

### Check All Services
```bash
# Status overview
docker compose ps

# Detailed health
docker inspect --format='{{.Name}}: {{.State.Health.Status}}' $(docker compose ps -q)
```

### Real-time Logs
```bash
# All services
docker compose logs -f

# Specific service with timestamps
docker compose logs -f --timestamps core

# Last 100 lines
docker compose logs --tail=100 mcp
```

### Resource Usage
```bash
# CPU and memory
docker stats --no-stream searxng-core searxng-valkey searxng-mcp
```

---

## 🔌 MCP Tools (for LLM Clients)

### Available Tools
| Tool | Description | Parameters |
|------|-------------|------------|
| `search_web` | Web search via SearXNG | `query: str`, `category: str` |
| `get_website` | Scrape website content | `url: str` |
| `get_current_datetime` | Current date/time | none |

### Tool Examples

#### search_web
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {
    "name": "search_web",
    "arguments": {
      "query": "rust programming",
      "category": "general"
    }
  }
}
```

#### get_website
```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "tools/call",
  "params": {
    "name": "get_website",
    "arguments": {
      "url": "https://example.com"
    }
  }
}
```

---

## 🧪 Testing Endpoints

### Quick Health Check
```bash
# One-liner to check all services
echo "SearXNG: $(curl -sf http://localhost:8080/healthz > /dev/null && echo '✓' || echo '✗')" && \
echo "MCP: $(curl -sf http://localhost:8000/health > /dev/null && echo '✓' || echo '✗')" && \
echo "Valkey: $(docker exec searxng-valkey valkey-cli ping 2>/dev/null | grep -q PONG && echo '✓' || echo '✗')"
```

### Search Test
```bash
curl -s "http://localhost:8080/search?q=docker&format=json" | jq -r '.results[:3][] | "\(.title)\n\(.url)\n"'
```

### MCP Connection Test
```bash
# List available tools
curl -X POST http://localhost:8000/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | jq '.result.tools[].name'
```

---

## 🔐 Security Notes

- **No authentication required** - Designed for local/development use
- **Internal network only** - Valkey not exposed to host
- **Read-only config** - core-config mounted as :ro
- **Non-root MCP** - Runs as mcp user
- **Resource limits** - Memory limits enforced via deploy.resources

---

## 📈 Performance Endpoints

### SearXNG Stats
```bash
# Check cache hit rate
docker exec searxng-valkey valkey-cli INFO stats | grep -E "keyspace_hits|keyspace_misses"

# Memory usage
docker exec searxng-valkey valkey-cli INFO memory | grep used_memory_human
```

### Request Latency
```bash
# SearXNG response time
time curl -s http://localhost:8080/search?q=test > /dev/null

# MCP response time
time curl -X POST http://localhost:8000/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' > /dev/null
```

---

## 🆘 Troubleshooting Endpoints

### Service Won't Start
```bash
# Check logs with full output
docker compose logs --no-log-prefix core 2>&1 | tail -50

# Verify config syntax
docker run --rm -v $(pwd)/core-config:/etc/searxng:ro searxng/searxng:latest python -c "import yaml; yaml.safe_load(open('/etc/searxng/settings.yml'))"
```

### Network Issues
```bash
# Test internal connectivity
docker exec searxng-mcp curl -s http://searxng-core:8080/healthz

# Check network
docker network inspect searxng-internal
```

### Port Conflicts
```bash
# Check what's using ports
sudo lsof -i :8080
sudo lsof -i :8000
```

---

## 📝 Environment Variables Reference

### MCP Server
| Variable | Default | Description |
|----------|---------|-------------|
| `SEARXNG_ENGINE_API_BASE_URL` | `http://searxng-core:8080/search` | SearXNG endpoint |
| `MCP_HTTP_HOST` | `0.0.0.0` | Bind address |
| `MCP_HTTP_PORT` | `8000` | HTTP port |
| `DESIRED_TIMEZONE` | `Europe/Moscow` | Timezone for datetime tool |
| `CACHE_TTL_MINUTES` | `5` | Cache TTL |
| `RATE_LIMIT_REQUESTS_PER_MINUTE` | `10` | Rate limit |

### SearXNG Core
| Variable | Default | Description |
|----------|---------|-------------|
| `SEARXNG_BASE_URL` | `http://localhost:8080/` | Public URL |
| `SEARXNG_SECRET` | `changeme...` | Secret key (CHANGE THIS!) |
