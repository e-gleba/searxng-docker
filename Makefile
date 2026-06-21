# =============================================================================
# SearXNG Docker — Development Commands
# =============================================================================
# Usage: make <target>
# =============================================================================

.DEFAULT_GOAL := help

.PHONY: help setup up down logs restart clean test health config update

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

setup: ## Initial setup — copy .env.example to .env
	@test -f .env || cp .env.example .env
	@echo "Created .env — edit SEARXNG_SECRET before starting."

up: ## Start all services in background
	docker compose up -d

down: ## Stop all services
	docker compose down

logs: ## Follow logs (all services)
	docker compose logs -f

restart: ## Restart all services
	docker compose restart

clean: ## Stop and remove all data (WARNING: deletes cache and volumes)
	docker compose down -v

test: ## Run health checks against running services
	@printf "SearXNG: "; curl -sf http://localhost:8080/healthz > /dev/null && echo "healthy" || echo "unhealthy"
	@printf "Valkey:  "; docker exec searxng-valkey valkey-cli ping 2>/dev/null | grep -q PONG && echo "healthy" || echo "unhealthy"

health: ## Show service status and resource usage
	docker compose ps
	@echo ""
	docker stats --no-stream searxng-core searxng-valkey

config: ## Validate docker-compose configuration
	docker compose config --quiet && echo "Configuration valid."

update: ## Pull latest images and restart services
	docker compose pull
	docker compose up -d
