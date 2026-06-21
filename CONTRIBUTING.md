# Contributing to SearXNG Docker

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

---

## Code of Conduct

This project adheres to the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct/). By participating, you agree to uphold this code.

---

## How to Contribute

### Reporting Bugs

1. Check [existing issues](https://github.com/e-gleba/searxng-docker/issues) to avoid duplicates
2. Use the [bug report template](https://github.com/e-gleba/searxng-docker/issues/new?template=bug_report.md)
3. Include:
   - Docker and Compose versions
   - Operating system
   - Steps to reproduce
   - Expected vs actual behavior
   - Relevant logs (`docker compose logs`)

### Suggesting Features

1. Open a [feature request](https://github.com/e-gleba/searxng-docker/issues/new?template=feature_request.md)
2. Describe the use case and benefits
3. Provide examples if applicable

### Submitting Changes

1. **Fork** the repository
2. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**:
   - Follow existing code style
   - Add tests if applicable
   - Update documentation
4. **Test locally**:
   ```bash
   make setup
   make up
   make test
   ```
5. **Commit with clear messages**:
   ```bash
   git commit -m "feat: add support for custom engine configuration"
   ```
6. **Push and open a pull request**:
   ```bash
   git push origin feature/your-feature-name
   ```

---

## Development Setup

### Prerequisites

- Docker Engine 24.0+
- Docker Compose v2
- Git
- Make (optional, for convenience commands)

### Local Development

```bash
# Clone your fork
git clone https://github.com/YOUR-USERNAME/searxng-docker.git
cd searxng-docker

# Set up environment
cp .env.example .env
# Edit .env and set SEARXNG_SECRET

# Start services
docker compose up -d

# View logs
docker compose logs -f

# Run tests
make test
```

### Testing Changes

**Configuration changes:**

```bash
# Edit settings.yml
vim core-config/settings.yml

# Restart SearXNG to apply
docker compose restart core

# Verify
curl -s "http://localhost:8080/search?q=test&format=json" | jq
```

**Compose changes:**

```bash
# Validate configuration
docker compose config --quiet

# Recreate services
docker compose down
docker compose up -d
```

**Dockerfile changes:**

```bash
# Build locally
docker build -t searxng-docker:test .

# Test the image
docker run -p 8080:8080 -e SEARXNG_SECRET=test123 searxng-docker:test
```

---

## Code Style Guidelines

### YAML Files

- Use 2-space indentation
- Add comments for complex configurations
- Group related settings with section headers

```yaml
# =============================================================================
# Section Name
# =============================================================================

setting_one: value
setting_two: value
```

### Docker Compose

- Use environment variables for configurable values
- Always include health checks
- Set resource limits via `deploy.resources`
- Use structured logging with rotation

### Shell Scripts

- Use `#!/bin/bash` or `#!/usr/bin/env bash`
- Quote variables: `"$variable"` not `$variable`
- Use `set -euo pipefail` for error handling

### Markdown

- Use ATX-style headers (`# Header`)
- Wrap at 100 characters (soft wrap)
- Use fenced code blocks with language identifiers
- Link to relevant documentation

---

## Commit Message Convention

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, no code change
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance tasks

**Examples:**

```bash
git commit -m "feat(engines): add Unreal Engine documentation search"
git commit -m "fix(compose): correct Valkey health check interval"
git commit -m "docs(readme): add production hardening section"
git commit -m "chore(deps): update SearXNG to latest version"
```

---

## Pull Request Process

1. **Ensure CI passes** — All checks must be green
2. **Update documentation** — README, ENDPOINTS, or inline comments as needed
3. **Keep PRs focused** — One feature or fix per PR
4. **Write a clear description**:
   - What does this PR do?
   - Why is it needed?
   - How was it tested?

### PR Title Format

Use the same convention as commit messages:

```
feat: add custom engine for Unity documentation
fix: resolve Valkey connection timeout issue
docs: update API reference with new endpoints
```

### Review Process

1. Maintainers will review within 7 days
2. Address feedback promptly
3. Squash commits if requested
4. Maintainer will merge when approved

---

## Adding Search Engines

To add a new search engine:

1. **Research the engine**:
   - Does it support search via URL parameters?
   - Can results be parsed from HTML/JSON?
   - Are there rate limits or API keys required?

2. **Add to `core-config/settings.yml`**:

```yaml
engines:
  - name: engine name
    engine: xpath  # or json
    shortcut: short
    categories: [it]
    search_url: https://example.com/search?q={query}
    url_xpath: //a[@class='result']/@href
    title_xpath: //a[@class='result']/text()
    content_xpath: //div[@class='snippet']/text()
    about:
      website: https://example.com
      use_official_api: false
      require_api_key: false
      results: HTML
```

3. **Test locally**:

```bash
docker compose restart core
curl -s "http://localhost:8080/search?q=test&engines=engine+name&format=json" | jq
```

4. **Document in README** — Add to the engine table

---

## Questions?

- Open a [discussion](https://github.com/e-gleba/searxng-docker/discussions)
- Check [existing issues](https://github.com/e-gleba/searxng-docker/issues)
- Review [SearXNG documentation](https://docs.searxng.org/)

---

Thank you for contributing! 🎮
