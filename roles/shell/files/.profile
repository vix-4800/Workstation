# ~/.profile
# This file is sourced by all POSIX-compatible shells

# ======= PATH Configuration =======
# Add local bins
export PATH="${HOME}/.local/bin:${HOME}/bin:${PATH}"

# Add Go paths
export PATH="/usr/local/go/bin:${HOME}/go/bin:${PATH}"

# Add Composer global vendor bin
export PATH="${HOME}/.config/composer/vendor/bin:${PATH}"

# Add Cargo bin
if [[ -d "${HOME}/.cargo/bin" ]]; then
    export PATH="${HOME}/.cargo/bin:${PATH}"
fi

# Add Neovim AppImage path
export PATH="/opt/nvim-linux-x86_64/bin:${PATH}"

# Add Node.js path (nvm - resolve latest installed version)
nvm_dir="${HOME}/.local/share/nvm"
if [[ -d "${nvm_dir}" ]]; then
    nvm_node=$(ls -1 "${nvm_dir}" 2>/dev/null | sort -V | tail -1)
    if [[ -n "${nvm_node}" ]]; then
        export PATH="${nvm_dir}/${nvm_node}/bin:${PATH}"
    fi
fi

# ======= Environment Variables =======
export EDITOR="nvim"
export VISUAL="${EDITOR}"
export TAPLO_CONFIG="${HOME}/.config/taplo/taplo.toml"

# ======= Load shell-agnostic aliases =======
if [[ -f "${HOME}/.aliases" ]]; then
    . "${HOME}/.aliases"
fi
