# 🔍 SearXNG Docker

> Приватный мета-поисковик **SearXNG** + **MCP сервер** для LLM клиентов.  
> Основано на [официальной архитектуре 2026](https://docs.searxng.org/admin/installation-docker.html) с **Granian** + **Valkey**.

---

## 🚀 Быстрый старт

```bash
git clone https://github.com/e-gleba/searxng-docker.git
cd searxng-docker
docker compose up -d
```

**Готово!**

- 🔍 **SearXNG**: http://localhost:8080 — веб-интерфейс поиска
- 🤖 **MCP сервер**: http://localhost:32769/sse — для LLM клиентов (Ollama, LM Studio, Claude Desktop, Cursor)

**Никаких `.env` файлов не нужно.**

---

## 🧪 Тестирование сервисов

### Проверка статуса контейнеров

```bash
docker compose ps
```

Должны быть `Up`:
- `searxng-core` (порт 8080)
- `searxng-valkey`
- `searxng-mcp` (порт 32769)

### Тест SearXNG (порт 8080)

```bash
# Простой поиск
curl "http://localhost:8080/search?q=rust&format=json" | jq '.results[0]'

# Поиск с категориями
curl "http://localhost:8080/search?q=python&categories=it&format=json" | jq '.results[0]'

# Проверка что SearXNG отвечает
curl -I http://localhost:8080
```

### Тест MCP сервера (SSE транспорт)

```bash
# Проверить что SSE endpoint доступен
curl -I http://localhost:32769/sse

# Подключиться к SSE потоку (будет открыто соединение)
curl -N http://localhost:32769/sse
```

**Важно:** SSE (Server-Sent Events) работает иначе чем REST API:
1. Клиент открывает GET соединение на `/sse`
2. Сервер отправляет события в потоке
3. Для вызова инструментов клиент делает POST на отдельный endpoint

### Просмотр логов

```bash
# Логи всех контейнеров
docker compose logs -f

# Логи конкретного контейнера
docker compose logs -f core  # SearXNG
docker compose logs -f mcp   # MCP сервер
docker compose logs -f valkey  # Valkey кэш

# Последние 50 строк
docker compose logs --tail=50 core
```

---

## 🤖 MCP сервер (для LLM)

MCP (Model Context Protocol) сервер позволяет **локальным LLM моделям** искать в интернете через ваш SearXNG.

**Используется:** [The-AI-Workshops/searxng-mcp-server](https://github.com/The-AI-Workshops/searxng-mcp-server) с **SSE транспортом** — стабильнее чем HTTP, работает со всеми MCP клиентами.

### Доступные tools

| Tool | Описание |
|------|----------|
| `search(q, categories?, engines?, language?)` | Веб-поиск через SearXNG |

### Параметры поиска

| Параметр | Описание | Пример |
|----------|----------|--------|
| `q` | Поисковый запрос (обязательный) | `"rust programming"` |
| `categories` | Категории через запятую | `"general,images"` |
| `engines` | Движки через запятую | `"google,duckduckgo"` |
| `language` | Код языка | `"ru"`, `"en"` |
| `time_range` | Временной диапазон | `"day"`, `"month"`, `"year"` |
| `safesearch` | Безопасный поиск | `0`, `1`, `2` |

### Подключение к LLM клиентам

#### Claude Desktop

Откройте `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS) или `%APPDATA%\Claude\claude_desktop_config.json` (Windows):

```json
{
  "mcpServers": {
    "searxng": {
      "transport": "sse",
      "url": "http://localhost:32769/sse"
    }
  }
}
```

Перезапустите Claude Desktop.

#### Cursor

Settings → MCP → Add MCP Server:

```
Type: SSE
URL: http://localhost:32769/sse
```

Или в `.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "searxng": {
      "transport": "sse",
      "url": "http://localhost:32769/sse"
    }
  }
}
```

#### LM Studio

Настройки → MCP Servers → Add:

```
Transport: SSE
URL: http://localhost:32769/sse
```

#### Ollama + Open WebUI

Если используете [Open WebUI](https://openwebui.com/) с Ollama:

Settings → Tools → Add MCP Server:

```
Transport: SSE
URL: http://localhost:32769/sse
```

#### Continue (VS Code extension)

В `~/.continue/config.json`:

```json
{
  "mcpServers": [
    {
      "name": "searxng",
      "transport": "sse",
      "url": "http://localhost:32769/sse"
    }
  ]
}
```

### Пример использования

После подключения LLM сможет:

```
Пользователь: Найди последние новости о Rust 2026
LLM: [использует search] → возвращает результаты из Google, DuckDuckGo, Brave
LLM: Вот что я нашел...
```

### Настройка MCP сервера

Все настройки через environment variables в `docker-compose.yml`:

```yaml
environment:
  - SEARXNG_BASE_URL=http://searxng-core:8080  # URL SearXNG
  - HOST=0.0.0.0                                # Listen address
  - PORT=32769                                  # Порт MCP
  - TRANSPORT=sse                               # SSE транспорт
```

Перезапуск после изменений:

```bash
docker compose restart mcp
```

---

## ⌨️ Vim hotkeys

SearXNG поддерживает vim-навигацию:

| Клавиша | Действие |
|---|---|
| `j` / `k` | Вниз / вверх по результатам |
| `h` / `l` | Предыдущая / следующая страница |
| `/` | Фокус на поле поиска |
| `Enter` | Открыть выбранный результат |
| `o` | Открыть результат в новой вкладке |
| `n` / `N` | Следующая / предыдущая категория |
| `?` | Показать справку по hotkeys |

---

## 📋 Описание

[SearXNG](https://github.com/searxng/searxng) — свободный мета-поисковик, который агрегирует результаты из Google, DuckDuckGo, Brave и десятков других движков, **не отслеживая вас**.

Этот репозиторий содержит:

- ✅ `docker-compose.yml` на базе официального шаблона 2026
- ✅ **Granian** (Rust ASGI-сервер) вместо устаревшего uWSGI
- ✅ **Valkey 9** (Redis fork) для кэширования
- ✅ **MCP сервер** для подключения LLM клиентов (Ollama, LM Studio, Claude Desktop, Cursor)
- ✅ `settings.yml` с `use_default_settings: true` — загружает все официальные дефолты
- ✅ **Оптимизировано для скорости** — уменьшены таймауты, отключены медленные движки
- ✅ **Vim hotkeys** — навигация без мыши
- ✅ **Dark theme** — современная темная тема
- ✅ **Custom dev-движки** — cppreference, devdocs.io
- ✅ Русская локаль из коробки
- ✅ **Одна команда для запуска** — никаких лишних файлов

---

## 🎨 Тема

Используется встроенная тема `simple` с **dark** стилем — минималистичная, быстрая, современная.

**Почему не catppuccin?** Catppuccin SearXNG [архивирован](https://github.com/catppuccin/SearXNG) и не поддерживается.

**Почему не paulgoio/searxng?** Это отдельный Docker образ с модифицированной темой, не просто тема.

**Встроенная тема `simple`** — официальная, поддерживаемая, быстрая. Имеет 4 стиля:
- `auto` — следует системной теме
- `light` — светлая
- `dark` — темная (используется)
- `black` — черная (AMOLED)

Изменить стиль в `core-config/settings.yml`:

```yaml
ui:
  theme_args:
    simple_style: black  # или auto, light, dark
```

---

## ⚡ Оптимизации

### Удалено (bloat)
- ❌ Bing (все виды)
- ❌ Yahoo
- ❌ Qwant
- ❌ Mojeek (медленный)
- ❌ HackerNews (часто таймаутит)
- ❌ ahmia, torch (Tor-only движки)

### Оптимизировано
- ⚡ `request_timeout`: 6.0s → **4.0s** (быстрее отклик)
- ⚡ `max_request_timeout`: 15.0s → **10.0s**
- ⚡ Уменьшены таймауты для arXiv, PubMed, CrossRef

### Добавлено (custom)
- 🛠️ **cppreference** (`!cpp`) — C++ документация
- 🛠️ **cppreference ru** (`!cppru`) — русская версия
- 🛠️ **devdocs** (`!dd`) — унифицированная документация

### Включено
- ✅ Yandex, Yandex Images (были отключены по умолчанию)

---

## 🐧 Установка Docker — Linux

### Ubuntu / Debian

```bash
sudo apt update && sudo apt install -y docker.io docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
```

### Fedora

```bash
sudo dnf install -y docker docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
```

### Arch Linux

```bash
sudo pacman -Syu docker docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
```

> ⚠️ После `usermod` **перезайдите в сессию** (или выполните `newgrp docker`).

---

## 🪟 Установка Docker — Windows 11

### Требования

| Компонент | Минимум |
|---|---|
| ОС | Windows 11 (22H2+) или Windows 10 (22H2+) |
| CPU | 64-bit, поддержка виртуализации (VT-x / AMD-V) |
| RAM | 4 ГБ (рекомендуется 8+) |
| WSL | WSL 2 (устанавливается автоматически) |

### Шаг 1 — Включить WSL 2

Откройте **PowerShell от имени администратора**:

```powershell
wsl --install
```

**Перезагрузите ПК** после завершения.

> 📖 [Install WSL on Windows](https://learn.microsoft.com/en-us/windows/wsl/install)

### Шаг 2 — Установить Docker Desktop

1. Скачайте: [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/)
2. Запустите установщик
3. Включите:
   - ✅ **Use WSL 2 instead of Hyper-V**
   - ✅ **Add shortcut to desktop**
4. Нажмите **OK** → **перезагрузите ПК**

> 📖 [Install Docker Desktop on Windows](https://docs.docker.com/desktop/setup/install/windows-install/)

### Шаг 3 — Настроить Docker Desktop

1. Запустите **Docker Desktop**
2. **Settings** (⚙️) → **General**:
   - ✅ **Start Docker Desktop when you log in**
   - ✅ **Use the WSL 2 based engine**
3. **Settings** → **Resources** → **WSL integration**:
   - ✅ **Enable integration with my default WSL distro**
4. **Apply & Restart**

### Шаг 4 — Запустить SearXNG

Откройте **PowerShell** или **Windows Terminal**:

```powershell
git clone https://github.com/e-gleba/searxng-docker.git
cd searxng-docker
docker compose up -d
```

Откройте **http://localhost:8080** — готово.

### ⚡ Частые проблемы на Windows

| Проблема | Решение |
|---|---|
| `docker: command not found` | Перезапустите терминал после установки Docker Desktop |
| `WSL 2 is not installed` | Выполните `wsl --install` и перезагрузитесь |
| Порт 8080 занят | Измените порт в `core-config/settings.yml` и `docker-compose.yml` |
| `permission denied` | Убедитесь, что Docker Desktop запущен (иконка в трее) |
| Connection refused | Смотрите раздел [🔥 Не открывается на 8080](#-не-открывается-на-8080-решение) |

> 💡 Используйте [Windows Terminal](https://aka.ms/terminal) + [Oh My Posh](https://ohmyposh.dev/) для удобной работы.

---

## 📦 Установка и запуск

```bash
git clone https://github.com/e-gleba/searxng-docker.git
cd searxng-docker
docker compose up -d
```

Запускаются **3 контейнера**:
- `searxng-core` — поисковик (Granian ASGI) на порту **8080**
- `searxng-valkey` — кэш Valkey 9 (Redis fork)
- `searxng-mcp` — MCP сервер для LLM на порту **32769** (SSE)

**SearXNG**: http://localhost:8080  
**MCP endpoint**: http://localhost:32769/sse

---

## 🔄 Обновление репозитория (git pull)

### Правильное обновление

```bash
# 1. Остановить контейнеры
docker compose down

# 2. Обновить репозиторий
git pull

# 3. Пересоздать контейнеры с новыми настройками
docker compose up -d
```

### Если git pull выдает "permission denied"

**Причина:** Docker создал файлы от имени root в volumes.

**Решение:**

```bash
# Остановить контейнеры
docker compose down

# Удалить volumes (ВНИМАНИЕ: удалит кэш и данные!)
docker compose down -v

# Исправить права доступа
sudo chown -R $USER:$USER .

# Обновить репозиторий
git pull

# Пересоздать контейнеры
docker compose up -d
```

### Альтернатива: сохранить данные

```bash
# Остановить контейнеры
docker compose down

# Временно переместить volumes
mv core-config core-config.backup

# Обновить репозиторий
git pull

# Вернуть ваши настройки (если меняли settings.yml)
# cp core-config.backup/settings.yml core-config/settings.yml
rm -rf core-config.backup

# Пересоздать контейнеры
docker compose up -d
```

---

## 🔥 Не открывается на 8080? Решение

### 1. Проверьте, что все контейнеры запущены

```bash
docker compose ps
```

Должны быть `Up`: `searxng-core`, `searxng-valkey`, `searxng-mcp`. Если `Exited` или `Restarting`:

```bash
docker compose logs -f core
```

### 2. Проверьте логи

```bash
# Логи SearXNG
docker compose logs -f core

# Логи MCP
docker compose logs -f mcp

# Логи Valkey
docker compose logs -f valkey

# Все логи
docker compose logs -f

# Последние 50 строк
docker compose logs --tail=50
```

В логах вы увидите:
- Старт Granian-сервера и какие порты слушает
- Загруженные движки
- HTTP-запросы (какие URL, статусы, время)
- Ошибки подключения к поисковым движкам (timeout, 403, 429)

### 3. Проверьте, что порт свободен

```bash
# Linux
ss -tlnp | grep 8080

# Windows (PowerShell)
netstat -ano | findstr "8080"
```

Если порт занят — измените в двух местах:

**1. `docker-compose.yml`** — строка с портами:
```yaml
ports:
  - "9090:8080"  # внешний:внутренний
```

**2. `core-config/settings.yml`** — секция `server`:
```yaml
server:
  port: 8080  # внутренний порт (не меняйте)
  base_url: "http://localhost:9090/"  # внешний URL
```

Затем:
```bash
docker compose down && docker compose up -d
```

### 4. Убедитесь, что `core-config/settings.yml` существует

```bash
ls core-config/
# Должен быть: settings.yml
```

### 5. Полный сброс

```bash
docker compose down -v
docker compose up -d
```

### 6. Windows: проверьте WSL integration

В Docker Desktop → Settings → Resources → WSL integration — ваша Ubuntu должна быть **включена**.

### 7. Зайдите в контейнер для отладки

```bash
docker compose exec -it --user root core /bin/sh -l
# Внутри контейнера:
cat /etc/searxng/settings.yml  # проверить конфиг
curl -v http://localhost:8080  # проверить, отвечает ли Granian
```

---

## 📊 Логирование

SearXNG использует **Granian** (Rust ASGI-сервер). Логи пишутся в stdout/stderr контейнера.

```bash
# Логи SearXNG в реальном времени
docker compose logs -f core

# Логи MCP сервера
docker compose logs -f mcp
```

Что видно в логах:
- Старт Granian (listening on 0.0.0.0:8080)
- HTTP-запросы к SearXNG (GET/POST, URL, статус, время в мс)
- Запросы к поисковым движкам
- Ошибки движков (timeout, 403, 429)
- MCP requests от LLM клиентов

### Пример лога при поиске

```
searxng-core  | [INFO] granian::http: 172.18.0.1 - "POST /search HTTP/1.1" 200 15234 (1823ms)
searxng-mcp   | INFO:root:SSE connection established from 172.18.0.1
```

---

## 🔄 Обновление SearXNG

```bash
docker compose pull && docker compose up -d
```

Данные сохраняются в named volumes (`core-data`, `valkey-data`) — обновление их не затрагивает.

---

## ⚙️ Изменение настроек

**Все настройки SearXNG хранятся в `core-config/settings.yml`.**

Файл использует `use_default_settings: true` — это загружает все официальные дефолты из [официального settings.yml](https://github.com/searxng/searxng/blob/master/searx/settings.yml), а мы переопределяем только нужное.

После изменений перезапустите:

```bash
docker compose restart core
```

### Смена `secret_key`

**Обязательно** смените `secret_key` в `core-config/settings.yml`:

```bash
# Linux / macOS
openssl rand -hex 32

# Windows (PowerShell)
[System.BitConverter]::ToString((1..32 | ForEach-Object { Get-Random -Minimum 0 -Maximum 256 })).Replace("-","").ToLower()
```

Скопируйте результат в поле `server.secret_key`.

### Изменение порта

Если порт 8080 занят, измените в двух местах:

**1. `docker-compose.yml`** — маппинг портов:
```yaml
ports:
  - "9090:8080"  # формат: внешний_порт:внутренний_порт
```

**2. `core-config/settings.yml`** — base_url:
```yaml
server:
  port: 8080  # НЕ МЕНЯЙТЕ (внутренний порт контейнера)
  base_url: "http://localhost:9090/"  # внешний URL
```

Затем `docker compose down && docker compose up -d`.

### Смена темы

Изменить стиль темы (auto, light, dark, black):

```yaml
ui:
  theme_args:
    simple_style: black  # AMOLED-friendly
```

Затем `docker compose restart core`.

---

## 🔧 Управление движками (engines)

С `use_default_settings: true` **все официальные движки уже доступны**. Популярные включены по умолчанию:

- ✅ Google, Google Images, Google News, Google Videos, Google Scholar
- ✅ DuckDuckGo
- ✅ Brave (+ Images, Videos, News)
- ✅ Wikipedia, Wikidata
- ✅ GitHub, Stack Overflow, GitLab
- ✅ arXiv, PubMed
- ✅ OpenStreetMap
- ✅ YouTube, Vimeo, Dailymotion
- ✅ Startpage
- ✅ Yandex, Yandex Images (включены вручную)
- ✅ **cppreference** (`!cpp`) — custom
- ✅ **cppreference ru** (`!cppru`) — custom
- ✅ **devdocs** (`!dd`) — custom

Движки, отключённые вручную (bloat):
- ❌ Bing (все виды)
- ❌ Yahoo
- ❌ Qwant
- ❌ Mojeek
- ❌ HackerNews
- ❌ ahmia, torch (Tor-only)

### Включение движка

```yaml
engines:
  - name: bing
    disabled: false
```

### Отключение движка

```yaml
engines:
  - name: google
    disabled: true
```

---

## 📁 Структура репозитория

```
searxng-docker/
├── docker-compose.yml          # Оркестрация (SearXNG + Valkey + MCP)
├── core-config/
│   └── settings.yml            # ВСЕ настройки SearXNG (единственный конфиг)
├── .env.example                # Пример необязательных переменных
├── .gitignore                  # Git ignore правила
├── .dockerignore               # Docker build context ignore
└── README.md                   # Эта документация
```

**Named volumes** (создаются автоматически):
- `core-data` → `/var/cache/searxng/` (favicon cache, данные)
- `valkey-data` → `/data/` (кэш Valkey)

---

## 🛡️ Безопасность и производительность

- HTTP-заголовки безопасности (X-Frame-Options, X-XSS-Protection, Referrer-Policy)
- `limiter: false` — подходит для приватного инстанса (не для публичного!)
- `image_proxy: true` — проксирование картинок через SearXNG для приватности
- **Телеметрия отключена** (`enable_metrics: false`)
- **Valkey** для кэширования (быстрее и безопаснее Redis)
- **Оптимизированные таймауты** — быстрее отклик
- **Vim hotkeys** — навигация без мыши
- **MCP сервер** — приватный поиск для LLM (без API ключей, без утечки данных)

> Для **публичного** инстанса включите `server.limiter: true` и настройте reverse proxy (nginx/caddy).

---

## 📄 Лицензия

Этот репозиторий — конфигурация для [SearXNG](https://github.com/searxng/searxng), который распространяется под лицензией **AGPL-3.0**.
