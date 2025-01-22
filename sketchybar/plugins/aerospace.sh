#!/usr/bin/env bash

# make sure it's executable with:
# chmod +x ~/.config/sketchybar/plugins/aerospace.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/workspace_utils.sh"

# Read from cache with automatic updates
EMPTY_WORKSPACES=$(get_cached_empty_workspaces)

# Get focused workspace only when not provided
if [ -z "$FOCUSED_WORKSPACE" ]; then
    FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)
fi

# Use parameter expansion for faster string operations
workspace_id="$1"
is_empty_workspace=$([[ $EMPTY_WORKSPACES =~ (^|[[:space:]])$workspace_id($|[[:space:]]) ]] && echo "off" || echo "on")
is_active=$([[ "$workspace_id" = "$FOCUSED_WORKSPACE" ]] && echo "on" || echo "off")

# Only calculate properties if workspace is empty and not active
if [[ $is_empty_workspace == "off" && $is_active == "off" ]]; then
    sketchybar --set $NAME icon.drawing=off label.drawing=off padding_left=0 padding_right=0
else
    if [ "$workspace_id" = "$FOCUSED_WORKSPACE" ]; then
        sketchybar --set $NAME background.drawing=on icon.drawing=on
    else
        sketchybar --set $NAME background.drawing=off
    fi
fi