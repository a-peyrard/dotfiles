#! /usr/bin/env bash

STATE_FILE="/tmp/yabai_display_state"
POSITIONS_FILE="/tmp/window_positions.json"

display_count=$(yabai -m query --displays | jq length)

echo -e "\n============== Executing on $(date) (w/ ${display_count} displays) ==============="

save_display_count() {
  echo "$1" > "$STATE_FILE"
}

save_window_positions() {
  local current_displays=$(yabai -m query --displays | jq length)
  
  yabai -m query --windows |
    jq '[.[] | {window: .id, app: .app, title: .title, space: .space, display: .display}]' > /tmp/window_positions_raw.json

  # Always store in "1-display canonical format"
  if [ "$current_displays" -eq 2 ]; then
    jq '[.[] | {
      window: .window,
      app: .app,
      title: .title,
      space: (if .space == 11 then 3 else .space end),
      display: .display
    }]' /tmp/window_positions_raw.json > "$POSITIONS_FILE"
  elif [ "$current_displays" -eq 3 ]; then
    jq '[.[] | {
      window: .window,
      app: .app,
      title: .title,
      space: (if .space == 11 then 2 elif .space == 12 then 3 else .space end),
      display: .display
    }]' /tmp/window_positions_raw.json > "$POSITIONS_FILE"
  else
    cp /tmp/window_positions_raw.json "$POSITIONS_FILE"
  fi

  echo "Window positions saved at $(date)"
}

restore_and_transform() {
  local to=$1
  
  if [ ! -f "$POSITIONS_FILE" ]; then
    echo "No positions file found, skipping transformation"
    return
  fi
  
  echo "Restoring windows for ${to} displays..."
  
  echo "DEBUG: Firefox position in dump:"
  jq '.[] | select(.app == "Firefox")' "$POSITIONS_FILE"
  
  # Transform FROM canonical (1-display) format TO current display count
  local space_map=""
  case "$to" in
    1) space_map='.space' ;; # No transformation needed, already in canonical format
    2) space_map='if .space == 3 then 11 else .space end' ;;
    3) space_map='if .space == 2 then 11 elif .space == 3 then 12 else .space end' ;;
    *) 
      echo "Unknown display count: ${to}"
      return
      ;;
  esac
  
  jq -r '[.[] | {window: .window, app: .app, new_space: ('"$space_map"')}] | .[] | "\(.window) \(.new_space) \(.app)"' "$POSITIONS_FILE" | \
  while read -r window_id new_space app_name; do
    echo "Moving window ${app_name} to space ${new_space} (window #${window_id})"
    yabai -m window "$window_id" --space "$new_space" 2>/dev/null || echo "  Failed to move window ${window_id}"
  done
}

if [ "$1" = "dump" ]; then
  save_window_positions
  save_display_count "$display_count"
elif [ "$1" = "transform" ]; then
  restore_and_transform "$display_count"
  save_display_count "$display_count"
else
  echo "Usage: $0 {dump|transform}"
fi