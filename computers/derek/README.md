# Derek - Linux Workstation

**Location:** Google Zurich Office  
**Owner:** Riccardo (ricc)  
**Type:** Work Laptop/Workstation

## System Information

### Hardware & OS
```bash
Hostname: derek.zrh.corp.google.com
Kernel:   Linux 6.16.12-1rodete2-amd64
OS:       Debian GNU/Linux rodete
Arch:     x86_64
```

### Software Environment
- **Desktop Environment:** GNOME
- **GNOME Shell Version:** 48.4
- **Display Server:** Wayland (default on GNOME 48)
- **User:** ricc (UID: 164825)

### Full uname Output
```
Linux derek.zrh.corp.google.com 6.16.12-1rodete2-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.16.12-1rodete2 (2025-11-10) x86_64 GNU/Linux
```

## Purpose

This is my primary Linux workstation at Google Zurich, used for:
- Development work
- Google Cloud Developer Advocacy
- Gemini API research and testing
- Open source contributions

## Configuration Notes

- Uses `rbenv` for Ruby version management
- Uses `chezmoi` for dotfiles management
- Uses `uv` for Python virtual environments
- Uses `justfile` for project-specific tasks
- Work environment (no root access)

## Known Issues & Investigations

See `issues/` directory for detailed investigations:

- **[20260113-screen-lock-chrome-inhibitors](./issues/20260113-screen-lock-chrome-inhibitors/)** - Screen lock not working due to Chrome WebRTC/media inhibitors (RESOLVED)

## Quick Commands

```bash
# System info
uname -a
lsb_release -a
gnome-shell --version

# Lock screen manually
loginctl lock-session
# or: Super+L

# Check screen lock settings (using local script)
./bin/get-status.sh

# Monitor idle detection in real-time
./bin/monitor-idle.sh

# Manual gsettings checks
gsettings get org.gnome.desktop.screensaver lock-enabled
gsettings get org.gnome.desktop.session idle-delay
gsettings get org.gnome.desktop.lockdown disable-lock-screen
```

## Diagnostic Scripts

Located in `bin/`:
- **`get-status.sh`**: Quick status check for screen lock settings
- **`monitor-idle.sh`**: Real-time idle detection monitor (useful for debugging)


---
**Last Updated:** 2026-01-13  
**Maintained by:** Riccardo (palladius/ricc)
