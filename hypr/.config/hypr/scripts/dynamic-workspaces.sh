#!/usr/bin/env bash
# Trim the workspace bar to "1 .. (highest workspace with a window) + 1".
#
# Every workspace up to the highest one that currently holds a window stays
# pinned, so SUPER+wheel (workspace m+1 / m-1) still scrolls through them, plus
# ONE trailing empty workspace as a drop target for something new. Workspaces
# above that are un-pinned and fall off Noctalia's bar once they're empty.
#
# --- ROLLBACK -----------------------------------------------------------------
# The default, with this script NOT running, is all 9 workspaces persistent
# (set in config/workspaces.lua). To get back there:
#
#   ~/.config/hypr/scripts/dynamic-workspaces.sh off     # sticky, survives reboot
#   ~/.config/hypr/scripts/dynamic-workspaces.sh on      # re-enable
#   ~/.config/hypr/scripts/dynamic-workspaces.sh status
#
# `off` stops the running instance, re-pins all 9, and drops a flag file so the
# autostart entry is a no-op on the next login until you run `on`. Nothing in
# the tracked config changes either way.
# ----------------------------------------------------------------------------
#
# Deps: hyprctl, jq, socat. Single-monitor assumption.
set -uo pipefail

SIG="${HYPRLAND_INSTANCE_SIGNATURE:?not inside a Hyprland session}"
SOCK="${XDG_RUNTIME_DIR}/hypr/${SIG}/.socket2.sock"
RUNDIR="${XDG_RUNTIME_DIR}/hypr/${SIG}"
PIDFILE="$RUNDIR/dynamic-workspaces.pid"
FLAG="${XDG_STATE_HOME:-$HOME/.local/state}/hypr/dynamic-workspaces.off"

MIN_TRAIL=2
MAX_WS=9

MON=""
refresh_mon() {
    local m
    m=$(hyprctl -j activeworkspace 2>/dev/null | jq -r '.monitor // empty' 2>/dev/null) || m=""
    [[ -n "$m" ]] && MON="$m"
}

rule() { # <id> <true|false>
    if [[ -n "$MON" ]]; then
        hyprctl eval "hl.workspace_rule({ workspace = '$1', monitor = '$MON', persistent = $2 })" >/dev/null 2>&1 || true
    else
        hyprctl eval "hl.workspace_rule({ workspace = '$1', persistent = $2 })" >/dev/null 2>&1 || true
    fi
}

pin_all() { # restore the config default: 1..9 persistent
    refresh_mon
    local i
    for ((i = 1; i <= MAX_WS; i++)); do rule "$i" true; done
}

stop_running() {
    [[ -f "$PIDFILE" ]] || return 0
    local p
    p=$(<"$PIDFILE") || return 0
    [[ "$p" =~ ^[0-9]+$ && "$p" != "$$" ]] || return 0
    kill "$p" 2>/dev/null || true
    local n
    for ((n = 0; n < 40; n++)); do kill -0 "$p" 2>/dev/null || break; sleep 0.05; done
}

case "${1:-}" in
    off)
        mkdir -p "$(dirname "$FLAG")"; : > "$FLAG"
        stop_running
        pin_all
        echo "dynamic-workspaces: OFF  (all $MAX_WS workspaces persistent)"
        exit 0
        ;;
    on)
        rm -f "$FLAG"
        exec "$0"
        ;;
    status)
        if [[ -e "$FLAG" ]]; then
            echo "OFF (flag: $FLAG)"
        elif [[ -f "$PIDFILE" ]] && kill -0 "$(<"$PIDFILE")" 2>/dev/null; then
            echo "ON (pid $(<"$PIDFILE"))"
        else
            echo "enabled, not running"
        fi
        exit 0
        ;;
    "") : ;;
    *) echo "usage: ${0##*/} [on|off|status]" >&2; exit 2 ;;
esac

# ---- daemon ----------------------------------------------------------------
[[ -e "$FLAG" ]] && { echo "dynamic-workspaces: disabled via $FLAG -- run 'on' to enable"; exit 0; }

command -v socat >/dev/null || { echo "dynamic-workspaces: socat not found" >&2; exit 1; }

mkdir -p "$RUNDIR"
stop_running
echo $$ > "$PIDFILE"

FIFO="$RUNDIR/dynamic-workspaces.$$.fifo"
mkfifo "$FIFO"
socat -U - "UNIX-CONNECT:$SOCK" > "$FIFO" &
SOCAT_PID=$!
trap 'rm -f "$PIDFILE" "$FIFO"; kill "$SOCAT_PID" 2>/dev/null; pin_all' EXIT INT TERM

pinned_target=0
recompute() {
    local hi cur target i
    refresh_mon
    hi=$(hyprctl -j workspaces 2>/dev/null \
        | jq '[.[] | select(.id >= 1 and .windows > 0) | .id] | max // 0' 2>/dev/null) || return 0
    cur=$(hyprctl -j activeworkspace 2>/dev/null | jq '.id' 2>/dev/null) || return 0
    [[ "$hi"  =~ ^[0-9]+$ ]] || return 0
    [[ "$cur" =~ ^-?[0-9]+$ ]] || return 0

    (( cur > hi )) && hi=$cur
    (( hi < 1 ))   && hi=1

    target=$(( hi + 1 ))
    (( target < MIN_TRAIL )) && target=$MIN_TRAIL
    (( target > MAX_WS ))    && target=$MAX_WS

    (( target == pinned_target )) && return

    for ((i = 1;          i <= target; i++)); do rule "$i" true;  done
    for ((i = target + 1; i <= MAX_WS; i++)); do rule "$i" false; done
    pinned_target=$target
}

recompute
while read -r line; do
    case "${line%%>>*}" in
        workspacev2|createworkspacev2|destroyworkspacev2|focusedmonv2|\
        openwindow|closewindow|movewindowv2|moveworkspacev2)
            recompute
            ;;
    esac
done < "$FIFO"
