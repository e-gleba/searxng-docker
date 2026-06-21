# Security Policy

## Supported Versions

This project follows the latest stable release of SearXNG. Security updates are provided for:

| Version | Supported |
|---------|-----------|
| Latest (main branch) | ✅ Yes |
| Previous releases | ❌ No |

---

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability, please report it responsibly.

### How to Report

**Option 1: GitHub Security Advisories (Preferred)**

1. Go to [Security Advisories](https://github.com/e-gleba/searxng-docker/security/advisories)
2. Click "Report a vulnerability"
3. Provide detailed information about the issue

**Option 2: Email**

Send an email to the maintainer with:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

### What to Expect

- **Acknowledgment**: Within 48 hours
- **Investigation**: Up to 7 days
- **Resolution**: Patch released as soon as possible

### Disclosure Policy

- Do not disclose the vulnerability publicly until a fix is released
- We will credit reporters (unless anonymity is requested)
- Critical vulnerabilities will be patched before public disclosure

---

## Security Best Practices

When deploying this project, follow these guidelines:

### 1. Generate Strong Secrets

```bash
# Generate a secure random secret
openssl rand -hex 32
```

Never use default values like `changeme` in production.

### 2. Use Environment Variables

Store secrets in `.env` files or environment variables, never in version control:

```bash
# .env (add to .gitignore)
SEARXNG_SECRET=your-secure-random-secret
```

### 3. Network Isolation

- Keep Valkey internal (not exposed to host)
- Use Docker networks to isolate services
- For public deployments, use a reverse proxy

### 4. TLS/SSL

For public or team-wide deployments:

- Use a reverse proxy (nginx, Traefik) with Let's Encrypt
- Redirect HTTP to HTTPS
- Enable HSTS headers

### 5. Rate Limiting

Enable SearXNG's built-in rate limiter for public instances:

```yaml
# core-config/settings.yml
server:
  limiter: true
  public_instance: true
```

### 6. Firewall Rules

Restrict access to necessary ports only:

```bash
# Allow SSH and HTTPS only
sudo ufw allow 22/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### 7. Regular Updates

Keep dependencies up to date:

```bash
# Weekly update check
docker compose pull
docker compose up -d
```

Or automate with cron:

```bash
0 3 * * 1 cd /opt/searxng-docker && docker compose pull && docker compose up -d
```

### 8. Monitor Logs

Watch for suspicious activity:

```bash
# Follow logs
docker compose logs -f

# Search for errors
docker compose logs | grep -i error
```

---

## Dependency Security

This project uses automated dependency updates:

- **Dependabot** monitors Docker images and GitHub Actions
- Updates are tested via CI pipeline before merge
- Security vulnerabilities are flagged by Trivy

### Viewing Dependencies

```bash
# Check current image versions
docker compose config | grep image:

# Review Dependabot PRs
# https://github.com/e-gleba/searxng-docker/pulls
```

---

## Container Security

### Image Verification

All images are built and published via GitHub Actions:

- **Base image**: `searxng/searxng:latest` (official upstream)
- **Cache**: `valkey/valkey:8-alpine` (official Valkey)
- **Published to**: `ghcr.io/e-gleba/searxng-docker`

### Resource Limits

Memory and CPU limits prevent resource exhaustion:

```yaml
# docker-compose.yml
deploy:
  resources:
    limits:
      memory: 2G
    reservations:
      memory: 512M
```

### Read-Only Filesystems

Configuration is mounted read-only:

```yaml
volumes:
  - ./core-config:/etc/searxng:ro
```

---

## Compliance

### Data Privacy

SearXNG is designed for privacy:

- No user tracking or profiling
- No persistent cookies by default
- Queries are not logged (unless configured)
- Results are cached temporarily (Valkey, cleared on restart)

### GDPR Considerations

For EU deployments:

- SearXNG does not collect personal data by default
- If enabling analytics, ensure GDPR compliance
- Provide a privacy policy page

---

## Security Contacts

- **Maintainer**: Evgeniy Gleba
- **GitHub**: [@e-gleba](https://github.com/e-gleba)

---

## License

This security policy is part of the [SearXNG Docker](https://github.com/e-gleba/searxng-docker) project, licensed under AGPL-3.0.
