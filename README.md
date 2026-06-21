<!-- markdownlint-disable MD033 MD041 -->

<div align="center">

# 🔍 SearXNG Docker

**Production-Ready Privacy Search Infrastructure for C++ Game Development Teams**

[![CI](https://github.com/e-gleba/searxng-docker/actions/workflows/ci.yml/badge.svg)](https://github.com/e-gleba/searxng-docker/actions/workflows/ci.yml)
[![Release](https://github.com/e-gleba/searxng-docker/actions/workflows/release.yml/badge.svg)](https://github.com/e-gleba/searxng-docker/actions/workflows/release.yml)
[![License: AGPL-3.0](https://img.shields.io/badge/License-AGPL%203.0-blue.svg)](LICENSE)
[![Docker Image](https://img.shields.io/badge/Docker-GHCR-2496ED?logo=docker&logoColor=white)](https://github.com/e-gleba/searxng-docker/pkgs/container/searxng-docker)
[![Platforms](https://img.shields.io/badge/Platforms-amd64%20%7C%20arm64-333?logo=linux)](#)

[Quick Start](#-quick-start) • [Configuration](#%EF%B8%8F-configuration) • [Production Hardening](#-production-hardening) • [API Reference](ENDPOINTS.md) • [Contributing](CONTRIBUTING.md)

</div>

---

## Overview

A minimal, zero-maintenance Docker Compose deployment for [SearXNG](https://github.com/searxng/searxng) — the privacy-respecting metasearch engine — purpose-built for cross-platform C++ game development studios.

**Why this exists:** Game development teams need fast, private access to C++ documentation, engine references, and API lookups without sending queries to ad-laden search engines. This project provides a self-hosted alternative with pre-configured engines for cppreference, DevDocs, and Godot documentation.

### Stack

| Component | Technology | Purpose |
|-----------|-----------|--------|
| **Search Engine** | SearXNG 2025+ (Granian ASGI) | Privacy-respecting metasearch |
| **Cache** | Valkey 8 (Redis-compatible) | High-performance result caching |
| **Orchestration** | Docker Compose v2 | Single-command deployment |
| **CI/CD** | GitHub Actions | Automated testing and multi-arch builds |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Docker Network                              │
│                       (searxng-internal)                            │
│                                                                     │
│  ┌─────────────────────────────────┐    ┌───────────────────────┐  │
│  │        SearXNG Core             │    │    Valkey Cache       │  │
│  │  ┌───────────────────────────┐  │    │  ┌─────────────────┐ │  │
│  │  │  Granian ASGI Server      │  │◄──►│  │  Redis Protocol │ │  │
│  │  │  Port: 8080               │  │    │  │  Port: 6379     │ │  │
│  │  └───────────────────────────┘  │    │  │  (internal)     │ │  │
│  │  ┌───────────────────────────┐  │    │  └─────────────────┘ │  │
│  │  │  Search Engines           │  │    │  Memory: 256MB       │  │
│  │  │  • cppreference (EN/RU)  │  │    │  Policy: allkeys-lru │  │
│  │  │  • DevDocs               │  │    └───────────────────────┘  │
│  │  │  • Godot Docs            │  │                               │
│  │  │  • Google, Yandex...     │  │                               │
│  │  └───────────────────────────┘  │                               │
│  └────────────┬────────────────────┘                               │
│               │ :8080                                               │
└───────────────┼─────────────────────────────────────────────────────┘
                │
                ▼
┌──────────────────────────────┐
│  Developer Workstation       │
│  http://localhost:8080       │
│  API: /search?q=...&format=json │
└──────────────────────────────┘
```

---

## 🚀 Quick Start

### Prerequisites

- Docker Engine 24.0+ with Compose v2
- 1 GB RAM minimum (2 GB recommended)

### Deploy

```bash
# Clone repository
git clone https://github.com/e-gleba/searxng-docker.git
cd searxng-docker

# Configure environment
cp .env.example .env
sed -i "s/^SEARXNG_SECRET=.*/SEARXNG_SECRET=$(openssl rand -hex 32)/" .env

# Start stack
docker compose up -d
```

**SearXNG is now available at:** [http://localhost:8080](http://localhost:8080)

### Verify Deployment

```bash
# Check service health
docker compose ps

# Test health endpoint
curl -f http://localhost:8080/healthz

# Test search API
curl -s "http://localhost:8080/search?q=std::vector&format=json" | jq '.results[0]'
```

### Alternative: Pre-built Image

For zero-configuration deployment, use the pre-built image from GitHub Container Registry:

```bash
docker pull ghcr.io/e-gleba/searxng-docker:latest
docker run -p 8080:8080 -e SEARXNG_SECRET=$(openssl rand -hex 32) ghcr.io/e-gleba/searxng-docker:latest
```

---

## ⚙️ Configuration

### Environment Variables

All runtime configuration is controlled via `.env` or environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `SEARXNG_PORT` | `8080` | Host port for SearXNG |
| `SEARXNG_BASE_URL` | `http://localhost:8080/` | Public-facing URL (update for reverse proxy) |
| `SEARXNG_SECRET` | *(required)* | Session encryption key — **generate with** `openssl rand -hex 32` |
| `SEARXNG_IMAGE` | `searxng/searxng:latest` | Docker image (switch to GHCR for pre-built) |
| `VALKEY_VERSION` | `8-alpine` | Valkey image tag |
| `VALKEY_MAX_MEMORY` | `256mb` | Cache memory limit |

### Search Engines

Edit `core-config/settings.yml` to customize engines:

```yaml
# Enable/disable engines
engines:
  - name: google
    disabled: false
  - name: cppreference
    disabled: false
    shortcut: cpp
```

**Pre-configured C++ dev engines:**

| Engine | Shortcut | Description |
|--------|----------|-------------|
| `cppreference` | `!cpp` | C++ Standard Library (English) |
| `cppreference ru` | `!cppru` | C++ Standard Library (Russian) |
| `devdocs` | `!dd` | Multi-language API docs (C, C++, CMake) |
| `godot docs` | `!godot` | Godot Engine documentation |

### UI Customization

```yaml
ui:
  default_locale: "en"        # Interface language
  hotkeys: vim                 # Vim navigation (j/k/Enter)
  theme_args:
    simple_style: dark         # auto, light, dark, black
  infinite_scroll: true        # Auto-load next page
```

Apply changes: `docker compose restart core`

---

## 🔒 Production Hardening

For public or team-wide deployments, apply these security measures:

### 1. Reverse Proxy with TLS

Deploy behind nginx or Traefik with Let's Encrypt:

```nginx
# /etc/nginx/conf.d/searxng.conf
server {
    listen 443 ssl http2;
    server_name search.example.com;

    ssl_certificate /etc/letsencrypt/live/search.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/search.example.com/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 2. Enable Rate Limiting

```yaml
# core-config/settings.yml
server:
  limiter: true
  public_instance: true
```

### 3. Firewall Rules

```bash
# Allow only reverse proxy to reach SearXNG
sudo ufw allow from 127.0.0.1 to any port 8080
sudo ufw deny 8080
```

### 4. Automatic Updates

```bash
# Crontab entry for weekly updates
0 3 * * 1 cd /opt/searxng-docker && docker compose pull && docker compose up -d
```

### 5. Secrets Management

Never commit `.env` to version control. Use Docker secrets or external secret managers:

```bash
# Docker Swarm secret
echo $(openssl rand -hex 32) | docker secret create searxng_secret -
```

---

## 📖 API Reference

### Search Endpoint

```
GET /search?q={query}&format=json
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `q` | string | Search query (URL-encoded) |
| `format` | string | Response format: `json` (default: `html`) |
| `categories` | string | Engine categories: `general`, `it`, `images`, etc. |
| `engines` | string | Comma-separated engine names |
| `language` | string | Language code: `en`, `ru`, `auto` |
| `time_range` | string | Time filter: `day`, `week`, `month`, `year` |

**Example:**

```bash
curl -s "http://localhost:8080/search?q=std::vector+push_back&engines=cppreference&format=json" \
  | jq '.results[] | {title, url, content}'
```

**Response:**

```json
{
  "query": "std::vector push_back",
  "results": [
    {
      "title": "std::vector::push_back - cppreference.com",
      "url": "https://en.cppreference.com/w/cpp/container/vector/push_back",
      "content": "Appends the given element value to the end of the container."
    }
  ],
  "number_of_results": 1
}
```

Full API documentation: [ENDPOINTS.md](ENDPOINTS.md)

---

## 🛠️ Management Commands

| Command | Description |
|---------|-------------|
| `make setup` | Initial setup (creates `.env`) |
| `make up` | Start services |
| `make down` | Stop services |
| `make logs` | Follow logs |
| `make restart` | Restart services |
| `make test` | Run health checks |
| `make health` | Show status + resource usage |
| `make update` | Pull latest images + restart |
| `make clean` | Remove all data (⚠️ destructive) |

Or use `docker compose` directly:

```bash
docker compose logs -f core          # Follow SearXNG logs
docker compose restart core          # Restart SearXNG only
docker compose down -v               # Remove volumes (clears cache)
```

---

## 🧪 Testing

### Health Checks

```bash
# SearXNG health
curl -f http://localhost:8080/healthz && echo "✓ healthy"

# Valkey health
docker exec searxng-valkey valkey-cli ping
```

### Search Tests

```bash
# Basic search
curl -s "http://localhost:8080/search?q=docker+compose&format=json" | jq '.results | length'

# cppreference engine
curl -s "http://localhost:8080/search?q=std::unique_ptr&engines=cppreference&format=json" | jq '.results[0].title'

# DevDocs engine
curl -s "http://localhost:8080/search?q=cmake+target&engines=devdocs&format=json" | jq '.results[:3]'
```

### Performance

```bash
# Response time
time curl -s "http://localhost:8080/search?q=test" > /dev/null

# Cache hit rate
docker exec searxng-valkey valkey-cli INFO stats | grep -E 'keyspace_hits|keyspace_misses'
```

---

## 📦 Project Structure

```
searxng-docker/
├── docker-compose.yml          # Service orchestration
├── Dockerfile                  # Production image (extends upstream)
├── Makefile                    # Development commands
├── .env.example                # Environment template
├── core-config/
│   └── settings.yml            # SearXNG configuration
├── .github/
│   ├── workflows/
│   │   ├── ci.yml              # CI pipeline (lint, test, build)
│   │   └── release.yml         # Release pipeline (GHCR publish)
│   └── dependabot.yml          # Automated dependency updates
├── ENDPOINTS.md                # Full API reference
├── CONTRIBUTING.md             # Contribution guidelines
├── SECURITY.md                 # Security policy
└── LICENSE                     # AGPL-3.0 license
```

---

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

**Development workflow:**

```bash
# Fork and clone
git clone https://github.com/YOUR-USERNAME/searxng-docker.git
cd searxng-docker

# Create feature branch
git checkout -b feature/my-improvement

# Make changes, test locally
make setup
make up
make test

# Commit and push
git commit -am "feat: add new search engine"
git push origin feature/my-improvement

# Open pull request
```

---

## 📄 License

This project is licensed under the [GNU Affero General Public License v3.0](LICENSE).

SearXNG is free software metasearch engine, also licensed under AGPL-3.0. See [github.com/searxng/searxng](https://github.com/searxng/searxng).

---

## 🙏 Acknowledgments

- [SearXNG](https://github.com/searxng/searxng) — The privacy-respecting metasearch engine
- [Valkey](https://github.com/valkey-io/valkey) — High-performance Redis-compatible cache
- [cppreference.com](https://en.cppreference.com/) — C++ Standard Library reference
- [DevDocs](https://devdocs.io/) — Multi-language API documentation

---

<div align="center">

**Built with ❤️ for C++ game developers**

[Report Bug](https://github.com/e-gleba/searxng-docker/issues) • [Request Feature](https://github.com/e-gleba/searxng-docker/issues)

</div>
