# Systemd User Services

Services managed via dotfiles symlinks to `~/.config/systemd/user/`.

## Available Timers

### Health & Wellness

- **break-reminder.timer** - Every 90 min: reminder to take a break
- **water-reminder.timer** - Every 60 min: stay hydrated
- **posture-check.timer** - Every 45 min: check your posture

### System Services

- **batsignal.service** - Battery notification service (laptops)
- **gpu-fan-control.service** - NVIDIA GPU fan control (desktops only, auto-detects)

### Dotfiles Maintenance

- **dotfiles-update-check.timer** - Every 60 min: check for dotfiles repository updates on GitHub

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
