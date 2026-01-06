#!/bin/bash

# Usage: toggle-app.sh <app-name> <app-id> [hidden-workspace]
# Example: toggle-app.sh Ghostty com.mitchellh.ghostty S

APP_NAME="$1"
APP_ID="$2"
HIDDEN_WS="${3:-S}"  # Default to S if not provided

if [ -z "$APP_NAME" ] || [ -z "$APP_ID" ]; then
    echo "Usage: $0 <app-name> <app-id> [hidden-workspace]"
    exit 1
fi

LOG="/tmp/aerospace-${APP_NAME}-toggle.log"

echo "$(date): Toggle triggered for $APP_NAME" >> "$LOG"

# Get app window ID and workspace in one query
APP_INFO=$(aerospace list-windows --monitor all --app-id "$APP_ID" --format "%{window-id}|%{workspace}" | head -n1)
APP_WINDOW=$(echo "$APP_INFO" | cut -d'|' -f1)
APP_WS=$(echo "$APP_INFO" | cut -d'|' -f2)

# Get ALL window IDs
ALL_WINDOWS=$(aerospace list-windows --monitor all --app-id "$APP_ID" --format "%{window-id}")

echo "$(date): $APP_NAME window ID: $APP_WINDOW" >> "$LOG"
echo "$(date): $APP_NAME workspace: $APP_WS" >> "$LOG"

if [ -z "$APP_WINDOW" ]; then
    # No app window exists, open it
    echo "$(date): No $APP_NAME window, opening..." >> "$LOG"
    open -a "$APP_NAME"
    sleep 0.3
    APP_WINDOW=$(aerospace list-windows --monitor all --app-id "$APP_ID" --format "%{window-id}" | head -n1)
    if [ -n "$APP_WINDOW" ]; then
        aerospace layout --window-id "$APP_WINDOW" floating
        echo "$(date): Opened and set to floating" >> "$LOG"
        
        echo "$(date): Changing fullscreen after opening for $APP_ID" >> "$LOG"
        aerospace fullscreen --window-id "$APP_WINDOW" on
    fi
else
    # Get the workspace visible on main display
    CURRENT_WS=$(aerospace list-workspaces --monitor all --visible --format '%{monitor-is-main}|%{workspace}'|grep true|cut -d'|' -f2)
    echo "$(date): Current workspace on main: $CURRENT_WS" >> "$LOG"
    
    if [ "$APP_WS" = "$CURRENT_WS" ]; then
        # App is here, hide all windows
        echo "$(date): Hiding all $APP_NAME windows (moving to $HIDDEN_WS)" >> "$LOG"

        # Check if current focused window belongs to this app and save it
        FOCUSED_WINDOW=$(aerospace list-windows --focused --format "%{window-id}")
        echo "$(date): Currently focused window: $FOCUSED_WINDOW" >> "$LOG"
        if echo "$ALL_WINDOWS" | grep -q "^$FOCUSED_WINDOW$"; then
            echo "$FOCUSED_WINDOW" > "/tmp/aerospace-${APP_NAME}-focused-window"
            echo "$(date): Saved focused window $FOCUSED_WINDOW" >> "$LOG"
        fi

        echo "$ALL_WINDOWS" | while read -r wid; do
            aerospace move-node-to-workspace --window-id "$wid" "$HIDDEN_WS"
        done
    else
        # App is elsewhere, bring all windows here
        echo "$(date): Showing all $APP_NAME windows (moving to $CURRENT_WS)" >> "$LOG"

        echo "$ALL_WINDOWS" | while read -r wid; do
            echo "$(date): Processing window $wid" >> "$LOG"
            aerospace fullscreen --window-id "$wid" on
            aerospace move-node-to-workspace --window-id "$wid" "$CURRENT_WS"
            aerospace layout --window-id "$wid" floating
        done

        # Restore focus to previously focused window if it still exists
        SAVED_FOCUSED="/tmp/aerospace-${APP_NAME}-focused-window"
        if [ -f "$SAVED_FOCUSED" ]; then
            FOCUSED_WINDOW=$(cat "$SAVED_FOCUSED")
            echo "$(date): Attempting to restore focus to saved window $FOCUSED_WINDOW" >> "$LOG"
            if echo "$ALL_WINDOWS" | grep -q "^$FOCUSED_WINDOW$"; then
                aerospace focus --window-id "$FOCUSED_WINDOW"
                echo "$(date): Restored focus to window $FOCUSED_WINDOW" >> "$LOG"
            else
                # Saved window no longer exists, focus first window
                echo "$(date): Saved window no longer exists, focusing first window $APP_WINDOW" >> "$LOG"
                aerospace focus --window-id "$APP_WINDOW"
            fi
        else
            # No saved focus, default to first window
            echo "$(date): No saved focus, focusing first window $APP_WINDOW" >> "$LOG"
            aerospace focus --window-id "$APP_WINDOW"
        fi
    fi
fi

echo "=== final status" >> "$LOG"
aerospace list-windows --app-id $APP_ID --monitor all --format "%{window-id}|%{window-is-fullscreen}|%{window-layout}|%{window-parent-container-layout}|%{window-title}|%{workspace}|%{monitor-id}" >> "$LOG"
