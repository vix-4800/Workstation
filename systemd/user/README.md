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

## Structure

```
systemd/user/
├── break-reminder.service
├── break-reminder.timer
└── ...
```

## Management

Use `workstation` script:

```bash
workstation service list        # list all
workstation timers              # show active timers
workstation timers setup        # enable health timers
```

## Adding service

1. Create directory: `systemd/user/my-service/`
2. Add `my-service.service` and optionally `my-service.timer`
3. Run: `workstation link`
4. Enable: `workstation service enable my-service.timer`

## Logs

```bash
journalctl --user -u my-service
```
