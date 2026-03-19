# Plan: AI Agent Enhancement for PHP/DevOps Stack

## Context

Задача — улучшить рабочие процессы с тремя CLI-агентами (Claude Code, Codex, Qwen Code) под стек PHP/Laravel/Yii2 + Ansible/DevOps + код-ревью GitHub PR.

**Текущий статус (что уже настроено):**

- Claude Code: plugins = security-guidance, serena, php-lsp, lua-lsp, commit-commands; **нет MCP серверов** в settings.json
- Codex: MCPs = github, serena, context7, docker; multi-agent = true
- Qwen: MCPs = github, serena, context7, docker; auto-edit режим
- Общие skills (симлинки во все три агента): `coding-standards`, `security-review`, `api-design`, `backend-patterns` — **все четыре написаны для TypeScript/React/Next.js**, не PHP
- AGENTS.md: подробные PHP/security правила — хорошо, шарится между всеми тремя

**Ключевые проблемы:**

1. Все 4 skills про TypeScript — PHP/Laravel разработчик работает без PHP-специфичных skills
2. Claude Code не имеет MCP серверов (несоответствие с Codex/Qwen)
3. Плагины `code-review` и `laravel-boost` есть в marketplace, но НЕ установлены
4. Нет hooks кроме security-guidance pre-edit предупреждения
5. Нет skills для Ansible/DevOps workflow

---

## Изменения по приоритету

### Tier 1: Плагины и MCP для Claude Code

**1. Включить плагин `code-review`** (`claude-plugins-official`)

- Добавить в `roles/ai-tools/files/claude/settings.json` → `enabledPlugins`
- Даёт команду `/code-review <PR_URL_или_номер>` с мульти-агентным ревью: 5 параллельных Sonnet агентов, confidence scoring, автоматический комментарий в PR через `gh`
- Работает с GitHub — подходит под ответ пользователя

**2. Добавить MCP серверы в Claude Code** (привести в соответствие с Codex/Qwen)
Добавить в `roles/ai-tools/files/claude/settings.json` → `mcpServers`:

```json
"github": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-github"] },
"context7": { "command": "npx", "args": ["-y", "@upstash/context7-mcp@latest"] },
"docker": { "command": "uvx", "args": ["--with", "fastmcp[tasks]", "mcp-docker"] }
```

Context7 особенно полезен: актуальная документация Laravel, PHP, Ansible прямо в контексте агента.

**3. Включить плагин `laravel-boost`** (`claude-plugins-official`)

- Laravel MCP toolkit: Artisan команды, Eloquent queries, routing, migrations
- Требует `php artisan boost:mcp` внутри Laravel проекта — добавить в settings.json как enabled plugin
- Добавить проектный `.mcp.json` в laravel проекты (шаблон в плане)

---

### Tier 2: Новые PHP/DevOps Skills

Все skills симлинкуются в `~/.claude/skills/`, `~/.qwen/skills/` и используются AGENTS.md для Codex. Создать в `roles/ai-tools/files/agents/skills/`.

**4. Создать skill `php-laravel`** (новый файл)
`roles/ai-tools/files/agents/skills/php-laravel/SKILL.md`

Структура skill:

```yaml
---
name: php-laravel
description: PHP and Laravel development patterns. Activate when writing PHP code, Laravel controllers/models/jobs/policies, running phpcs/phpstan/rector, or fixing PHP type errors.
disable-model-invocation: false
allowed-tools: Read, Grep, Glob, Bash(php *), Bash(composer *), Bash(./vendor/bin/phpcs *), Bash(./vendor/bin/phpstan *), Bash(./vendor/bin/rector *)
---
```

Содержимое skill охватывает:

- `declare(strict_types=1)` enforcement, readonly properties, constructor promotion
- Laravel: thin controllers, Form Requests, Policies, Jobs/Events, Service Providers
- Yii2: components, behaviors, validators pattern
- Запрещённые паттерны: empty(), isset() для логики, global, $$var, @suppress
- SOLID checklist специфичный для PHP
- Команды анализа: phpcs, phpstan, rector dry-run
- Примеры хорошего/плохого PHP кода (в отличие от нынешних TS примеров)

**5. Создать skill `ansible-devops`** (новый файл)
`roles/ai-tools/files/agents/skills/ansible-devops/SKILL.md`

```yaml
---
name: ansible-devops
description: Ansible playbooks, roles and DevOps tasks. Activate when writing Ansible tasks, roles, inventory, Proxmox automation, or infrastructure provisioning.
disable-model-invocation: false
allowed-tools: Read, Grep, Glob, Bash(ansible-lint *), Bash(ansible-playbook --check *), Bash(ansible-playbook --syntax-check *)
---
```

Содержимое охватывает:

- Структуру ролей: defaults/main.yml, tasks/main.yml, handlers/main.yml
- Теги: каждый task должен иметь role-tag + type-tag (packages/config/services/system)
- 2-space YAML indentation (как в CLAUDE.md проекта)
- `community.general.pacman` для Arch, `kewlfft.aur.aur` для AUR
- `become: true` только где нужно
- Шаблоны vault/secrets, не хранить credentials plaintext
- Идемпотентность: `creates:`, `changed_when:`, `failed_when:`
- Proxmox provisioning паттерны через community.general.proxmox
- Запуск `ansible-lint` и `--check` перед применением

**6. Обновить skill `coding-standards`**
`roles/ai-tools/files/agents/skills/coding-standards/SKILL.md`

Текущий файл посвящён TypeScript/React. Добавить секцию PHP в начало (PHP — основной язык):

- PSR-1, PSR-4, PSR-12 summary
- PHP naming conventions (camelCase methods, PascalCase classes, UPPER_SNAKE constants)
- PHP-специфичные code smells
- Оставить TypeScript секцию для случаев когда работает с TS

**7. Обновить skill `security-review`**
`roles/ai-tools/files/agents/skills/security-review/SKILL.md`

Текущий файл содержит только TypeScript/Supabase/Blockchain примеры. Добавить PHP/Laravel секцию:

- Laravel Mass Assignment protection (`$fillable`, `$guarded`)
- SQL Injection в raw queries (`DB::select()` с параметрами)
- CSRF в Laravel (встроенный middleware vs. API routes)
- File upload validation (MIME server-side, вне web root)
- `.env` и vault для secrets
- Laravel authorization: Gates, Policies, не only middleware

---

### Tier 3: Hooks

Добавить в `roles/ai-tools/files/claude/settings.json` → `hooks`:

**8. Stop hook: уведомление о завершении**

```json
"Stop": [{
  "hooks": [{"type": "command", "command": "notify-send 'Claude Code' 'Задача завершена'"}],
  "matcher": ""
}]
```

**9. PreToolUse hook: блокировка debug-кода в PHP**
Скрипт проверяет перед Edit/Write: если файл `.php` и содержит `dd(`, `var_dump(`, `print_r(`, `dump(` — выводит предупреждение (не блокирует, но предупреждает через stderr/exit code 2 для warning).

Создать: `roles/ai-tools/files/claude/hooks/php_debug_guard.sh`
Добавить в hooks.json или settings.json:

```json
"PreToolUse": [{
  "hooks": [{"type": "command", "command": "~/.claude/hooks/php_debug_guard.sh"}],
  "matcher": "Edit|Write|MultiEdit"
}]
```

Ansible task для симлинка скрипта в `~/.claude/hooks/`.

---

## Файлы для изменения

| Файл | Действие |
|------|----------|
| `roles/ai-tools/files/claude/settings.json` | Добавить mcpServers, включить code-review + laravel-boost plugins, добавить hooks |
| `roles/ai-tools/files/agents/skills/php-laravel/SKILL.md` | Создать новый |
| `roles/ai-tools/files/agents/skills/ansible-devops/SKILL.md` | Создать новый |
| `roles/ai-tools/files/agents/skills/coding-standards/SKILL.md` | Добавить PHP секцию |
| `roles/ai-tools/files/agents/skills/security-review/SKILL.md` | Добавить PHP/Laravel секцию |
| `roles/ai-tools/files/claude/hooks/php_debug_guard.sh` | Создать новый |
| `roles/ai-tools/tasks/main.yml` | Добавить симлинк для hooks скрипта |
| `roles/ai-tools/defaults/main.yml` | Добавить hooks скрипт в symlinks (при необходимости) |

**Не затрагиваем:**

- `roles/ai-tools/files/codex/config.toml` — Codex уже имеет все MCPs
- `roles/ai-tools/files/qwen/settings.json` — Qwen уже имеет все MCPs
- `AGENTS.md` / `CLAUDE.md` — глобальные инструкции уже хорошо написаны

---

## Почему НЕ включаем некоторые вещи

- **gitlab MCP**: пользователь использует GitHub для PR ревью
- **MySQL/PostgreSQL MCP**: не упомянут в стеке, добавить позже по необходимости
- **cc-devops-skills из community**: ansible-generator/validator имеют зависимости от внешних инструментов (terraform, k8s) не входящих в стек; лучше сделать свой ansible-devops skill
- **Trail of Bits security skills**: не имеют PHP правил, только Go/Ruby/Python/HCL

---

## Проверка после внесения изменений

1. `just apply` или `ansible-playbook site.yml --tags ai-tools` — применить конфиг
2. Перезапустить Claude Code, проверить `/code-review` команду в GitHub PR
3. Проверить что skills загружаются: в любом PHP проекте набрать `/php-laravel`
4. В директории с Ansible rolями набрать `/ansible-devops`
5. Проверить Stop hook: после завершения задачи должно прийти desktop уведомление
6. Проверить debug hook: попробовать написать `dd($var)` в PHP файле, должно выйти предупреждение
7. Context7 MCP: спросить Claude "use context7 to check Laravel version X docs on..."
