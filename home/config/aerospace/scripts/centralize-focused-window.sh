#!/usr/bin/env bash
# https://betterprogramming.pub/best-practices-for-bash-scripts-17229889774d
set -o errexit
set -o nounset
set -o pipefail

print_screen_size() {
  # find focused monitor
  local monitor_name=$(aerospace list-monitors --focused --format '%{monitor-name}')
  case $monitor_name in
    "Built-in Retina Display")
      monitor_name="Color LCD";;
    *) ;;
  esac

  # check cache
  if [[ -e "/tmp/centralize-focused-window/display-info-${monitor_name}" ]]; then
    cat "/tmp/centralize-focused-window/display-info-${monitor_name}"
    return
  fi

  # display information of the focused monitor
  local jq_filter=".SPDisplaysDataType[].spdisplays_ndrvs[] | select(._name == \"${monitor_name}\") | ._spdisplays_resolution"
  local display_info=$(system_profiler SPDisplaysDataType -json | jq -r "${jq_filter}")

  # print screen size
  local screen_width=$(echo "${display_info}" | cut -d ' ' -f 1)
  local screen_height=$(echo "${display_info}" | cut -d ' ' -f 3)
  mkdir -p /tmp/centralize-focused-window
  echo "${screen_width} ${screen_height}" >> "/tmp/centralize-focused-window/display-info-${monitor_name}"
  cat "/tmp/centralize-focused-window/display-info-${monitor_name}"
}

centralize-focused-window() {
  local screen_size=$(print_screen_size)
  local screen_width=$(echo "${screen_size}" | cut -d ' ' -f 1)
  local screen_height=$(echo "${screen_size}" | cut -d ' ' -f 2)
  osascript <<EOF
set w to ${screen_width} / 5 * 3
set h to ${screen_height} / 5 * 3
set x to (${screen_width} - w) / 2
set y to (${screen_height} - h) / 2

tell application "System Events" to tell first application process whose frontmost is true
  -- it seems using only 'first window' or 'last window' (or 'front window') is not enough
  -- for some applications like Brave, Obsidian that have multiple windows and using both
  -- windows is necessary to centralize the focused window
  set position of first window to {x, y}
  set position of last window to {x, y}
  set size of first window to {w, h}
  set size of last window to {w, h}
end tell
EOF
}

centralize-focused-window
