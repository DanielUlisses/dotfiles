#!/bin/bash
set -euo pipefail

umask 022
PATH=/usr/local/bin:/usr/bin:/bin

log() {
  logger -t lid-events "[$0] $*"
}

# ========== CONFIGURATION SECTION ==========
# Customize these values based on your hardware
LAPTOP_MONITOR="eDP-1"                    # Your laptop display name
EXTERNAL_MONITOR="DP-5"                   # Your external display name
EXTERNAL_MONITOR2="DP-6"                   # Your external display name
EXTERNAL_RESOLUTION="1920x1080@75"        # External monitor resolution@refresh
LAPTOP_RESOLUTION="1920x1080@60"          # Laptop monitor resolution@refresh
EXTERNAL_SCALE="1"                     # External monitor scaling factor
LAPTOP_SCALE="1"                           # Laptop monitor scaling factor
EXTERNAL_POSITION="0x0"                   # External monitor position
EXTERNAL_POSITION2="1920x0"                   # External monitor position
LAPTOP_POSITION_DUAL="3840x0"            # Laptop position in dual mode
LAPTOP_POSITION_SOLO="0x0"               # Laptop position when alone
# Workspace distribution
EXTERNAL_WS="${EXTERNAL_WS:-1 2 3 4 5}"  # Workspaces for external monitor
EXTERNAL_WS2="${EXTERNAL_WS2:-10}"  # Workspaces for external monitor
LAPTOP_WS="${LAPTOP_WS:-6 7 8 9}"     # Workspaces for laptop monitor
# ========== END CONFIGURATION SECTION ==========

# Debounce: single instance at a time
exec 9>/run/lid-switch.lock || true
if command -v flock >/dev/null 2>&1; then
  flock -n 9 || { log "Another lid handler instance running, exiting."; exit 0; }
fi

require_cmd() { command -v "$1" >/dev/null 2>&1 || { log "Missing command: $1"; exit 1; }; }
require_cmd hyprctl
require_cmd logger

get_hypr_user() {
  local u
  u=$(ps -o user= -C Hyprland | head -n1 || true)
  if [ -z "$u" ]; then
    u=$(ps aux | grep -E '[Hh]yprland' | awk '{print $1}' | head -n1 || true)
  fi
  echo "$u"
}

export_hypr_env() {
  HYPR_USER="${HYPR_USER:-$(get_hypr_user)}"
  if [ -z "$HYPR_USER" ]; then
    log "Hyprland user not found."
    return 1
  fi
  local pid
  pid=$(pgrep -u "$HYPR_USER" -x Hyprland | head -n1 || true)
  if [ -z "$pid" ]; then
    pid=$(pgrep -u "$HYPR_USER" -f '[Hh]yprland' | head -n1 || true)
  fi
  if [ -z "$pid" ]; then
    log "Hyprland PID not found for user $HYPR_USER."
    return 1
  fi
  
  # Get XDG_RUNTIME_DIR from the process environment
  XDG_RUNTIME_DIR=$(cat /proc/"$pid"/environ | tr '\0' '\n' | awk -F= '$1=="XDG_RUNTIME_DIR"{print $2}')
  if [ -z "$XDG_RUNTIME_DIR" ]; then
    XDG_RUNTIME_DIR="/run/user/$(id -u "$HYPR_USER")"
  fi
  
  # Try to get HYPRLAND_INSTANCE_SIGNATURE from the process environment
  HYPR_SIG=$(cat /proc/"$pid"/environ | tr '\0' '\n' | awk -F= '$1=="HYPRLAND_INSTANCE_SIGNATURE"{print $2}')
  
  # If not found (e.g., UWSM managed), try to find the most recent socket directory
  if [ -z "$HYPR_SIG" ]; then
    # Look for the most recent Hyprland socket directory
    local latest_socket=""
    local latest_time=0
    for socket_dir in "$XDG_RUNTIME_DIR"/hypr/*/; do
      if [ -d "$socket_dir" ] && [ -S "${socket_dir}/.socket.sock" ]; then
        local mtime=$(stat -c %Y "$socket_dir" 2>/dev/null || echo 0)
        if [ "$mtime" -gt "$latest_time" ]; then
          latest_time="$mtime"
          latest_socket="$socket_dir"
        fi
      fi
    done
    if [ -n "$latest_socket" ]; then
      HYPR_SIG=$(basename "$latest_socket")
    fi
  fi
  
  if [ -z "$XDG_RUNTIME_DIR" ]; then
    log "Could not determine XDG_RUNTIME_DIR for user $HYPR_USER."
    return 1
  fi
  
  # We can proceed even without HYPR_SIG as hyprctl might work without it
  export HYPR_USER HYPR_SIG XDG_RUNTIME_DIR
  log "Hyprland env: user=$HYPR_USER, XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR, sig=${HYPR_SIG:-'(auto-detect)'}"
}

run_as_hypr() {
  if [ -n "$HYPR_SIG" ]; then
    if command -v runuser >/dev/null 2>&1; then
      runuser -u "$HYPR_USER" -- env HYPRLAND_INSTANCE_SIGNATURE="$HYPR_SIG" XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" "$@"
    else
      sudo -u "$HYPR_USER" env HYPRLAND_INSTANCE_SIGNATURE="$HYPR_SIG" XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" "$@"
    fi
  else
    # Try without HYPR_SIG, let hyprctl auto-detect
    if command -v runuser >/dev/null 2>&1; then
      runuser -u "$HYPR_USER" -- env XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" "$@"
    else
      sudo -u "$HYPR_USER" env XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" "$@"
    fi
  fi
}

hypr() {
  run_as_hypr hyprctl "$@"
}

external_connected() {
  # Prefer sysfs so it works even before Hyprland sees it
  local f
  for f in /sys/class/drm/card*-${EXTERNAL_MONITOR}/status; do
    [ -r "$f" ] && grep -q '^connected' "$f" && return 0
  done
  # Fallback via Hyprland view
  hypr monitors 2>/dev/null | grep -q "^Monitor ${EXTERNAL_MONITOR} " && return 0
  return 1
}

move_ws_to_monitor() {
  local dest="$1"
  shift
  local ws
  for ws in "$@"; do
    hypr dispatch moveworkspacetomonitor "$ws" "$dest" >/dev/null 2>&1 || true
  done
}

set_external_only() {
  # Enable external and disable laptop using configured values
  hypr keyword monitor "${EXTERNAL_MONITOR},${EXTERNAL_RESOLUTION},${EXTERNAL_POSITION},${EXTERNAL_SCALE}"
  hypr keyword monitor "${EXTERNAL_MONITOR2},${EXTERNAL_RESOLUTION},${EXTERNAL_POSITION2},${EXTERNAL_SCALE}"
  hypr keyword monitor "${LAPTOP_MONITOR},disable"
}

set_dual_layout() {
  # External and laptop both enabled, positions/scales from config
  hypr keyword monitor "${EXTERNAL_MONITOR},${EXTERNAL_RESOLUTION},${EXTERNAL_POSITION},${EXTERNAL_SCALE}"
  hypr keyword monitor "${EXTERNAL_MONITOR2},${EXTERNAL_RESOLUTION},${EXTERNAL_POSITION2},${EXTERNAL_SCALE}"
  hypr keyword monitor "${LAPTOP_MONITOR},${LAPTOP_RESOLUTION},${LAPTOP_POSITION_DUAL},${LAPTOP_SCALE}"
}

set_laptop_only() {
  hypr keyword monitor "${EXTERNAL_MONITOR},disable"
  hypr keyword monitor "${EXTERNAL_MONITOR2},disable"
  hypr keyword monitor "${LAPTOP_MONITOR},${LAPTOP_RESOLUTION},${LAPTOP_POSITION_SOLO},${LAPTOP_SCALE}"
}

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    run_as_hypr notify-send "$@"
  fi
}
