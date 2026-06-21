# syntax=docker/dockerfile:1

# =============================================================================
# SearXNG Docker — Production Image
# =============================================================================
# Extends the official SearXNG image with pre-configured settings
# optimized for cross-platform C++ game development teams.
#
# Build:   docker build -t searxng-docker .
# Run:     docker run -p 8080:8080 --env-file .env searxng-docker
# =============================================================================

ARG SEARXNG_VERSION=latest
FROM searxng/searxng:${SEARXNG_VERSION}

LABEL org.opencontainers.image.title="SearXNG Docker" \
      org.opencontainers.image.description="Production-ready SearXNG for C++ game development teams" \
      org.opencontainers.image.url="https://github.com/e-gleba/searxng-docker" \
      org.opencontainers.image.source="https://github.com/e-gleba/searxng-docker" \
      org.opencontainers.image.license="AGPL-3.0" \
      org.opencontainers.image.vendor="e-gleba"

# Copy pre-configured settings
COPY core-config/settings.yml /etc/searxng/settings.yml

RUN chmod 644 /etc/searxng/settings.yml

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:8080/healthz || exit 1
