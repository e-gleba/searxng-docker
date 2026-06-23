# syntax=docker/dockerfile:1.12

ARG SEARXNG_VERSION=latest
FROM searxng/searxng:${SEARXNG_VERSION}

LABEL org.opencontainers.image.title="SearXNG Docker" \
      org.opencontainers.image.description="Production-ready SearXNG configuration for developer-focused private search" \
      org.opencontainers.image.url="https://github.com/e-gleba/searxng-docker" \
      org.opencontainers.image.source="https://github.com/e-gleba/searxng-docker" \
      org.opencontainers.image.license="AGPL-3.0" \
      org.opencontainers.image.vendor="e-gleba"

COPY core-config/settings.yml /etc/searxng/settings.yml

USER root
RUN chmod 0444 /etc/searxng/settings.yml
USER searxng

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=45s --retries=5 \
  CMD wget --quiet --spider http://localhost:8080/healthz || exit 1
