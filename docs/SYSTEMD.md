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

## Add new service

1. Create `systemd/user/my-service.{service,timer}`
2. Apply: `workstation dotfiles link`
3. Enable: `workstation services enable-all` or `systemctl --user enable --now my-service.timer`

## Logs

```bash
journalctl --user -u <service-name>.service
journalctl --user -u <service-name>.service -f  # follow
```
