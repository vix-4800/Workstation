# Configuration Management System

This repository now uses a modern YAML-based configuration system for better maintainability and readability.

## Overview

The configuration system supports two formats:

1. **YAML Format** (`dotfiles.yaml`) - **Recommended**: Human-readable, organized, easy to edit
2. **Legacy Format** (`linux.confmap`) - Tab-separated format for backward compatibility

## YAML Configuration Format

Edit `dotfiles.yaml` to manage your dotfile mappings:

```yaml
# Development tools configuration
development:
  php-cs-fixer: ~/.config/php-cs-fixer
  phpstan: ~/.config/phpstan
  nvim: ~/.config/nvim

# Shell configurations
shell:
  .profile: ~/.profile
  .aliases: ~/.aliases
  bash/bashrc: ~/.bashrc
  zsh/zshrc: ~/.zshrc
  fish: ~/.config/fish

# Desktop environment
desktop:
  sway: ~/.config/sway
  waybar: ~/.config/waybar
  alacritty: ~/.config/alacritty

# Applications
applications:
  git/gitconfig: ~/.gitconfig
  tmux/.tmux.conf: ~/.tmux.conf
```

## Commands

### Using the config helper script:

```bash
# Edit the YAML configuration
./bin/config edit

# Generate linux.confmap from YAML
./bin/config generate

# Validate YAML syntax
./bin/config validate

# Show help
./bin/config help
```

### Using the main dotfiles script:

The `dotfiles` script automatically detects when `dotfiles.yaml` is newer than `linux.confmap` and regenerates it:

```bash
# These commands will auto-generate confmap if needed
./bin/dotfiles link
./bin/dotfiles status
./bin/dotfiles unlink
```

## Benefits of YAML Format

✅ **Better organization** - Group related configurations
✅ **No tab alignment issues** - YAML uses spaces and indentation
✅ **Comments support** - Document your configuration choices
✅ **Validation** - Catch syntax errors before deployment
✅ **Version control friendly** - Clean diffs and merges
✅ **Auto-generation** - Legacy format generated automatically

## Migration from Legacy Format

If you have an existing `linux.confmap`, you can migrate to YAML:

1. Create `dotfiles.yaml` based on the existing mappings
2. Organize entries into logical groups (development, shell, desktop, etc.)
3. Test with `./bin/config validate`
4. Generate the new confmap with `./bin/config generate`

## Go Dependency

The YAML system requires Go to be installed for the config manager. If Go is not available:
- The system falls back to using `linux.confmap` directly
- A warning is shown suggesting manual confmap management
- All dotfiles functionality remains available

## Backward Compatibility

The system maintains full backward compatibility:
- Existing `linux.confmap` files continue to work
- You can mix YAML and manual confmap editing
- Old scripts and workflows remain functional
