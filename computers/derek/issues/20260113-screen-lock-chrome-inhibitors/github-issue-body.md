# Screen Lock Not Working on Derek (GNOME 48 + Debian)

## 🔴 Priority: HIGH - Security Issue

**Computer:** derek.zrh.corp.google.com (Google Zurich workstation)  
**Date Reported:** 2026-01-12  
**Date Investigated:** 2026-01-13  
**Status:** ✅ ROOT CAUSE IDENTIFIED

---

## 📋 Problem Statement

The screen lock/screensaver does NOT activate automatically after idle time, despite correct GNOME settings. This poses a **security risk** as the computer remains unlocked when the user is away from the desk.

**Expected Behavior:** Screen should lock after 60 seconds of inactivity  
**Actual Behavior:** Screen never locks automatically, even after 2+ minutes of inactivity

---

## 🔍 Investigation Summary

### Initial Hypothesis (INCORRECT)
- ❌ Settings misconfigured → **Settings were correct all along**
- ❌ GNOME Shell needs restart → **Not the issue**
- ❌ Session too old (4 weeks uptime) → **Not the root cause**

### System Configuration (ALL CORRECT ✅)

```bash
# GNOME Settings
org.gnome.desktop.screensaver.lock-enabled: true
org.gnome.desktop.screensaver.lock-delay: 0 seconds
org.gnome.desktop.screensaver.idle-activation-enabled: true
org.gnome.desktop.session.idle-delay: 60 seconds (1 minute)

# Google Corporate Policy (enforced via dconf)
- lock-enabled: LOCKED to true
- idle-activation-enabled: LOCKED to true
- lock-delay: LOCKED to 0
- idle-delay: 300s default (user overridden to 60s)
```

### 🎯 ROOT CAUSE IDENTIFIED

**Google Chrome is actively preventing idle detection via GNOME Session Manager inhibitors!**

```bash
$ gdbus call --session --dest org.gnome.SessionManager \
  --object-path /org/gnome/SessionManager \
  --method org.gnome.SessionManager.IsInhibited 4

(true,)  # ← IDLE is INHIBITED!
```

**Culprits Found:**
1. `google-chrome-stable` - "WebRTC has active PeerConnections" (flag 4)
2. `google-chrome` - "Capturing" (flag 12) - Multiple instances
3. `google-chrome-stable` - "Video Wake Lock" (flag 12)

**Inhibitor Flags:**
- Flag 4: IDLE (prevents screen lock)
- Flag 8: SUSPEND
- Flag 12: IDLE + SUSPEND (4 + 8)

---

## ✅ Solutions

### Solution 1: Close Offending Chrome Tabs (Recommended)

1. **Open Google Chrome**
2. **Look for tabs with these indicators:**
   - 🎥 Camera icon in tab
   - 🎤 Microphone icon in tab
   - 📹 Recording indicator
3. **Common culprits:**
   - Google Meet tabs (even after call ends!)
   - Zoom web client
   - Any tab using camera/microphone
   - Video players with wake lock enabled
4. **Close those tabs**
5. **Verify:** Run the blocker detector script
6. **Test:** Don't touch keyboard/mouse for 60 seconds

### Solution 2: Use Chrome Media Internals

1. Open `chrome://media-internals` in Chrome
2. Look for active audio/video sessions
3. Identify and close tabs with active media sessions

### Solution 3: Close Chrome Completely (Nuclear Option)

```bash
killall chrome
# Then test screen lock
```

### Solution 4: Use the Diagnostic Script

```bash
cd ~/git/ricclife-with-gemini-pvt/computers/derek
./bin/find-lock-blockers.sh
```

This script will identify which applications are blocking idle detection.

---

## 🧪 Verification

### Before Fix
```bash
./bin/find-lock-blockers.sh
# Should show: ❌ IDLE IS BEING INHIBITED
```

### After Fix
```bash
./bin/find-lock-blockers.sh
# Should show: ✅ IDLE is NOT inhibited

# Then test with idle monitor:
./bin/monitor-idle.sh
# Don't touch anything for 60 seconds
# IdleHint should change from 'no' to 'yes'
# Screen should lock immediately
```

---

## 📁 Investigation Files

All investigation materials are in `computers/derek/`:

- **`20260113-screensaver-lock-not-working.md`** - Full investigation log
- **`ROOT-CAUSE-CHROME-INHIBITORS.md`** - Detailed root cause analysis
- **`bin/find-lock-blockers.sh`** - Diagnostic script to find inhibitors
- **`bin/monitor-idle.sh`** - Real-time idle detection monitor
- **`bin/get-status.sh`** - Quick settings status checker
- **`bin/THE-FIX.sh`** - Original fix instructions (outdated)

---

## 🎓 Lessons Learned

1. ✅ **Settings were always correct** - Google corporate policy + user override
2. ❌ **Applications can override system idle detection** via Session Manager inhibitors
3. 🎯 **Chrome's WebRTC/media features prevent screen lock by design** - This is a feature, not a bug
4. 🔧 **Diagnostic tools are essential** - `gdbus` + Session Manager introspection revealed the truth

### Why This Happens

Chrome **intentionally** prevents screen lock during:
- Video calls (so screen doesn't lock mid-meeting)
- Screen sharing sessions
- Active camera/microphone usage
- Video playback with wake lock

This is **correct behavior** for these use cases, but if you forget to close these tabs, your screen will **never lock automatically**.

---

## 🛠️ Prevention Tips

To avoid this issue in the future:

1. **Always close Google Meet tabs** after video calls end
2. **Check for camera/mic icons** in Chrome tabs before leaving desk
3. **Run the blocker detector periodically:**
   ```bash
   ~/git/ricclife-with-gemini-pvt/computers/derek/bin/find-lock-blockers.sh
   ```
4. **Consider creating a keyboard shortcut** to run the detector
5. **Manually lock screen** when leaving: `Super + L` or `loginctl lock-session`

---

## 🔧 System Information

- **Hostname:** derek.zrh.corp.google.com
- **OS:** Debian GNU/Linux rodete
- **Kernel:** 6.16.12-1rodete2-amd64
- **Desktop:** GNOME 48.4 (Wayland)
- **User:** ricc (UID: 164825)
- **Session Uptime:** 4 weeks (since 2025-12-15)

---

## 📊 Technical Details

### GNOME Session Manager Inhibitor API

```bash
# Check if IDLE is inhibited (flag 4)
gdbus call --session --dest org.gnome.SessionManager \
  --object-path /org/gnome/SessionManager \
  --method org.gnome.SessionManager.IsInhibited 4

# Get all inhibitors
gdbus call --session --dest org.gnome.SessionManager \
  --object-path /org/gnome/SessionManager \
  --method org.gnome.SessionManager.GetInhibitors

# Query specific inhibitor
gdbus call --session --dest org.gnome.SessionManager \
  --object-path /org/gnome/SessionManager/Inhibitor<ID> \
  --method org.gnome.SessionManager.Inhibitor.GetAppId
```

### Inhibitor Flags Reference

- `1` - LOGOUT
- `2` - SWITCH_USER
- `4` - IDLE (prevents screen lock/screensaver)
- `8` - SUSPEND (prevents system suspend)
- `12` - IDLE + SUSPEND (4 + 8)

---

## ✅ Resolution

**Status:** RESOLVED - Root cause identified  
**Action Required:** User must close Chrome tabs with active WebRTC/media  
**Verification:** Use `find-lock-blockers.sh` to confirm fix  

---

**Labels:** `security`, `gnome`, `screen-lock`, `chrome`, `derek`, `investigation`  
**Assignee:** @palladius  
**Investigated by:** Antigravity AI Agent  
**Time to Root Cause:** ~30 minutes
