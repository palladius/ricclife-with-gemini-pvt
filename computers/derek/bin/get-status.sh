# 1. Check if the idle timer is successfully set to 60s
gsettings get org.gnome.desktop.session idle-delay
# Expected output: uint32 60

# 2. Check if the lock is actually enabled
gsettings get org.gnome.desktop.screensaver lock-enabled
# Expected output: true

# 3. Check if the key is actually locked by an Admin (if this returns false, you have a bigger permissions issue)
gsettings writable org.gnome.desktop.screensaver lock-enabled


# ls -l ~/.config/dconf/user
# sudo chown ricc:ricc ~/.config/dconf/user
gsettings get org.gnome.desktop.lockdown disable-lock-screen