# Systemd User Services

Services managed via dotfiles symlinks to `~/.config/systemd/user/`.

## Available Timers

### Health & Wellness

- **break-reminder.timer** - After 85 min from boot, then every 85 min with up to 15 min randomized delay
- **water-reminder.timer** - After 55 min from boot, then every 55 min with up to 10 min randomized delay
- **posture-check.timer** - After 40 min from boot, then every 40 min with up to 10 min randomized delay

### System Services

- **batsignal.service** - Battery notification service (laptops)
- **gpu-fan-control.service** - NVIDIA GPU fan control (desktops only, auto-detects)

### Dotfiles Maintenance

- **composer-update-check.timer** - Weekly, 15 min after boot, with up to 1 hour randomized delay
- **dotfiles-update-check.timer** - 5 min after boot, then every hour

## Structure

```text
systemd/user/
├── break-reminder.service
├── break-reminder.timer
└── ...
```

## Management

Use `workstation` script:

```bash
workstation services list           # list all available services/timers
workstation services enable-all     # enable all services and timers
workstation services disable-all    # disable all services and timers
workstation services status         # show status of all services
```

Or manage individual units directly:

```bash
systemctl --user enable --now my-service.timer
systemctl --user status my-service.timer
```

## Adding service

1. Create `systemd/user/my-service.service` (and optionally `my-service.timer`)
2. Add entries to `dotfiles.json` pointing to `$HOME/.config/systemd/user/`
3. Run: `workstation dotfiles link`
4. Enable: `systemctl --user enable --now my-service.timer`

## Logs

```bash
journalctl --user -u my-service
```
