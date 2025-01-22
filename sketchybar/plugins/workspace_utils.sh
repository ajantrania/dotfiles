#!/usr/bin/env bash

# Cache directory setup
CACHE_DIR="/tmp/sketchybar"
EMPTY_WORKSPACES_CACHE="$CACHE_DIR/empty_workspaces"
mkdir -p "$CACHE_DIR"

# Get empty workspaces across all monitors
get_empty_workspaces() {
  local empty_workspaces=""
  local num_monitors=$(aerospace list-monitors | wc -l)

  for ((monitor = 1; monitor <= num_monitors; monitor++)); do
    empty_workspaces="$empty_workspaces $(aerospace list-workspaces --monitor $monitor --empty)"
  done

  # Write to cache if requested
  if [ "$1" = "--update-cache" ]; then
    echo "$empty_workspaces" > "$EMPTY_WORKSPACES_CACHE"
  fi

  echo "$empty_workspaces"
}

# Get cached empty workspaces, updating if necessary
get_cached_empty_workspaces() {
  # Update cache if it doesn't exist or is older than 10 seconds
  if [ ! -f "$EMPTY_WORKSPACES_CACHE" ] || [ $(( $(date +%s) - $(stat -f %m "$EMPTY_WORKSPACES_CACHE") )) -gt 10 ]; then
    get_empty_workspaces --update-cache
  fi
  cat "$EMPTY_WORKSPACES_CACHE"
}

# Check if a workspace is empty
is_workspace_empty() {
  local workspace_id="$1"
  local empty_workspaces="$2"
  [[ $empty_workspaces =~ (^|[[:space:]])$workspace_id($|[[:space:]]) ]] && echo "off" || echo "on"
}

# Get workspace properties based on empty and active status
get_workspace_properties() {
  local workspace_id="$1"
  local is_empty="$2"
  local is_active="$3"

  if [[ $is_empty == "off" && $is_active == "off" ]]; then
    echo "icon.drawing=off label.drawing=off padding_left=0 padding_right=0"
  else
    echo ""
  fi
}
