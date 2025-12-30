# Secure Boot Configuration Guide

This system uses `sbctl` to manage Secure Boot with custom keys.

## What is Secure Boot?

Secure Boot is a UEFI feature that ensures only signed bootloaders and kernels can run,
preventing unauthorized code execution during the boot process.

## Prerequisites

- UEFI firmware (not legacy BIOS)
- Root/sudo access
- GRUB bootloader

## Automated Setup (Ansible)

The Ansible playbook handles most of the setup automatically:

```bash
ansible-playbook ansible/secure-boot.yml
```

This will:

- Install `sbctl`
- Create custom Secure Boot keys
- Sign bootloader, GRUB, and Linux kernel
- Configure automatic signing of future kernel updates

## Manual Steps Required

After running the Ansible playbook, you must complete these steps manually:

### 1. Enter Setup Mode

1. Reboot your system
2. Enter BIOS/UEFI (usually `Del`, `F2`, or `F12` during boot)
3. Navigate to Secure Boot settings
4. Clear/Delete existing Secure Boot keys (this enters "Setup Mode")
5. Save and reboot

### 2. Enroll Custom Keys

After booting back to Linux:

```bash
sudo sbctl enroll-keys --microsoft
```

The `--microsoft` flag includes Microsoft's keys for Windows compatibility (if dual-booting).

### 3. Enable Secure Boot

1. Reboot into BIOS again
2. Enable Secure Boot
3. Save and boot normally

### 4. Verify

Check that Secure Boot is active:

```bash
sbctl status
```

Expected output:

```text
Installed:      ✓ sbctl is installed
Setup Mode:     ✓ Disabled
Secure Boot:    ✓ Enabled
```

## Maintenance

### Signing New Kernels

The `sbctl` pacman hook automatically signs new kernels during updates. No manual action needed.

### Verify Signed Files

Check which files are signed:

```bash
sudo sbctl verify
```

### Manually Sign a File

If needed:

```bash
sudo sbctl sign -s /path/to/file.efi
```

### List Enrolled Keys

```bash
sudo sbctl list-keys
```

## Troubleshooting

### System Won't Boot After Enabling Secure Boot

1. Boot into BIOS
2. Temporarily disable Secure Boot
3. Boot to Linux
4. Run `sudo sbctl verify` to check signatures
5. Re-sign any unsigned files:

   ```bash
   sudo sbctl sign -s /efi/EFI/GRUB/grubx64.efi
   sudo sbctl sign -s /boot/vmlinuz-linux
   ```

6. Enable Secure Boot again

### Cannot Enter Setup Mode

Some firmwares require:

- Disabling Secure Boot first
- Using "Custom" or "Expert" mode
- Physical presence confirmation (pressing a key sequence)

### Dual Boot with Windows

The `--microsoft` flag during `sbctl enroll-keys` ensures Windows bootloader remains trusted.
Windows should continue to work normally.

## Files Signed

The following files are automatically signed:

- `/efi/EFI/Boot/bootx64.efi` - UEFI fallback bootloader
- `/efi/EFI/GRUB/grubx64.efi` - GRUB bootloader
- `/boot/vmlinuz-linux` - Linux kernel

## Key Storage

Custom Secure Boot keys are stored in:

- `/usr/share/secureboot/keys/`

**IMPORTANT**: Back up these keys! If you lose them and need to reinstall,
you'll have to clear Secure Boot keys in BIOS again.

## Security Considerations

- Custom keys protect against rootkits and bootkits
- Only signed code can execute during boot
- Updates to bootloader/kernel are automatically signed
- Keys are unique to your system
- Including Microsoft keys allows Windows dual-boot

## References

- [sbctl GitHub](https://github.com/Foxboron/sbctl)
- [Arch Wiki: Secure Boot](https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot)
