# 🔍 SearXNG Docker

> Приватный мета-поисковик **SearXNG** — готовый к запуску в Docker.  
> Основано на [официальной архитектуре 2026](https://docs.searxng.org/admin/installation-docker.html) с **Granian** + **Valkey**.

---

## 🚀 Быстрый старт

```bash
git clone https://github.com/e-gleba/searxng-docker.git
cd searxng-docker
docker compose up -d
```

Откройте **http://localhost:8080** — поиск готов.

**Всё. Никаких `.env` файлов не нужно.**

---

## 📋 Описание

[SearXNG](https://github.com/searxng/searxng) — свободный мета-поисковик, который агрегирует результаты из Google, DuckDuckGo, Brave и десятков других движков, **не отслеживая вас**.

Этот репозиторий содержит:

- ✅ `docker-compose.yml` на базе официального шаблона 2026
- ✅ **Granian** (Rust ASGI-сервер) вместо устаревшего uWSGI
- ✅ **Valkey 9** (Redis fork) для кэширования
- ✅ `settings.yml` с `use_default_settings: true` — загружает все официальные дефолты
- ✅ Русская локаль из коробки
- ✅ **Одна команда для запуска** — никаких лишних файлов

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

SearXNG будет доступен на **http://localhost:8080**.

Запускаются **2 контейнера**:
- `searxng-core` — поисковик (Granian ASGI)
- `searxng-valkey` — кэш Valkey 9 (Redis fork)

---

## 🔥 Не открывается на 8080? Решение

### 1. Проверьте, что оба контейнера запущены

```bash
docker compose ps
```

Должны быть `Up`: `searxng-core` и `searxng-valkey`. Если `Exited` или `Restarting`:

```bash
docker compose logs -f core
```

### 2. Проверьте логи

```bash
# Логи SearXNG
docker compose logs -f core

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
```

Что видно в логах:
- Старт Granian (listening on 0.0.0.0:8080)
- HTTP-запросы к SearXNG (GET/POST, URL, статус, время в мс)
- Запросы к поисковым движкам
- Ошибки движков (timeout, 403, 429)

### Пример лога при поиске

```
searxng-core  | [INFO] granian::http: 172.18.0.1 - "POST /search HTTP/1.1" 200 15234 (1823ms)
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
- ✅ и многие другие

Движки, отключённые по умолчанию, включаются в `core-config/settings.yml`:

```yaml
engines:
  - name: yandex
    disabled: false

  - name: yandex images
    disabled: false

  - name: bing
    disabled: false
```

Полный список движков: [официальная документация](https://docs.searxng.org/user/configured_engines.html).

### Отключение движка

```yaml
engines:
  - name: google
    disabled: true
```

### Добавление тем

Темы меняются в секции `ui`:

```yaml
ui:
  default_theme: simple      # simple, oscar, pix-art, legacy
  theme_args:
    simple_style: auto       # auto, light, dark
```

---

## 📁 Структура репозитория

```
searxng-docker/
├── docker-compose.yml          # Оркестрация (SearXNG + Valkey)
├── core-config/
│   └── settings.yml            # ВСЕ настройки SearXNG (единственный конфиг)
├── .env.example                # Пример необязательных переменных
├── README.md
└── .gitignore
```

**Named volumes** (создаются автоматически):
- `core-data` → `/var/cache/searxng/` (favicon cache, данные)
- `valkey-data` → `/data/` (кэш Valkey)

---

## 🛡️ Безопасность

- HTTP-заголовки безопасности (X-Frame-Options, X-XSS-Protection, Referrer-Policy)
- `limiter: false` — подходит для приватного инстанса (не для публичного!)
- `image_proxy: true` — проксирование картинок через SearXNG для приватности
- Телеметрия и метрики **отключены**
- **Valkey** для кэширования (быстрее и безопаснее Redis)

> Для **публичного** инстанса включите `server.limiter: true` и настройте reverse proxy (nginx/caddy).

---

## 📄 Лицензия

Этот репозиторий — конфигурация для [SearXNG](https://github.com/searxng/searxng), который распространяется под лицензией **AGPL-3.0**.
