# SearXNG Docker

Small, private, single-user SearXNG instance on Docker Compose.

SearXNG is a privacy-respecting metasearch engine. This repository runs it for one person: bound to loopback, no bot limiter in the way, trimmed memory ceilings, and search shortcuts tuned for daily engineering work.

## Features

- Docker Compose v2 stack with SearXNG and Valkey.
- Fast local setup with `make setup && make up`.
- Published on `127.0.0.1` only; nothing on the LAN can reach it.
- Health checks for both services.
- GitHub Actions CI for Compose validation, Docker build, Compose integration tests, Hadolint, and Trivy.
- GHCR release workflow with multi-arch `linux/amd64` and `linux/arm64` images.
- Release images include provenance and SBOM attestations.
- Developer search profile with shortcuts for cppreference, Stack Overflow, GitHub, DevDocs, Godot docs, Wikipedia, and Russian cppreference.

## Requirements

- Docker Engine with Compose v2.
- `make`.
- `python3` for portable local secret generation in `make setup`.
- `curl` for smoke tests.
- Roughly 1 GB of free RAM and 1 GB of disk.

## Quick start

```bash
git clone https://github.com/e-gleba/searxng-docker.git
cd searxng-docker
make setup
make up
make test
```

Open <http://localhost:8080>.

## Manual setup

```bash
cp .env.example .env
python3 - <<'PY'
from pathlib import Path
import secrets
p = Path('.env')
s = p.read_text()
s = s.replace('SEARXNG_SECRET=', f'SEARXNG_SECRET={secrets.token_hex(32)}')
p.write_text(s)
PY
docker compose up -d --wait
```

## Configuration

Runtime values live in `.env`:

| Variable | Default | Description |
| --- | --- | --- |
| `SEARXNG_PORT` | `8080` | Host port for SearXNG. |
| `SEARXNG_BIND_HOST` | `127.0.0.1` | Host interface the port is published on. Use `0.0.0.0` only for deliberate LAN exposure. |
| `SEARXNG_BASE_URL` | `http://localhost:8080/` | Public URL, especially behind reverse proxy. |
| `SEARXNG_SECRET` | Required | Secret key for sessions. Generate a unique value. |
| `SEARXNG_IMAGE` | `searxng/searxng:latest` | SearXNG image to run. |
| `VALKEY_VERSION` | `8-alpine` | Valkey image tag. |
| `VALKEY_MAX_MEMORY` | `128mb` | Cache memory limit. |

Main SearXNG settings live in `core-config/settings.yml`. It is already tuned for a private instance: `limiter: false`, `public_instance: false`, metrics off, dark simple theme, vim hotkeys.

## Resource footprint

| Service | Memory reservation | Memory limit |
| --- | --- | --- |
| `core` | 256M | 1G |
| `valkey` | 64M | 192M |

Upstream guidance is 256M minimum and 512M recommended for SearXNG plus 50-100M for the cache, so these ceilings keep headroom without reserving a whole gigabyte up front.

## Search shortcuts

| Shortcut | Engine | Example |
| --- | --- | --- |
| `!cpp` | cppreference EN | `!cpp std::vector push_back` |
| `!cppru` | cppreference RU | `!cppru std::unique_ptr` |
| `!so` | Stack Overflow | `!so docker compose healthcheck` |
| `!gh` | GitHub | `!gh searxng settings.yml redis` |
| `!dd` | DevDocs | `!dd cmake target_link_libraries` |
| `!godot` | Godot docs | `!godot signal connect` |
| `!wiki` | Wikipedia | `!wiki valkey` |

API example:

```bash
curl --get 'http://localhost:8080/search' \
  --data-urlencode 'q=!cpp std::vector reserve' \
  --data-urlencode 'format=json'
```

More endpoints are documented in [endpoints.md](endpoints.md).

## Make commands

| Command | Description |
| --- | --- |
| `make help` | Show commands. |
| `make setup` | Create `.env` and generate secret. |
| `make up` | Start stack and wait for health. |
| `make down` | Stop stack. |
| `make logs` | Follow logs. |
| `make restart` | Restart services. |
| `make test` | Run health and API smoke tests. |
| `make health` | Show service/resource status. |
| `make config` | Validate compose config. |
| `make build` | Build local image. |
| `make update` | Pull images and restart. |
| `make clean` | Remove containers, volumes, and `.env`. |

## CI/CD

The CI workflow runs on pushes and pull requests to `main`:

1. Validate Docker Compose config.
2. Lint Dockerfile with Hadolint.
3. Build Docker image with BuildKit cache.
4. Run a real Compose integration smoke test.
5. Scan repository filesystem with Trivy and upload SARIF.

The release workflow runs on `v*` tags and publishes a multi-arch image to GitHub Container Registry with provenance and SBOM enabled.

## If you ever expose it

The defaults assume a private instance. Before putting it on a network:

- Put the service behind a TLS reverse proxy and set `SEARXNG_BASE_URL` to the external URL.
- Enable the SearXNG limiter in `core-config/settings.yml`; there is no authentication by design.
- Consider dropping `json` from `search.formats` so the API is not open.
- Keep `SEARXNG_SECRET` unique and private. `.env` is ignored by Git.

## Project structure

```text
.
├── .github/workflows/      # CI and release automation
├── core-config/            # SearXNG configuration
├── docker-compose.yml      # Runtime stack
├── Dockerfile              # Optional custom image
├── Makefile                # Local commands
├── .env.example            # Environment template
├── endpoints.md            # API examples
└── readme.md               # Project documentation
```

## License

This repository is licensed under the GNU Affero General Public License v3.0. See [license.md](license.md).

SearXNG is also AGPL-3.0 licensed. See the upstream project at <https://github.com/searxng/searxng>.
