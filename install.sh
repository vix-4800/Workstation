#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(pwd)"
BIN_SRC="${REPO_ROOT}/bin/dotfiles"
LOCAL_BIN="${HOME}/.local/bin"
TARGET_BIN="${LOCAL_BIN}/dotfiles"

mkdir -p "${LOCAL_BIN}"

sed "s|^REPO_ROOT=.*|REPO_ROOT=\"${REPO_ROOT}\"|" "${BIN_SRC}" > "${TARGET_BIN}"
chmod 0755 "${TARGET_BIN}"

ensure_alias() {
    local rcfile="$1"
    local line="alias dotfiles='${TARGET_BIN}'"
    touch "${rcfile}"
    if ! grep -Fq "${line}" "${rcfile}"; then
        echo "${line}" >> "${rcfile}"
        echo "[install] Added alias to ${rcfile}"
    else
        echo "[install] Alias already exists in ${rcfile}"
    fi
}

ensure_alias "${HOME}/.zshrc"

if ! command -v dotfiles >/dev/null 2>&1; then
    echo "[install] It seems ~/.local/bin is not in PATH. Add this line to your rc file:"
    echo 'export PATH="$HOME/.local/bin:$PATH"'
else
    echo "[install] Done. Example: dotfiles status"
fi
