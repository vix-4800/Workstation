#!/usr/bin/env bash

set -euo pipefail

# =========================
# Dotfiles installer
# =========================
# Опции:
#   --force       перезаписывать существующие файлы (если это не симлинк на репо)
#   --no-backup   не создавать .bak бэкап перед заменой
#   --dry-run     только показать, что будет сделано
#   --verbose     подробный вывод

FORCE=false
NO_BACKUP=false
DRY_RUN=false
VERBOSE=false

log() {
  echo "[dotfiles] $*"
}

vlog() {
  if $VERBOSE; then
    log "$@"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) FORCE=true; shift ;;
    --no-backup) NO_BACKUP=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    --verbose|-v) VERBOSE=true; shift ;;
    *) log "Неизвестная опция: $1"; exit 2 ;;
  esac
done
unset case_esac_done # shellcheck disable=SC2034

# Определим корень репозитория
# realpath есть на большинстве систем; fallback через pwd
if command -v realpath >/dev/null 2>&1; then
  REPO_DIR="$(realpath "$(dirname "$0")")"
else
  pushd "$(dirname "$0")" >/dev/null
  REPO_DIR="$PWD"
  popd >/dev/null
fi

HOME_DIR="${HOME}"

# Карта источников (в репо) -> целей (в системе)
# Логику можно расширять при добавлении новых файлов
declare -a SOURCES
declare -a TARGETS

# Shell
SOURCES+=("$REPO_DIR/shell/.bashrc")
TARGETS+=("$HOME_DIR/.bashrc")

SOURCES+=("$REPO_DIR/shell/.zshrc")
TARGETS+=("$HOME_DIR/.zshrc")

# Editorconfig
SOURCES+=("$REPO_DIR/.editorconfig")
TARGETS+=("$HOME_DIR/.editorconfig")

# PHP
SOURCES+=("$REPO_DIR/php/php-cs-fixer.php")
TARGETS+=("$HOME_DIR/.config/php-cs-fixer/php-cs-fixer.php")

SOURCES+=("$REPO_DIR/php/phpstan.neon")
TARGETS+=("$HOME_DIR/.config/phpstan/phpstan.neon")

SOURCES+=("$REPO_DIR/php/rector.php")
TARGETS+=("$HOME_DIR/.config/rector/rector.php")

# Python
SOURCES+=("$REPO_DIR/python/.flake8")
TARGETS+=("$HOME_DIR/.config/flake8/flake8")

SOURCES+=("$REPO_DIR/python/mypy.ini")
TARGETS+=("$HOME_DIR/.config/mypy/config")

ensure_dir() {
  local dir_path="$1"
  if [[ -d "$dir_path" ]]; then
    return 0
  fi
  if $DRY_RUN; then
    log "mkdir -p $dir_path"
  else
    mkdir -p "$dir_path"
  fi
}

backup_if_needed() {
  local target="$1"
  if $NO_BACKUP; then
    return 0
  fi
  if [[ -e "$target" || -L "$target" ]]; then
    # Бэкапим только если это не симлинк уже на наш репо-файл
    if [[ -L "$target" ]]; then
      local link_target
      link_target="$(readlink "$target" || true)"
      if [[ "$link_target" == "$2" ]]; then
        # Уже правильный симлинк — бэкап не нужен
        return 0
      fi
    fi
    local ts
    ts="$(date +%Y%m%d_%H%M%S)"
    local backup="${target}.bak.${ts}"
    if $DRY_RUN; then
      log "backup -> $backup"
    else
      mv -f "$target" "$backup"
      vlog "Создан бэкап: $backup"
    fi
  fi
}

link_file() {
  local src="$1"
  local dst="$2"

  if [[ ! -e "$src" ]]; then
    log "WARN: источника нет: $src — пропускаю"
    return 0
  fi

  local dst_dir
  dst_dir="$(dirname "$dst")"
  ensure_dir "$dst_dir"

  # Если уже правильный симлинк — пропускаем
  if [[ -L "$dst" ]]; then
    local link_target
    link_target="$(readlink "$dst" || true)"
    if [[ "$link_target" == "$src" ]]; then
      vlog "OK: уже связан -> $dst → $src"
      return 0
    fi
  fi

  # Если файл существует и не симлинк (или симлинк на другой файл)
  if [[ -e "$dst" || -L "$dst" ]]; then
    if ! $FORCE; then
      log "SKIP: $dst уже существует. Используйте --force для замены."
      return 0
    fi
    backup_if_needed "$dst" "$src"
    if $DRY_RUN; then
      log "rm -rf $dst"
    else
      rm -rf "$dst"
    fi
  fi

  if $DRY_RUN; then
    log "ln -s $src $dst"
  else
    ln -s "$src" "$dst"
    vlog "Связал: $dst → $src"
  fi
}

log "Репозиторий: $REPO_DIR"
log "Домашняя директория: $HOME_DIR"
$DRY_RUN && log "Режим: DRY-RUN (ничего не меняю)"

# Пробежимся по парам
for i in "${!SOURCES[@]}"; do
  src="${SOURCES[$i]}"
  dst="${TARGETS[$i]}"
  link_file "$src" "$dst"
done

log "Готово ✅"
$DRY_RUN && log "Это был только показ действий. Запустите без --dry-run для применения."
