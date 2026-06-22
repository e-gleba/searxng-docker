# Contributing to SearXNG Docker

Thank you for contributing! This document provides guidelines for contributing to the project.

---

## How to Contribute

### Reporting Bugs

1. Check [existing issues](https://github.com/e-gleba/searxng-docker/issues) to avoid duplicates
2. Include: Docker and Compose versions, OS, steps to reproduce, expected vs actual behavior, relevant logs

### Suggesting Features

1. Open a [feature request](https://github.com/e-gleba/searxng-docker/issues/new)
2. Describe the use case and benefits

### Submitting Changes

1. **Fork** the repository
2. **Create a feature branch**: `git checkout -b feature/your-feature-name`
3. **Make your changes** — follow existing code style, add tests if applicable, update docs
4. **Test locally**: `make setup && make up && make test`
5. **Commit**: `git commit -m "feat: add support for custom engine configuration"`
6. **Push and open a PR**: `git push origin feature/your-feature-name`

---

## Development Setup

```bash
git clone https://github.com/YOUR-USERNAME/searxng-docker.git
cd searxng-docker
cp .env.example .env
# Edit .env and set SEARXNG_SECRET
docker compose up -d
```

### Testing Changes

```bash
# Configuration changes
docker compose restart core

# Compose changes
docker compose config --quiet
docker compose down && docker compose up -d

# Dockerfile changes
docker build -t searxng-docker:test .
docker run -p 8080:8080 -e SEARXNG_SECRET=test123 searxng-docker:test
```

---

## Code Style

- **YAML**: 2-space indentation, comment complex sections
- **Docker Compose**: use env vars for configurable values, include health checks, set resource limits
- **Shell**: use `#!/bin/bash`, quote variables, use `set -euo pipefail`
- **Markdown**: ATX headers, fenced code blocks with language tags

---

## Commit Convention

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```bash
git commit -m "feat(engines): add Unreal Engine documentation search"
git commit -m "fix(compose): correct Valkey health check interval"
git commit -m "docs(readme): add production hardening section"
```

---

## Pull Request Process

1. Ensure CI passes
2. Update documentation as needed
3. Keep PRs focused — one feature or fix per PR
4. Maintainers review within 7 days

---

## Adding Search Engines

1. Research the engine (URL params, parseable results, rate limits)
2. Add to `core-config/settings.yml`:

```yaml
engines:
  - name: engine name
    engine: xpath
    shortcut: short
    categories: [it]
    search_url: https://example.com/search?q={query}
    url_xpath: //a[@class='result']/@href
    title_xpath: //a[@class='result']/text()
    content_xpath: //div[@class='snippet']/text()
```

3. Test: `docker compose restart core && curl -s "http://localhost:8080/search?q=test&engines=engine+name&format=json" | jq`
4. Document in readme engine table

---

## Questions?

- Open a [discussion](https://github.com/e-gleba/searxng-docker/discussions)
- Check [existing issues](https://github.com/e-gleba/searxng-docker/issues)
- Review [SearXNG documentation](https://docs.searxng.org/)
