.PHONY: help setup up down logs restart test health update clean config build

COMPOSE := docker compose
URL ?= http://localhost:8080

help:
	@printf "SearXNG Docker commands:\n"
	@printf "  make setup    create .env with generated secret\n"
	@printf "  make up       start stack\n"
	@printf "  make down     stop stack\n"
	@printf "  make logs     follow logs\n"
	@printf "  make restart  restart services\n"
	@printf "  make test     run health and API smoke tests\n"
	@printf "  make health   show service and resource status\n"
	@printf "  make config   validate compose config\n"
	@printf "  make build    build local image\n"
	@printf "  make update   pull images and restart\n"
	@printf "  make clean    remove containers, volumes, and .env\n"

setup:
	@cp -n .env.example .env 2>/dev/null || true
	@python3 - <<'PY'
from pathlib import Path
import secrets
p = Path('.env')
s = p.read_text()
secret = secrets.token_hex(32)
lines = []
for line in s.splitlines():
    if line.startswith('SEARXNG_SECRET='):
        line = f'SEARXNG_SECRET={secret}'
    lines.append(line)
p.write_text('\n'.join(lines) + '\n')
PY
	@echo "Environment configured. Edit .env, then run: make up"

up:
	$(COMPOSE) up -d --wait

down:
	$(COMPOSE) down

logs:
	$(COMPOSE) logs -f

restart:
	$(COMPOSE) restart

test:
	@curl --fail --silent --show-error $(URL)/healthz >/dev/null
	@curl --fail --silent --show-error --get $(URL)/search --data-urlencode 'q=std::vector' --data-urlencode 'format=json' >/dev/null
	@echo "healthy"

health:
	@$(COMPOSE) ps
	@docker stats --no-stream

config:
	@SEARXNG_SECRET=local-config-check $(COMPOSE) config --quiet
	@echo "compose config ok"

build:
	docker build -t searxng-docker:local .

update:
	$(COMPOSE) pull
	$(COMPOSE) up -d --wait

clean:
	$(COMPOSE) down -v --remove-orphans
	@rm -f .env
	@echo "All local data removed"
