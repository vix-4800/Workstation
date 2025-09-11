# Arch Linux Setup Script

Автоматический скрипт для установки и настройки системы Arch Linux с окружением Sway (Wayland).

## Что устанавливается

### Основные компоненты системы:

- **Desktop Environment**: Sway (Wayland compositor)
- **Status Bar**: Waybar
- **Application Launcher**: Wofi
- **Notifications**: Mako
- **Lock Screen**: Swaylock
- **Terminal**: Alacritty
- **Shell**: Fish (с возможностью использования Zsh)
- **Editor**: Neovim
- **Display Manager**: SDDM

### Системные пакеты:

- Базовые инструменты разработки (base-devel, git, curl, etc.)
- Аудиосистема PipeWire с полным стеком
- Шрифты (JetBrains Mono Nerd Font, Font Awesome)
- Инструменты для скриншотов (grim, slurp)
- Управление яркостью (brightnessctl)
- VPN (WireGuard)

### Инструменты разработки:

- **PHP**: php, composer + глобальные пакеты (PHPStan, PHP-CS-Fixer, PHPCS, Rector)
- **Python**: python-pip, pipx + инструменты (black, flake8, mypy, pre-commit)
- **JavaScript**: Node.js через NVM (устанавливается отдельно)
- **Docker**: docker, docker-compose
- **Git**: github-cli для работы с GitHub

## Использование

### Автоматическая установка:

```bash
# Скачать и запустить
curl -fsSL https://raw.githubusercontent.com/vix-4800/dotfiles/main/bin/arch-setup | bash

# Или клонировать репозиторий и запустить локально
git clone https://github.com/vix-4800/dotfiles.git ~/Code/Dotfiles
cd ~/Code/Dotfiles
./bin/arch-setup
```

### Что делает скрипт:

1. **Обновление системы** - `pacman -Syu`
2. **Установка пакетов** - все необходимые пакеты из pacman
3. **Установка AUR helper** - yay для доступа к AUR
4. **Установка AUR пакетов** - VS Code и другие
5. **Системные сервисы** - настройка и включение служб
6. **Dotfiles** - клонирование и связывание конфигураций
7. **Shell настройка** - установка Fish как основной оболочки
8. **Инструменты разработки** - установка через pipx, composer

## После установки

### Обязательные действия:

```bash
# 1. Перезагрузка системы
sudo reboot

# 2. Аутентификация в GitHub (опционально)
gh auth login

# 3. Настройка Git (если нужно)
git config --global user.name "Ваше Имя"
git config --global user.email "email@example.com"
```

### Дополнительные настройки:

#### Опциональные пакеты:

```bash
# SwayFX - улучшенная версия Sway с эффектами
yay -S swayfx

# Дополнительные темы для SDDM
yay -S sddm-theme-corners-git

# Дополнительные шрифты
yay -S ttf-cascadia-code
```

#### WireGuard VPN:

```bash
# Поместите конфигурацию в ~/.config/wireguard/
mkdir -p ~/.config/wireguard
# Скопируйте файл .conf и настройте права
chmod 600 ~/.config/wireguard/wg0.conf

# Подключение через NetworkManager
nmcli connection import type wireguard file ~/.config/wireguard/wg0.conf
```

#### Node.js (через NVM):

```bash
# Установка NVM (если не установлен через Fisher)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Установка последней версии Node.js
nvm install node
nvm use node
```

## Структура dotfiles

После установки в `~/Code/Dotfiles` будут доступны конфигурации для:

- **Sway**: `sway/config` и `sway/config.d/`
- **Waybar**: `waybar/config.jsonc` и `waybar/style.css`
- **Alacritty**: `alacritty/alacritty.toml`
- **Neovim**: `nvim/` (полная конфигурация)
- **Fish**: `fish/config.fish` и дополнительные функции
- **Git**: `git/gitconfig`
- **Mako**: `mako/config`
- **Wofi**: `wofi/config` и `wofi/style.css`

## Решение проблем

### Если Sway не запускается:

```bash
# Проверьте драйверы GPU
lspci | grep VGA
sudo pacman -S mesa  # Для AMD/Intel
# Для NVIDIA может потребоваться nvidia-utils
```

### Если нет звука:

```bash
# Проверка статуса аудиосервисов
systemctl --user status pipewire pipewire-pulse wireplumber

# Перезапуск PipeWire
systemctl --user restart pipewire pipewire-pulse wireplumber

# Проверка подключения к PipeWire
pactl info

# Проверка аудиоустройств
pactl list sinks short

# Если используется jack2 вместо pipewire-jack
pw-jack pactl info
```

### Конфликт pipewire-jack и jack2:

```bash
# Если возникает ошибка "pipewire-jack and jack2 are in conflict"
# Проверьте, требует ли waybar jack2
pacman -Qi waybar | grep jack2

# Если waybar зависит от jack2, используйте jack2 вместо pipewire-jack
# Если нет, замените jack2 на pipewire-jack:
sudo pacman -R jack2
sudo pacman -S pipewire-jack

# Альтернативно, можно использовать jack2 с pipewire через pw-jack:
# sudo pacman -S jack2
# export JACK_SERVER="/usr/bin/pw-jack"
```

### Для обновления dotfiles:

```bash
cd ~/Code/Dotfiles
git pull
./bin/dotfiles link
```

## Кастомизация

Все конфигурации можно редактировать в `~/Code/Dotfiles/`. После изменений запустите:

```bash
./bin/dotfiles link
```

Или для отдельных компонентов:

```bash
# Только для Sway
ln -sf ~/Code/Dotfiles/sway/config ~/.config/sway/config
```
