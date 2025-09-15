# Arch Linux Setup Script

Автоматический скрипт для установки и настройки системы Arch Linux с окружением Sway (Wayland).

## Что устанавливается

### Основные компоненты системы:

- **Desktop Environment**: Sway (Wayland compositor)
- **Status Bar**: Waybar
- **Application Launcher**: Wofi
- **Notifications**: SwaNC
- **Lock Screen**: Swaylock
- **Terminal**: Alacritty
- **Shell**: Fish (с возможностью использования Zsh)
- **Editor**: Neovim
- **Display Manager**: SDDM / greetd с ReGreet / KDE Plasma

### Системные пакеты:

- **Базовые**: base-devel, git, curl, openssh, udiskie, ffmpeg, reflector
- **Аудиосистема**: PipeWire с полным стеком
- **Шрифты**: JetBrains Mono Nerd Font, Font Awesome
- **Инструменты**: grim/slurp (скриншоты), brightnessctl (яркость)
- **Безопасность**: ufw (firewall), bluez (bluetooth)
- **VPN**: WireGuard + NetworkManager integration
- **Микрокод**: AMD-ucode или Intel-ucode (по выбору)

### Инструменты разработки:

- **PHP**: php, php-gd, php-intl, composer + глобальные пакеты (PHPStan, PHP-CS-Fixer, PHPCS, Rector)
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

1. **Интерактивный выбор компонентов**:
   - CPU микрокод (AMD/Intel/Skip)
   - Display manager (SDDM/greetd с ReGreet/KDE Plasma/None)
   - GPU драйверы (NVIDIA/AMD-Intel/Skip)
   - Мультимедийные кодеки и дополнительные приложения
   - Настройка таймзоны, локали и hostname
   - Дополнительные dev-инструменты (Python/PHP пакеты)
   - Кастомная тема GRUB (Xenlism theme + grub-customizer)
   - Автоматическая настройка firewall (ufw)

2. **Обновление системы** - `pacman -Syu` + reflector для зеркал
3. **Установка пакетов** - все необходимые пакеты из pacman
4. **Установка GPU драйверов** - NVIDIA или AMD/Intel драйверы
5. **Установка AUR helper** - yay для доступа к AUR
6. **Установка AUR пакетов** - grub-customizer и опционально SwayFX
7. **Системные сервисы** - NetworkManager, Docker, Bluetooth, Firewall
8. **Базовые настройки системы** - таймзона, локаль, hostname, sudo права
9. **Мультимедийные кодеки** - поддержка всех популярных форматов
10. **Shell настройка** - установка Fish как основной оболочки
11. **Инструменты разработки** - установка через pipx, composer
12. **Настройка окружения** - адаптивные переменные среды под выбранный DM

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

# Для AMD/Intel (установятся автоматически если выбрано в скрипте):
sudo pacman -S mesa xf86-video-amdgpu xf86-video-intel vulkan-radeon vulkan-intel

# Для NVIDIA (установятся автоматически если выбрано в скрипте):
sudo pacman -S nvidia nvidia-utils
# После установки NVIDIA перезагрузите систему
```

### Управление NetworkManager:

```bash
# Статус сети
nmcli general status

# Подключение к Wi-Fi
nmcli device wifi list
nmcli device wifi connect "SSID" password "password"

# Управление через GUI
nm-connection-editor
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

### Проблемы с запуском Sway:

```bash
# Если Sway не запускается после логина
# 1. Проверьте переменные окружения
echo $XDG_SESSION_TYPE
echo $XDG_CURRENT_DESKTOP

# 2. Переменные окружения настраиваются автоматически в /etc/environment

# 3. Для ручного запуска (если выбран display manager "None")
if [[ -z $DISPLAY && $(tty) == /dev/tty1 ]]; then
  exec sway
fi

# 4. Проверьте конфигурацию Sway
sway --validate

# 5. Проверьте логи
journalctl --user -u sway
```

### Настройка ReGreet (greetd):

```bash
# ReGreet конфигурируется автоматически в /etc/greetd/regreet.toml
# Для кастомизации отредактируйте:
sudo nano /etc/greetd/regreet.toml

# Изменение фона:
[background]
path = "/путь/к/изображению.jpg"
fit = "Cover"

# Проверка статуса greetd:
sudo systemctl status greetd

# Логи ReGreet:
sudo journalctl -u greetd

# Перезапуск после изменений:
sudo systemctl restart greetd
```

### Настройка GRUB темы:

```bash
# Если установлена кастомная тема GRUB (Xenlism):
# Скрипт автоматически использует локальную тему из ~/Code/Dotfiles/grub/themes/Xenlism Arch/
# или скачивает её из репозитория GitHub

# Тема устанавливается в стандартное системное расположение:
# /usr/share/grub/themes/Xenlism-Arch/

# Установка использует оригинальный installer.sh из темы для максимальной совместимости

# Для дальнейшей кастомизации используйте grub-customizer:
sudo grub-customizer

# Ручная настройка GRUB (если нужно):
sudo nano /etc/default/grub

# После изменений обновите конфигурацию:
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Проверка установленной темы:
grep GRUB_THEME /etc/default/grub
# Должно показать: GRUB_THEME="/usr/share/grub/themes/Xenlism-Arch/theme.txt"

# Если тема не отображается, проверьте файлы темы:
ls -la /usr/share/grub/themes/Xenlism-Arch/
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
