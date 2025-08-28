#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(pwd)"
BIN_SRC="${REPO_ROOT}/bin/dotfiles"
LOCAL_BIN="${HOME}/.local/bin"
TARGET_BIN="${LOCAL_BIN}/dotfiles"

mkdir -p "${LOCAL_BIN}"

# Создаем модифицированную версию скрипта с жестко заданным REPO_ROOT
sed "s|^REPO_ROOT=.*|REPO_ROOT=\"${REPO_ROOT}\"|" "${BIN_SRC}" > "${TARGET_BIN}"
chmod 0755 "${TARGET_BIN}"

ensure_alias() {
  local rcfile="$1"
  local line="alias dotfiles='${TARGET_BIN}'"
  touch "${rcfile}"
  if ! grep -Fq "${line}" "${rcfile}"; then
    echo "${line}" >> "${rcfile}"
    echo "[install] Добавлен алиас в ${rcfile}"
  else
    echo "[install] Алиас уже есть в ${rcfile}"
  fi
}

ensure_alias "${HOME}/.zshrc"

# Убедимся, что ~/.local/bin в PATH (на будущее)
if ! command -v dotfiles >/dev/null 2>&1; then
  echo "[install] Похоже, ~/.local/bin не в PATH. Добавь в rc-файл строку:"
  echo 'export PATH="$HOME/.local/bin:$PATH"'
else
  echo "[install] Готово. Пример: dotfiles status"
fi
