#!/usr/bin/env bash
# Keep exactly ONE empty trailing workspace present at all times, so Noctalia's
# bar always shows "(highest used workspace) + 1" -- a mouse target for a fresh
# workspace -- without pinning all 9.
#
# Strategy: workspace 1 is persistent via Hyprland's own Lua config. This script
# watches the Hyprland event socket and moves a single "persistent" flag onto
# whatever workspace should be the trailing empty one, clearing the previous one.
#
# This config uses Hyprland's Lua config parser, so `hyprctl keyword workspace`
# is rejected ("non-legacy parser"). We use `hyprctl eval` + hl.workspace_rule()
# instead.
#
# Deps: hyprctl, jq, socat. Single-monitor assumption (uses activeworkspace).
set -euo pipefail

SIG="${HYPRLAND_INSTANCE_SIGNATURE:?not inside a Hyprland session}"
SOCK="${XDG_RUNTIME_DIR}/hypr/${SIG}/.socket2.sock"

MAX_WS=9      # never pin past this
MIN_TRAIL=2   # smallest workspace we'll ever pin (ws1 alone => bar also shows 2)

pinned=""     # workspace id we currently hold persistent (besides ws1)

set_rule() { # <id> <true|false>
    hyprctl eval \
        "hl.workspace_rule({ workspace = '$1', monitor = '$2', persistent = $3 })" \
        >/dev/null
}

recompute() {
    local hi cur target mon
    hi=$(hyprctl -j workspaces \
        | jq '[.[] | select(.id >= 1 and .windows > 0) | .id] | max // 0')
    cur=$(hyprctl -j activeworkspace | jq '.id')
    mon=$(hyprctl -j activeworkspace | jq -r '.monitor')
    (( cur < 1 )) && cur=0
    (( cur > hi )) && hi=$cur

    target=$(( hi + 1 ))
    (( target < MIN_TRAIL )) && target=$MIN_TRAIL
    (( target > MAX_WS ))    && target=$MAX_WS

    [[ "$target" == "$pinned" ]] && return

    if [[ -n "$pinned" && "$pinned" != "1" ]]; then
        set_rule "$pinned" "$mon" false
    fi
    set_rule "$target" "$mon" true
    pinned=$target
}

recompute
socat -U - "UNIX-CONNECT:$SOCK" | while read -r line; do
    case "${line%%>>*}" in
        workspacev2|createworkspacev2|destroyworkspacev2|focusedmonv2|\
        openwindow|closewindow|movewindowv2|moveworkspacev2)
            recompute
            ;;
    esac
done
