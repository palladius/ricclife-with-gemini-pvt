# Changelog - Derek Computer Configuration

All notable changes to this computer configuration will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-13

### 🎉 Initial Release

First structured documentation and tooling for derek workstation.

### ✨ Added
- 📁 **Modular issue tracking structure** - `issues/` directory for investigations
- 🔍 **Screen lock investigation** - Complete root cause analysis of Chrome inhibitors blocking screen lock
- 🛠️ **Diagnostic tools** in `bin/`:
  - `find-lock-blockers.sh` - Detect applications blocking screen lock via GNOME Session Manager
  - `monitor-idle.sh` - Real-time idle detection monitor
  - `get-status.sh` - Quick screen lock settings checker
- 📝 **System documentation** - Complete README with uname, OS info, GNOME version
- 🐛 **GitHub Issue #1** - Screen lock not working due to Chrome WebRTC inhibitors

### 🔧 Fixed
- 🐛 **Bug in find-lock-blockers.sh** - Fixed FLAGS parsing to correctly extract values from `uint32` format
- 🔒 **Screen lock issue** - Identified Chrome WebRTC/media tabs as root cause

### 📚 Documented
- **System Information**:
  - Hostname: derek.zrh.corp.google.com
  - OS: Debian GNU/Linux rodete
  - Kernel: 6.16.12-1rodete2-amd64
  - Desktop: GNOME 48.4 (Wayland)
- **Google Corporate Policy** - dconf settings enforcement
- **GNOME Session Manager Inhibitor API** - How to detect and debug idle inhibitors

### 🎓 Lessons Learned
- Settings were always correct - application-level inhibitors were the issue
- Chrome intentionally prevents screen lock during video calls (by design)
- `gdbus` + GNOME Session Manager introspection is essential for debugging

---

**Investigated by:** Antigravity AI Agent  
**Date:** 2026-01-13  
**Time to Resolution:** ~30 minutes
