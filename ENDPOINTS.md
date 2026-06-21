# Endpoint Map - SearXNG Docker Stack

Complete reference of all available endpoints, health checks, and APIs.

---

## 🌐 Public Endpoints

### SearXNG Core (Port 8080)

| Endpoint | Method | Description | Auth |
|----------|--------|-------------|------|
| `http://localhost:8080/` | GET | Web UI - Search interface | No |
| `http://localhost:8080/search?q={query}` | GET | Search with query | No |
| `http://localhost:8080/search?q={query}&format=json` | GET | JSON API response | No |
| `http://localhost:8080/preferences` | GET | User preferences page | No |
| `http://localhost:8080/about` | GET | About page | No |
| `http://localhost:8080/healthz` | GET | Health check endpoint | No |

---

## 🔧 Health Check Endpoints

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
docker compose logs --tail=100 core
```

### Resource Usage

```bash
# CPU and memory
docker stats --no-stream searxng-core searxng-valkey
```

---

## 🧪 Testing Endpoints

### Quick Health Check

```bash
# One-liner to check all services
echo "SearXNG: $(curl -sf http://localhost:8080/healthz > /dev/null && echo '✓' || echo '✗')" && \
echo "Valkey: $(docker exec searxng-valkey valkey-cli ping 2>/dev/null | grep -q PONG && echo '✓' || echo '✗')"
```

### Search Test

```bash
curl -s "http://localhost:8080/search?q=docker&format=json" | jq -r '.results[:3][] | "\(.title)\n\(.url)\n"'
```

---

## 🔐 Security Notes

- **No authentication required** - Designed for local/development use
- **Internal network only** - Valkey not exposed to host
- **Read-only config** - core-config mounted as :ro
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
# Check network
docker network inspect searxng-internal
```

### Port Conflicts

```bash
# Check what's using ports
sudo lsof -i :8080
```

---

## 📝 Environment Variables Reference

### SearXNG Core

| Variable | Default | Description |
|----------|---------|-------------|
| `SEARXNG_BASE_URL` | `http://localhost:8080/` | Public URL |
| `SEARXNG_SECRET` | `changeme...` | Secret key (CHANGE THIS!) |

### Valkey Cache

Valkey uses command-line arguments in docker-compose.yml:
- `--maxmemory 256mb` - Memory limit
- `--maxmemory-policy allkeys-lru` - Eviction policy
