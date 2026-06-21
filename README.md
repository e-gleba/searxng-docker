# 🔍 SearXNG Docker

> Приватный мета-поисковик **SearXNG** — готовый к запуску в Docker.
> Безопасные настройки из коробки, минимум телеметрии, удобный интерфейс.

---

## 🚀 Быстрый старт

```bash
git clone https://github.com/e-gleba/searxng-docker.git && cd searxng-docker && docker compose up -d
```

Откройте **http://localhost:8080** — поиск готов.

---

## 📋 Описание

[SearXNG](https://github.com/searxng/searxng) — свободный мета-поисковик, который агрегирует результаты из Google, DuckDuckGo, Brave и десятков других движков, **не отслеживая вас**.

Этот репозиторий содержит:

- ✅ Минимальный `docker-compose.yml` для запуска
- ✅ Преднастроенный `settings.yml` с безопасными дефолтами
- ✅ `.env.example` с понятными переменными
- ✅ Отключённая телеметрия и лишние плагины
- ✅ Русская локаль из коробки

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

Откройте **PowerShell от имени администратора** и выполните:

```powershell
wsl --install
```

Это установит WSL 2 + Ubuntu по умолчанию. **Перезагрузите ПК** после завершения.

> 📖 Подробная инструкция Microsoft: [Install WSL on Windows](https://learn.microsoft.com/en-us/windows/wsl/install)

### Шаг 2 — Установить Docker Desktop

1. Скачайте установщик: [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/)
2. Запустите `Docker%20Desktop%20Installer.exe`
3. В установщике убедитесь, что включены:
   - ✅ **Use WSL 2 instead of Hyper-V** (рекомендуется)
   - ✅ **Add shortcut to desktop**
4. Нажмите **OK** → дождитесь окончания → **перезагрузите ПК**

> 📖 Официальный гайд Docker: [Install Docker Desktop on Windows](https://docs.docker.com/desktop/setup/install/windows-install/)

### Шаг 3 — Настроить Docker Desktop

1. Запустите **Docker Desktop**
2. Перейдите в **Settings** (⚙️) → **General**:
   - ✅ **Start Docker Desktop when you log in**
   - ✅ **Use the WSL 2 based engine**
3. Перейдите в **Settings** → **Resources** → **WSL integration**:
   - ✅ **Enable integration with my default WSL distro**
   - Включите интеграцию для нужных дистрибутивов (Ubuntu и т.д.)
4. Нажмите **Apply & Restart**

### Шаг 4 — Запустить SearXNG

Откройте **PowerShell** или **Windows Terminal** в папке проекта:

```powershell
# Клонируем репозиторий
git clone https://github.com/e-gleba/searxng-docker.git
cd searxng-docker

# Создаём .env
copy .env.example .env

# Запускаем
docker compose up -d
```

Откройте **http://localhost:8080** в браузере — готово.

### ⚡ Частые проблемы на Windows

| Проблема | Решение |
|---|---|
| `docker: command not found` | Перезапустите терминал после установки Docker Desktop |
| `WSL 2 is not installed` | Выполните `wsl --install` и перезагрузитесь |
| Порт 8080 занят | Измените `SEARXNG_PORT` в `.env` на другой (например, `8888`) |
| `permission denied` при `docker compose` | Убедитесь, что Docker Desktop запущен (иконка в трее) |
| Контейнер падает с `exec format error` | В Docker Desktop → Settings → Docker Engine → убедитесь, что архитектура x86_64 |
| Медленная работа | Settings → Resources → увеличьте RAM/CPU для WSL 2 |

> 💡 **Совет:** Для удобной работы используйте [Windows Terminal](https://aka.ms/terminal) + [Oh My Posh](https://ohmyposh.dev/) — красивый prompt с Git-статусом.

---

## 📦 Установка и запуск

```bash
# 1. Клонируем репозиторий
git clone https://github.com/e-gleba/searxng-docker.git
cd searxng-docker

# 2. Создаём .env из примера (опционально — можно редактировать)
cp .env.example .env        # Linux / macOS
# copy .env.example .env    # Windows (PowerShell / CMD)

# 3. Запускаем
docker compose up -d
```

SearXNG будет доступен на **http://localhost:8080**.

---

## 🔄 Обновление SearXNG

```bash
# Подтянуть новый образ и пересоздать контейнер
docker compose pull && docker compose up -d
```

Данные и настройки сохраняются в `./searxng/` и `./data/` — обновление их не затрагивает.

---

## ⚙️ Изменение настроек

Все настройки SearXNG хранятся в `searxng/settings.yml`.

**Важно:**
- Ключи — в **snake_case**
- После изменений пересоздайте контейнер:

```bash
docker compose restart
```

### Смена `secret_key`

**Обязательно** смените `secret_key` в `searxng/settings.yml` на случайную строку:

```bash
# Linux / macOS
openssl rand -hex 32

# Windows (PowerShell)
[System.BitConverter]::ToString((1..32 | ForEach-Object { Get-Random -Minimum 0 -Maximum 256 })).Replace("-","").ToLower()
```

Скопируйте результат в поле `server.secret_key`.

---

## 🔧 Добавление собственных движков (engines)

Откройте `searxng/settings.yml` → секция `engines`.

Пример — добавить Yandex:

```yaml
  - name: yandex
    engine: yandex
    shortcut: yd
    disabled: false
```

Полный список движков: [документация SearXNG](https://docs.searxng.org/user/configured_engines.html).

### Добавление тем

Темы меняются в секции `ui`:

```yaml
ui:
  default_theme: simple      # simple, oscar, pix-art, legacy
  theme_args:
    simple_style: auto       # auto, light, dark
```

---

## 🌐 Переменные окружения

Все переменные задаются в файле `.env` (создаётся из `.env.example`).

| Переменная | По умолчанию | Описание |
|---|---|---|
| `SEARXNG_PORT` | `8080` | Порт, на котором слушает SearXNG |
| `SEARXNG_IMAGE_TAG` | `latest` | Тег Docker-образа |
| `INSTANCE_NAME` | `SearXNG` | Название инстанса в заголовке страницы |
| `AUTOCOMPLETE` | `google` | Движок автодополнения (`google`, `duckduckgo`, `wikipedia`, `startpage`, или `""`) |
| `BASE_URL` | `http://localhost:8080/` | Публичный URL инстанса |

---

## 📁 Структура репозитория

```
searxng-docker/
├── docker-compose.yml      # Оркестрация контейнеров
├── .env.example            # Пример переменных окружения
├── searxng/
│   └── settings.yml        # Конфиг SearXNG
├── data/                   # Данные SearXNG (создаётся автоматически)
├── README.md
└── .gitignore
```

---

## 🛡️ Безопасность

- `cap_drop: ALL` + минимальные `cap_add` (CHOWN, SETGID, SETUID)
- HTTP-заголовки безопасности (X-Frame-Options, CSP, Referrer-Policy)
- `limiter: false` — подходит для приватного инстанса (не для публичного!)
- `image_proxy: true` — проксирование картинок через SearXNG для приватности
- Телеметрия и метрики **отключены**

> Для **публичного** инстанса включите `server.limiter: true` и настройте reverse proxy (nginx/caddy).

---

## 📄 Лицензия

Этот репозиторий — конфигурация для [SearXNG](https://github.com/searxng/searxng), который распространяется под лицензией **AGPL-3.0**.
