# SearXNG Docker

Production-ready Docker Compose setup for a private, developer-focused SearXNG instance.

SearXNG is a privacy-respecting metasearch engine. This repository packages a clean local/team deployment with Valkey cache, stable CI, multi-arch image publishing, and search shortcuts tuned for daily engineering work.

## Features

- Docker Compose v2 stack with SearXNG and Valkey.
- Fast local setup with `make setup && make up`.
- Health checks for both services.
- GitHub Actions CI for compose validation, Docker build, integration test, markdown lint, Hadolint, and Trivy.
- GHCR release workflow with multi-arch `linux/amd64` and `linux/arm64` images.
- Developer search profile with shortcuts for cppreference, Stack Overflow, GitHub, DevDocs, Godot docs, Wikipedia, and Russian cppreference.

## Requirements

- Docker Engine with Compose v2.
- `make`.
- `python3` for portable local secret generation in `make setup`.
- `curl` for smoke tests.

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
| `SEARXNG_BASE_URL` | `http://localhost:8080/` | Public URL, especially behind reverse proxy. |
| `SEARXNG_SECRET` | Required | Secret key for sessions. Generate a unique value. |
| `SEARXNG_IMAGE` | `searxng/searxng:latest` | SearXNG image to run. |
| `VALKEY_VERSION` | `8-alpine` | Valkey image tag. |
| `VALKEY_MAX_MEMORY` | `256mb` | Cache memory limit. |

Main SearXNG settings live in `core-config/settings.yml`.

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
3. Lint Markdown.
4. Build Docker image with BuildKit cache.
5. Run a real Compose integration smoke test.
6. Scan repository filesystem with Trivy and upload SARIF.

The release workflow runs on `v*` tags and publishes a multi-arch image to GitHub Container Registry with provenance and SBOM enabled.

## Production notes

- Put the service behind a TLS reverse proxy for public/team use.
- Set `SEARXNG_BASE_URL` to the external URL.
- Keep `SEARXNG_SECRET` unique and private.
- Consider enabling SearXNG limiter when exposing the instance publicly.
- Keep `.env` out of Git; it is ignored by default.

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
