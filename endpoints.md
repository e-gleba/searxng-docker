# Endpoint Reference — SearXNG Docker

Complete API documentation for the SearXNG Docker deployment.

---

## Public Endpoints

| Endpoint | Method | Description | Auth |
|----------|--------|-------------|------|
| `/` | GET | Web UI — search interface | None |
| `/search?q={query}` | GET | Search with query | None |
| `/search?q={query}&format=json` | GET | JSON API response | None |
| `/preferences` | GET | User preferences page | None |
| `/about` | GET | About page | None |
| `/healthz` | GET | Health check endpoint | None |

---

## Search API

```
GET /search
```

### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `q` | string | Yes | — | Search query (URL-encoded) |
| `format` | string | No | `html` | Response format: `html`, `json` |
| `categories` | string | No | `general` | Engine categories |
| `engines` | string | No | — | Comma-separated engine names |
| `language` | string | No | `auto` | Language code: `en`, `ru`, `auto` |
| `time_range` | string | No | — | Time filter: `day`, `week`, `month`, `year` |
| `safesearch` | integer | No | `0` | Safe search: `0`, `1`, `2` |
| `pageno` | integer | No | `1` | Result page number |

### Example Requests

```bash
# Basic search
curl -s "http://localhost:8080/search?q=std::vector&format=json"

# cppreference engine
curl -s "http://localhost:8080/search?q=std::unique_ptr&engines=cppreference&format=json"

# DevDocs engine
curl -s "http://localhost:8080/search?q=cmake+target_link_libraries&engines=devdocs&format=json"

# Filtered search
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
  "suggestions": ["std::vector::push_back", "std::vector::emplace_back"]
}
```

---

## Health Check Endpoints

```bash
# SearXNG
curl -f http://localhost:8080/healthz

# Valkey
docker exec searxng-valkey valkey-cli ping

# Service status
docker compose ps

# Resource usage
docker stats --no-stream searxng-core searxng-valkey
```

---

## Performance

```bash
# Cache hit/miss ratio
docker exec searxng-valkey valkey-cli INFO stats | grep -E 'keyspace_hits|keyspace_misses'

# Memory usage
docker exec searxng-valkey valkey-cli INFO memory | grep used_memory_human

# Request latency
time curl -s http://localhost:8080/search?q=test > /dev/null
```

---

## Troubleshooting

```bash
# Check logs
docker compose logs core
docker compose logs valkey

# Verify configuration
docker compose config --quiet

# Clean rebuild
docker compose down -v && docker compose up -d

# Port already in use
sudo ss -tlnp | grep 8080
```

---

## Environment Variables

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

---

## Security Notes

- No authentication — designed for local/private network use
- Valkey not exposed to host (only accessible by SearXNG)
- Config mounted read-only (`core-config/` → `:ro`)
- Resource limits enforced via `deploy.resources`
- Structured logging with rotation (`max-size: 20m`, `max-file: 5`)

For public deployments, see [Production Hardening](readme.md#-production-hardening) in readme.
