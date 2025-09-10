# Wlogout Configuration

Современное меню выхода для Sway в стиле вашего дизайна.

## Установка

```bash
# Arch Linux
sudo pacman -S wlogout

# Debian/Ubuntu
sudo apt install wlogout
```

## Настройка

1. Создайте симлинк на конфигурацию:
```bash
ln -sf ~/Code/Dotfiles/wlogout ~/.config/wlogout
```

2. Запуск через скрипт:
```bash
~/Code/Dotfiles/bin/wlogout-launch
```

3. Или через горячую клавишу: `$mod+x`

## Функции

- **Lock** (l) - Блокировка экрана с помощью swaylock
- **Logout** (e) - Выход из Sway сессии
- **Suspend** (u) - Режим сна
- **Hibernate** (h) - Режим гибернации
- **Reboot** (r) - Перезагрузка системы
- **Shutdown** (s) - Выключение системы

## Кастомизация

- `layout` - Определяет кнопки и их действия
- `style.css` - Стили в соответствии с вашей цветовой схемой
- `icons/` - SVG иконки в стиле One Dark

## Цветовая схема

Использует ту же палитру, что и остальные компоненты:
- Background: `#0f111a` с blur эффектом
- Primary: `#61afef` (синий)
- Lock: `#e5c07b` (желтый)
- Logout: `#c678dd` (пурпурный)
- Suspend: `#56b6c2` (циан)
- Hibernate: `#98c379` (зеленый)
- Reboot: `#ff7a86` (красный яркий)
- Shutdown: `#e06c75` (красный)
