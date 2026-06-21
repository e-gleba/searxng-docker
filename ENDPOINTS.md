# Endpoint Reference — SearXNG Docker

Complete API documentation for the SearXNG Docker deployment.

---

## Public Endpoints

### SearXNG Core (Port 8080)

| Endpoint | Method | Description | Authentication |
|----------|--------|-------------|----------------|
| `/` | GET | Web UI — search interface | None |
| `/search?q={query}` | GET | Search with query | None |
| `/search?q={query}&format=json` | GET | JSON API response | None |
| `/preferences` | GET | User preferences page | None |
| `/about` | GET | About page | None |
| `/healthz` | GET | Health check endpoint | None |

---

## Search API

### Endpoint

```
GET /search
```

### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `q` | string | Yes | — | Search query (URL-encoded) |
| `format` | string | No | `html` | Response format: `html`, `json` |
| `categories` | string | No | `general` | Engine categories: `general`, `it`, `images`, `news`, `videos`, `files` |
| `engines` | string | No | — | Comma-separated engine names |
| `language` | string | No | `auto` | Language code: `en`, `ru`, `de`, `auto` |
| `time_range` | string | No | — | Time filter: `day`, `week`, `month`, `year` |
| `safesearch` | integer | No | `0` | Safe search level: `0`, `1`, `2` |
| `pageno` | integer | No | `1` | Result page number |

### Example Requests

**Basic search:**

```bash
curl -s "http://localhost:8080/search?q=std::vector&format=json"
```

**cppreference engine:**

```bash
curl -s "http://localhost:8080/search?q=std::unique_ptr&engines=cppreference&format=json"
```

**DevDocs engine:**

```bash
curl -s "http://localhost:8080/search?q=cmake+target_link_libraries&engines=devdocs&format=json"
```

**Filtered search:**

```bash
curl -s "http://localhost:8080/search?q=rust&categories=it&time_range=month&format=json"
```

### Response Format

```json
{
  "query": "std::vector",
  "number_of_results": 42,
  "results": [
    {
      "url": "https://en.cppreference.com/w/cpp/container/vector",
      "title": "std::vector - cppreference.com",
      "content": "std::vector is a sequence container that encapsulates dynamic size arrays.",
      "engine": "cppreference",
      "category": "it"
    }
  ],
  "answers": [],
  "corrections": [],
  "infoboxes": [],
  "suggestions": ["std::vector::push_back", "std::vector::emplace_back"]
}
```

---

## Health Check Endpoints

### SearXNG Core

```bash
# Docker health check (used internally)
curl -f http://localhost:8080/healthz
# Expected: HTTP 200

# Manual verification
curl -s http://localhost:8080/search?q=test&format=json | jq '.results | length'
# Expected: integer > 0
```

### Valkey Cache

```bash
# Docker health check (used internally)
docker exec searxng-valkey valkey-cli ping
# Expected: PONG

# Detailed status
docker exec searxng-valkey valkey-cli INFO server | grep -E 'redis_version|uptime_in_days'
```

---

## Monitoring Commands

### Service Status

```bash
# Overview
docker compose ps

# Detailed health status
docker inspect --format='{{.Name}}: {{.State.Health.Status}}' $(docker compose ps -q)
```

### Real-time Logs

```bash
# All services
docker compose logs -f

# Specific service with timestamps
docker compose logs -f --timestamps core

# Last N lines
docker compose logs --tail=100 core
```

### Resource Usage

```bash
# CPU and memory stats
docker stats --no-stream searxng-core searxng-valkey

# Continuous monitoring
watch -n 2 'docker stats --no-stream searxng-core searxng-valkey'
```

---

## Performance Endpoints

### Cache Statistics

```bash
# Hit/miss ratio
docker exec searxng-valkey valkey-cli INFO stats | grep -E 'keyspace_hits|keyspace_misses'

# Memory usage
docker exec searxng-valkey valkey-cli INFO memory | grep used_memory_human

# Connected clients
docker exec searxng-valkey valkey-cli INFO clients | grep connected_clients
```

### Request Latency

```bash
# Single request timing
time curl -s http://localhost:8080/search?q=test > /dev/null

# Multiple requests (average)
for i in {1..10}; do
  time curl -s http://localhost:8080/search?q=test$i > /dev/null
done 2>&1 | grep real | awk '{sum+=$2; n++} END {print "Average: " sum/n "s"}'
```

---

## Troubleshooting

### Service Won't Start

```bash
# Check logs
docker compose logs core
docker compose logs valkey

# Verify configuration
docker compose config --quiet

# Clean rebuild
docker compose down -v
docker compose up -d
```

### Port Already in Use

```bash
# Find process using port 8080
sudo lsof -i :8080
# or
sudo ss -tlnp | grep 8080

# Change port in .env
SEARXNG_PORT=9090
```

### No Search Results

```bash
# Check engine status
curl -s "http://localhost:8080/search?q=test&format=json" | jq '.engines'

# Verify network connectivity
docker exec searxng-core curl -I https://google.com

# Check engine configuration
docker exec searxng-core cat /etc/searxng/settings.yml | grep -A 5 'engines:'
```

### High Memory Usage

```bash
# Check current usage
docker stats --no-stream

# Reduce Valkey memory limit
# Edit .env:
VALKEY_MAX_MEMORY=128mb

# Restart services
docker compose down
docker compose up -d
```

---

## Environment Variables Reference

### SearXNG Core

| Variable | Default | Description |
|----------|---------|-------------|
| `SEARXNG_PORT` | `8080` | Host port mapping |
| `SEARXNG_BASE_URL` | `http://localhost:8080/` | Public URL |
| `SEARXNG_SECRET` | *(required)* | Session encryption key |
| `SEARXNG_IMAGE` | `searxng/searxng:latest` | Docker image |

### Valkey Cache

| Variable | Default | Description |
|----------|---------|-------------|
| `VALKEY_VERSION` | `8-alpine` | Image tag |
| `VALKEY_MAX_MEMORY` | `256mb` | Memory limit |

Valkey command-line arguments (configured in `docker-compose.yml`):
- `--save 60 1` — Persist to disk every 60s if at least 1 key changed
- `--maxmemory-policy allkeys-lru` — Evict least recently used keys when memory limit reached

---

## Security Notes

- **No authentication** — Designed for local/private network use
- **Internal network** — Valkey not exposed to host (only accessible by SearXNG)
- **Read-only config** — `core-config/` mounted as `:ro` (read-only)
- **Resource limits** — Memory limits enforced via `deploy.resources`
- **Structured logging** — JSON logs with rotation (`max-size: 20m`, `max-file: 5`)

For public deployments, see [Production Hardening](README.md#-production-hardening) in README.
