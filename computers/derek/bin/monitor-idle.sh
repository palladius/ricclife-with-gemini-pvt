#!/bin/bash
# Real-time idle monitor for debugging screen lock
# This will show you exactly when the system detects idle state

echo "🔍 Monitoring Idle Detection - Press Ctrl+C to stop"
echo "=================================================="
echo ""
echo "Current settings:"
echo "  Lock enabled: $(gsettings get org.gnome.desktop.screensaver lock-enabled)"
echo "  Idle delay: $(gsettings get org.gnome.desktop.session idle-delay) seconds"
echo "  Idle activation: $(gsettings get org.gnome.desktop.screensaver idle-activation-enabled)"
echo ""
echo "⏱️  Don't touch keyboard/mouse for 60 seconds..."
echo "   Watch for IdleHint to change from 'no' to 'yes'"
echo ""

# Get session ID
SESSION=$(loginctl | grep ricc | awk '{print $1}' | head -1)

if [ -z "$SESSION" ]; then
    echo "❌ Could not find session ID"
    exit 1
fi

echo "Session ID: $SESSION"
echo ""
echo "Time | IdleHint | IdleSince"
echo "-----+----------+----------"

while true; do
    TIMESTAMP=$(date +"%H:%M:%S")
    IDLE_HINT=$(loginctl show-session $SESSION | grep "^IdleHint=" | cut -d= -f2)
    IDLE_SINCE=$(loginctl show-session $SESSION | grep "^IdleSinceHint=" | cut -d= -f2)
    
    printf "%s | %-8s | %s\n" "$TIMESTAMP" "$IDLE_HINT" "$IDLE_SINCE"
    
    sleep 1
done
