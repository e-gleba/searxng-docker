# 🔍 SearXNG Docker

Production-ready SearXNG setup with MCP server integration for LLM clients.

**Stack:** SearXNG (Granian) + Valkey + MCP Server  
**Architecture:** Docker Compose with health checks and isolated networking

---

## 🚀 Quick Start

```bash
git clone https://github.com/e-gleba/searxng-docker.git
cd searxng-docker
docker compose up -d --build
```

**Services will be available at:**
- 🔍 **SearXNG:** http://localhost:8080
- 🤖 **MCP Server:** http://localhost:8000/mcp

See [INFRASTRUCTURE.md](INFRASTRUCTURE.md) for complete endpoint documentation.

---

## 📋 Features

- ✅ **SearXNG 2026** with Granian ASGI server
- ✅ **MCP Server** for LLM integration (Claude, Cursor, etc.)
- ✅ **Valkey** high-performance cache
- ✅ **Health checks** for all services
- ✅ **Isolated network** for security
- ✅ **Structured logging** with rotation
- ✅ **Zero authentication** for local development
- ✅ **Vim hotkeys** enabled
- ✅ **Dark theme** by default

---

## 🧪 Testing

### Verify Services

```bash
# Check all containers are healthy
docker compose ps

# Test SearXNG
curl http://localhost:8080/healthz

# Test MCP server
curl -X POST http://localhost:8000/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | jq
```

### Search Examples

```bash
# Basic search
curl "http://localhost:8080/search?q=rust&format=json" | jq '.results[0]'

# Search with filters
curl "http://localhost:8080/search?q=python&categories=it&time_range=month&format=json" | jq
```

### MCP Examples

```bash
# Web search via MCP
curl -X POST http://localhost:8000/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/call",
    "params": {
      "name": "search_web",
      "arguments": {"query": "rust programming"}
    }
  }' | jq

# Scrape website
curl -X POST http://localhost:8000/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 2,
    "method": "tools/call",
    "params": {
      "name": "get_website",
      "arguments": {"url": "https://example.com"}
    }
  }' | jq
```

---

## 🤖 LLM Client Configuration

### Claude Desktop

Add to `claude_desktop_config.json`:

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

---

## 📖 Documentation

- **[INFRASTRUCTURE.md](INFRASTRUCTURE.md)** - Complete endpoint map and API documentation
- **[core-config/settings.yml](core-config/settings.yml)** - SearXNG configuration

---

## 🔧 Management

### Start/Stop

```bash
# Start all services
docker compose up -d

# Stop all services
docker compose down

# Restart specific service
docker compose restart core
```

### Logs

```bash
# View all logs
docker compose logs -f

# View specific service
docker compose logs -f core
docker compose logs -f mcp
```

### Update

```bash
# Pull latest images and rebuild
docker compose pull
docker compose up -d --build
```

### Reset

```bash
# Stop and remove everything (WARNING: deletes cache)
docker compose down -v

# Start fresh
docker compose up -d --build
```

---

## ⚙️ Configuration

### SearXNG

Edit `core-config/settings.yml`:

```yaml
# Change theme
ui:
  theme_args:
    simple_style: dark  # auto, light, dark, black

# Enable/disable engines
engines:
  - name: google
    disabled: false
```

Restart to apply: `docker compose restart core`

### MCP Server

Environment variables in `docker-compose.yml`:

```yaml
environment:
  - DESIRED_TIMEZONE=Europe/Moscow
  - PAGE_CONTENT_WORDS_LIMIT=10000
  - MAX_IMAGE_RESULTS=20
```

Rebuild to apply: `docker compose up -d --build mcp`

---

## 🔒 Security

This setup is designed for **local/private use**. No authentication is configured.

For public deployments, add:
- Reverse proxy with SSL
- Authentication layer
- Rate limiting (`limiter: true` in settings.yml)
- Firewall rules

---

## 🐛 Troubleshooting

### Services won't start

```bash
# Check logs
docker compose logs

# Verify config
docker compose config

# Clean rebuild
docker compose down -v
docker compose up -d --build
```

### Port already in use

```bash
# Find process
lsof -i :8080
lsof -i :8000

# Stop or change ports in docker-compose.yml
```

### MCP connection issues

```bash
# Test endpoint
curl http://localhost:8000/mcp \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'

# Check logs
docker compose logs mcp

# Restart
docker compose restart mcp
```

See [INFRASTRUCTURE.md](INFRASTRUCTURE.md) for detailed troubleshooting.

---

## 📁 Project Structure

```
searxng-docker/
├── docker-compose.yml          # Service orchestration
├── core-config/
│   └── settings.yml            # SearXNG configuration
├── mcp-server/
│   └── Dockerfile              # Custom MCP server build
├── INFRASTRUCTURE.md           # Complete endpoint documentation
├── README.md                   # This file
└── .gitignore                  # Git ignore rules
```

---

## 📄 License

SearXNG: AGPL-3.0  
MCP Server: MIT
