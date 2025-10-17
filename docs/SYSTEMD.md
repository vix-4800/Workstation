# Systemd Services

## Quick commands

```bash
# Enable service
bin/systemd-services enable arch-update.timer

# Check status
bin/systemd-services status arch-update.timer

# List all services
bin/systemd-services list

# Show active timers
bin/systemd-services timers

# Enable all
bin/systemd-services enable-all
```

## Add new service

1. Create `systemd/user/my-service.{service,timer}`
2. Apply: `bin/dotfiles link`
3. Enable: `bin/systemd-services enable my-service.timer`

## Logs

```bash
journalctl --user -u arch-update.service
journalctl --user -u arch-update.service -f  # follow
```
