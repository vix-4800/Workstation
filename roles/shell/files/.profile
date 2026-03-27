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

# Add Node.js path (if using nvm or manual installation)
if [[ -d "${HOME}/.local/share/nvm/v24.7.0/bin" ]]; then
    export PATH="${HOME}/.local/share/nvm/v24.7.0/bin:${PATH}"
fi

# ======= Environment Variables =======
export EDITOR="nvim"
export VISUAL="${EDITOR}"

# ======= Load shell-agnostic aliases =======
if [[ -f "${HOME}/.aliases" ]]; then
    . "${HOME}/.aliases"
fi
