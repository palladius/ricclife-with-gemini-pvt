#!/bin/bash
# Find which applications are preventing screen lock

echo "🔍 Screen Lock Inhibitor Detective"
echo "===================================="
echo ""

echo "Checking GNOME Session Manager for IDLE inhibitors (flag 4)..."
echo ""

# Check if idle is inhibited
INHIBITED=$(gdbus call --session --dest org.gnome.SessionManager --object-path /org/gnome/SessionManager --method org.gnome.SessionManager.IsInhibited 4 2>&1 | grep -o "true\|false")

if [ "$INHIBITED" = "true" ]; then
    echo "❌ IDLE IS BEING INHIBITED - Screen lock will NOT work!"
    echo ""
else
    echo "✅ IDLE is NOT inhibited - Screen lock should work"
    echo ""
    exit 0
fi

# Get all inhibitors
INHIBITORS=$(gdbus call --session --dest org.gnome.SessionManager --object-path /org/gnome/SessionManager --method org.gnome.SessionManager.GetInhibitors 2>&1 | grep -oP "'/org/gnome/SessionManager/Inhibitor\d+'" | tr -d "'")

echo "🔎 Found $(echo "$INHIBITORS" | wc -l) inhibitors. Checking which ones block IDLE..."
echo ""

for inhibitor in $INHIBITORS; do
    # Get flags - extract the number after "uint32 " from "(uint32 X,)" format
    FLAGS_RAW=$(gdbus call --session --dest org.gnome.SessionManager --object-path $inhibitor --method org.gnome.SessionManager.Inhibitor.GetFlags 2>&1)
    FLAGS=$(echo "$FLAGS_RAW" | grep -oP 'uint32 \K\d+')
    
    # Skip if we couldn't get flags
    if [ -z "$FLAGS" ]; then
        continue
    fi
    
    # Flag 4 = IDLE inhibit, Flag 8 = SUSPEND inhibit, Flag 12 = IDLE+SUSPEND
    # Check if flag includes IDLE (bit 2 set: 4, 5, 6, 7, 12, 13, 14, 15...)
    if [ $((FLAGS & 4)) -ne 0 ]; then
        APP=$(gdbus call --session --dest org.gnome.SessionManager --object-path $inhibitor --method org.gnome.SessionManager.Inhibitor.GetAppId 2>&1 | grep -oP "(?<=\(').*(?=',\))")
        REASON=$(gdbus call --session --dest org.gnome.SessionManager --object-path $inhibitor --method org.gnome.SessionManager.Inhibitor.GetReason 2>&1 | grep -oP "(?<=\(').*(?=',\))")
        
        echo "🚫 BLOCKING: $APP"
        echo "   Reason: $REASON"
        echo "   Flags: $FLAGS"
        echo ""
    fi
done

echo ""
echo "💡 SOLUTION:"
echo "============"
echo ""
echo "To fix screen lock, you need to:"
echo ""
echo "1. Close Chrome tabs with active WebRTC/video/camera:"
echo "   - Google Meet calls"
echo "   - Tabs using camera/microphone"
echo "   - Tabs playing video with wake lock"
echo "   - WebRTC connections"
echo ""
echo "2. Or close Chrome completely"
echo ""
echo "3. Then test: Don't touch keyboard/mouse for 60 seconds"
echo ""
echo "🔍 To find the specific Chrome tabs:"
echo "   - Open Chrome"
echo "   - Look for tabs with camera/mic icons"
echo "   - Check chrome://media-internals for active sessions"
echo ""
