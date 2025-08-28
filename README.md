# Dotfiles

Система управления конфигурационными файлами через символические ссылки.

## Установка

```bash
git clone https://github.com/vix-4800/dotfiles.git ~/Code/Dotfiles
cd ~/Code/Dotfiles
./install.sh
```

После установки команда `dotfiles` будет доступна из любой директории.

## Использование

### Основные команды

```bash
# Показать статус всех ссылок
dotfiles status

# Создать символические ссылки (dry-run)
dotfiles link -n

# Создать символические ссылки
dotfiles link

# Удалить символические ссылки (dry-run)
dotfiles unlink -n

# Удалить символические ссылки
dotfiles unlink

# Обновить репозиторий и пересоздать ссылки
dotfiles update

# Проверить окружение
dotfiles doctor

# Показать пути к репозиторию и карте
dotfiles which

# Редактировать карту конфигурации
dotfiles edit
```

### Дополнительные параметры

```bash
# Использовать альтернативную карту конфигурации
dotfiles status --map /path/to/custom.confmap
dotfiles link --map /path/to/custom.confmap
```

## Конфигурация

Файл `linux.confmap` содержит соответствия между файлами в репозитории и их местоположением в системе:

```
php/php-cs-fixer.php	$HOME/.config/php-cs-fixer/php-cs-fixer.php
php/phpstan.neon	$HOME/.config/phpstan/phpstan.neon
php/rector.php	$HOME/.config/rector/rector.php
python/.flake8	$HOME/.config/flake8/flake8
python/mypy.ini	$HOME/.config/mypy/mypy
shell/.zshrc	$HOME/.zshrc
```

### Формат карты

-   Источник и цель разделяются табуляцией
-   Пустые строки и строки, начинающиеся с `#`, игнорируются
-   Поддерживаются переменные `$HOME` и `~`
-   Относительные пути источников считаются относительно корня репозитория

## Особенности

-   **Безопасность**: Существующие файлы автоматически сохраняются в `~/.local/share/dotfiles/backups/`
-   **Dry-run режим**: Флаг `-n` позволяет посмотреть, что будет сделано, без реальных изменений
-   **Автосоздание директорий**: Родительские директории создаются автоматически
-   **Проверка целостности**: Команда `status` показывает актуальное состояние всех ссылок

## Структура проекта

```
.
├── bin/dotfiles          # Основной скрипт
├── linux.confmap         # Карта соответствий для Linux
├── install.sh            # Скрипт установки
├── php/                  # PHP конфигурации
├── python/               # Python конфигурации
└── shell/                # Shell конфигурации
```

## Примеры

```bash
# Посмотреть, что будет создано
dotfiles link -n

# Создать все ссылки
dotfiles link

# Проверить статус
dotfiles status

# Обновить конфигурации из git
dotfiles update
```
