#!/bin/bash
STATUS=$(noctalia msg notification-dnd-status 2>/dev/null)

if [ "$STATUS" = "on" ]; then
    noctalia msg notification-dnd-set false
    noctalia msg notification-show "Stream Mode" "DISABLED • Notifications unmuted"
else
    noctalia msg notification-dnd-set true
    noctalia msg notification-show "Stream Mode" "ENABLED • Notifications muted (DND)"
fi
