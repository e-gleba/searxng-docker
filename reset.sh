#!/bin/bash
# ============================================
# ЯДЕРНЫЙ СБРОС — выполняет если ничего не помогает
# ============================================
# Использование:
#   bash reset.sh
# ============================================

echo "🔥 Останавливаю все контейнеры searxng..."
docker compose down -v --remove-orphans 2>/dev/null

echo "🗑️  Удаляю старые контейнеры (если остались)..."
docker rm -f searxng searxng-core searxng-valkey 2>/dev/null

echo "🗑️  Удаляю старые образы..."
docker rmi searxng/searxng:latest docker.io/searxng/searxng:latest valkey/valkey:9-alpine docker.io/valkey/valkey:9-alpine 2>/dev/null

echo "🗑️  Удаляю старые volumes..."
docker volume rm searxng_core-data searxng_valkey-data 2>/dev/null

echo "🗑️  Удаляю старые конфиги..."
rm -rf searxng/ data/ .env core-config/

echo "✅ Сброс завершён."
echo ""
echo "Теперь склонируй заново:"
echo "  cd .."
echo "  rm -rf searxng-docker"
echo "  git clone https://github.com/e-gleba/searxng-docker.git"
echo "  cd searxng-docker"
echo "  docker compose up -d"
