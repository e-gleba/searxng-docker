# 🔍 SearXNG Docker

Production-ready SearXNG deployment with Docker Compose.

**Stack:** SearXNG (Granian) + Valkey  
**Architecture:** Docker Compose v2 with health checks and isolated networking

---

## 🚀 Quick Start

```bash
git clone https://github.com/e-gleba/searxng-docker.git
cd searxng-docker
docker compose up -d
```

**SearXNG will be available at:** http://localhost:8080

See [ENDPOINTS.md](ENDPOINTS.md) for complete endpoint documentation.

---

## 📋 Features

- ✅ **SearXNG 2026** with Granian ASGI server
- ✅ **Valkey** high-performance Redis-compatible cache
- ✅ **Health checks** for all services
- ✅ **Isolated network** for security
- ✅ **Structured logging** with rotation
- ✅ **Zero authentication** for local development
- ✅ **Vim hotkeys** enabled
- ✅ **Dark theme** by default

---

## 💻 Installation

### ALT Linux (ALT GNOME)

Установка Docker на ALT Linux:

```bash
# Обновите систему
sudo apt-get update
sudo apt-get dist-upgrade -y

# Установите Docker
sudo apt-get install -y docker-engine

# Установите Docker Compose
sudo apt-get install -y docker-compose

# Добавьте пользователя в группу docker
sudo usermod -aG docker $USER

# Перезапустите сессию или выполните:
newgrp docker

# Проверьте установку
docker --version
docker compose version
```

Запустите стек:

```bash
git clone https://github.com/e-gleba/searxng-docker.git
cd searxng-docker
docker compose up -d
```

### Windows (Docker Desktop)

**Requirements:** Windows 10/11 (64-bit) with WSL 2 or Hyper-V enabled.

#### Option 1: Download Installer

1. Download Docker Desktop from [official site](https://www.docker.com/products/docker-desktop/)
2. Run `Docker Desktop Installer.exe`
3. During installation, ensure:
   - ✅ Use WSL 2 instead of Hyper-V (recommended)
   - ✅ Add shortcut to desktop
4. Restart computer when prompted
5. Launch Docker Desktop and wait for "Docker is running"

#### Option 2: Winget (Windows Package Manager)

```powershell
# Open PowerShell as Administrator
winget install -e --id Docker.DockerDesktop

# Restart computer
shutdown /r
```

After restart, launch Docker Desktop and wait for initialization.

#### Verify Installation

```powershell
docker --version
docker compose version
```

#### Deploy Stack

```powershell
git clone https://github.com/e-gleba/searxng-docker.git
cd searxng-docker
docker compose up -d
```

**Note:** If you see WSL errors, enable WSL 2:

```powershell
wsl --install
wsl --set-default-version 2
```

### Generic Linux (Ubuntu/Debian)

```bash
# Install Docker
curl -fsSL https://get.docker.com | sh

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Install Docker Compose (if not bundled)
sudo apt-get install -y docker-compose-plugin

# Deploy
git clone https://github.com/e-gleba/searxng-docker.git
cd searxng-docker
docker compose up -d
```

---

## 🧪 Testing

### Verify Services

```bash
# Check all containers are healthy
docker compose ps

# Test SearXNG
curl http://localhost:8080/healthz
```

### Search Examples

```bash
# Basic search
curl "http://localhost:8080/search?q=rust&format=json" | jq '.results[0]'

# Search with filters
curl "http://localhost:8080/search?q=python&categories=it&time_range=month&format=json" | jq
```

---

## 📖 Documentation

- **[ENDPOINTS.md](ENDPOINTS.md)** - Complete endpoint map and API documentation
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
docker compose logs -f valkey
```

### Update

```bash
# Pull latest images
docker compose pull
docker compose up -d
```

### Reset

```bash
# Stop and remove everything (WARNING: deletes cache)
docker compose down -v

# Start fresh
docker compose up -d
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
docker compose up -d
```

### Port already in use

```bash
# Find process
lsof -i :8080

# Stop or change ports in docker-compose.yml
```

See [ENDPOINTS.md](ENDPOINTS.md) for detailed troubleshooting.

---

## 📁 Project Structure

```
searxng-docker/
├── docker-compose.yml          # Service orchestration
├── core-config/
│   └── settings.yml            # SearXNG configuration
├── ENDPOINTS.md                # Complete endpoint documentation
├── README.md                   # This file
└── .gitignore                  # Git ignore rules
```

---

## 📄 License

SearXNG: AGPL-3.0
