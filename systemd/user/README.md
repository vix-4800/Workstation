# Systemd User Services

Services managed via dotfiles symlinks to `~/.config/systemd/user/`.

## Structure

```
systemd/user/
├── arch-update/
│   ├── arch-update.service
│   └── arch-update.timer
└── my-service/
    ├── my-service.service
    └── my-service.timer
```

## Management

Use `bin/systemd-services` script:

```bash
bin/systemd-services list        # list all
bin/systemd-services enable-all  # enable all
bin/systemd-services timers      # show active timers
```

## Adding service

1. Create directory: `systemd/user/my-service/`
2. Add `my-service.service` and optionally `my-service.timer`
3. Run: `bin/dotfiles link`
4. Enable: `bin/systemd-services enable my-service.timer`

## Logs

```bash
journalctl --user -u my-service
```
