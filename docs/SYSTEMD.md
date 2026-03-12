# Systemd Services

## Quick commands

```bash
# Enable all services/timers
workstation services enable-all

# Disable all services/timers
workstation services disable-all

# Check status of all services
workstation services status

# List all services
workstation services list

# Manual control (if needed)
systemctl --user enable --now <service>
systemctl --user disable --now <service>
systemctl --user status <service>
```

## Current timers

- `break-reminder.timer` - 85 minutes after boot, then every 85 minutes with up to 15 minutes randomized delay
- `water-reminder.timer` - 55 minutes after boot, then every 55 minutes with up to 10 minutes randomized delay
- `posture-check.timer` - 40 minutes after boot, then every 40 minutes with up to 10 minutes randomized delay
- `composer-update-check.timer` - weekly, 15 minutes after boot, with up to 1 hour randomized delay
- `dotfiles-update-check.timer` - 5 minutes after boot, then every hour

## Add new service

1. Create `systemd/user/my-service.{service,timer}`
2. Apply: `workstation dotfiles link`
3. Enable: `workstation services enable-all` or `systemctl --user enable --now my-service.timer`

## Logs

```bash
journalctl --user -u <service-name>.service
journalctl --user -u <service-name>.service -f  # follow
```
