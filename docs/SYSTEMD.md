# Systemd Services

## Quick commands

```bash
# Enable service
workstation service enable arch-update.timer
workstation service enable gpu-fan-control.service

# Check status
workstation service status arch-update.timer

# List all services
workstation service list

# Show active timers
workstation timers

# Setup timers
workstation timers setup

# Enable all
systemctl --user enable --now <service>
```

## Add new service

1. Create `systemd/user/my-service.{service,timer}`
2. Apply: `workstation link`
3. Enable: `workstation service enable my-service.timer`

## Logs

```bash
journalctl --user -u arch-update.service
journalctl --user -u arch-update.service -f  # follow
```
