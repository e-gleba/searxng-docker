.PHONY: setup up down logs restart test health update clean

setup:
	@cp -n .env.example .env 2>/dev/null || true
	@sed -i "s/^SEARXNG_SECRET=.*/SEARXNG_SECRET=$$(openssl rand -hex 32)/" .env
	@echo "Environment configured. Edit .env, then: make up"

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f

restart:
	docker compose restart

test:
	@curl -sf http://localhost:8080/healthz && echo " healthy" || echo " unhealthy"

health:
	@docker compose ps
	@docker stats --no-stream

update:
	docker compose pull
	docker compose up -d

clean:
	docker compose down -v --remove-orphans
	@rm -f .env
	@echo "All data removed"
