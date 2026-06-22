# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| Latest (main branch) | Yes |
| Previous releases | No |

---

## Reporting a Vulnerability

**Option 1: GitHub Security Advisories (Preferred)**

1. Go to [Security Advisories](https://github.com/e-gleba/searxng-docker/security/advisories)
2. Click "Report a vulnerability"
3. Provide detailed information

**Option 2: Email** — contact the maintainer directly.

### What to Expect

- **Acknowledgment**: Within 48 hours
- **Investigation**: Up to 7 days
- **Resolution**: Patch released as soon as possible

### Disclosure Policy

- Do not disclose publicly until a fix is released
- Reporters credited (unless anonymity requested)
- Critical vulnerabilities patched before public disclosure

---

## Security Best Practices

### 1. Generate Strong Secrets

```bash
openssl rand -hex 32
```

Never use default values like `changeme` in production.

### 2. Use Environment Variables

Store secrets in `.env` files, never in version control.

### 3. Network Isolation

- Keep Valkey internal (not exposed to host)
- Use Docker networks to isolate services
- Use a reverse proxy for public deployments

### 4. TLS/SSL

Use a reverse proxy (nginx, Traefik) with Let's Encrypt. Redirect HTTP to HTTPS.

### 5. Rate Limiting

```yaml
server:
  limiter: true
  public_instance: true
```

### 6. Firewall Rules

```bash
sudo ufw allow 22/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### 7. Regular Updates

```bash
0 3 * * 1 cd /opt/searxng-docker && docker compose pull && docker compose up -d
```

### 8. Monitor Logs

```bash
docker compose logs -f
docker compose logs | grep -i error
```

---

## Container Security

- **Base image**: `searxng/searxng:latest` (official upstream)
- **Cache**: `valkey/valkey:8-alpine` (official Valkey)
- **Published to**: `ghcr.io/e-gleba/searxng-docker`
- **Config mounted read-only**: `./core-config:/etc/searxng:ro`
- **Resource limits**: memory limits enforced via `deploy.resources`

---

## Data Privacy

- No user tracking or profiling
- No persistent cookies by default
- Queries not logged (unless configured)
- Results cached temporarily (Valkey, cleared on restart)

---

## Security Contacts

- **Maintainer**: Evgeniy Gleba
- **GitHub**: [@e-gleba](https://github.com/e-gleba)
