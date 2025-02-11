#!/usr/bin/env bash
source "$HOME/.config/sketchybar/colors.sh" # Loads all defined colors

YES="yes"
NO="no"

declare -a EMPTY_WORKSPACE_PROPS=(
    icon.drawing=off
    icon.padding_left=0
    icon.padding_right=0

    label.drawing=off
    label.padding_left=0
    label.padding_right=0

    background.drawing=off
    background.padding_left=0
    background.padding_right=0
)

AEROSPACE_NUM_MONITORS=$(aerospace list-monitors | wc -l)
AEROSPACE_WORKSPACES=$(aerospace list-workspaces --all)
AEROSPACE_EMPTY_WORKSPACES=""
AEROSPACE_NON_EMPTY_WORKSPACES=""

ANIMATION_DURATION="1"
ANIMATION_TYPE="tanh"

# Cache directory setup
CACHE_DIR="/tmp/sketchybar"
EMPTY_WORKSPACES_CACHE="$CACHE_DIR/empty_workspaces"
NON_EMPTY_WORKSPACES_CACHE="$CACHE_DIR/non_empty_workspaces"
mkdir -p "$CACHE_DIR"

# Helper Functions
# Get empty workspaces across all monitors
_update_workspaces_status() {
  local empty_workspaces=""
  local non_empty_workspaces=""
  local num_monitors=$(aerospace list-monitors | wc -l)

  for ((monitor = 1; monitor <= num_monitors; monitor++)); do
    empty_workspaces="$empty_workspaces $(aerospace list-workspaces --monitor $monitor --empty)"
  done

  for workspace in $AEROSPACE_WORKSPACES; do
    if [[ ! "$empty_workspaces" =~ (^|[[:space:]])$workspace($|[[:space:]]) ]]; then
      non_empty_workspaces="$non_empty_workspaces $workspace"
    fi
  done

  if [ "$1" = "--update-cache" ]; then
    echo "$empty_workspaces" > "$EMPTY_WORKSPACES_CACHE"
    echo "$non_empty_workspaces" > "$NON_EMPTY_WORKSPACES_CACHE"
  fi

  AEROSPACE_EMPTY_WORKSPACES=$empty_workspaces
  AEROSPACE_NON_EMPTY_WORKSPACES=$non_empty_workspaces
}

# Get cached empty workspaces, updating if necessary
update_workspaces_status() {
  # Update cache if it doesn't exist or is older than 10 seconds
  if [ ! -f "$EMPTY_WORKSPACES_CACHE" ] || [ $(( $(date +%s) - $(stat -f %m "$EMPTY_WORKSPACES_CACHE") )) -gt 10 ]; then
    _update_workspaces_status --update-cache
  elif [ -z "$AEROSPACE_EMPTY_WORKSPACES" ] && [ -z "$AEROSPACE_NON_EMPTY_WORKSPACES" ]; then
    # Load from the cache if needed
    AEROSPACE_EMPTY_WORKSPACES=$(cat "$EMPTY_WORKSPACES_CACHE")
    AEROSPACE_NON_EMPTY_WORKSPACES=$(cat "$NON_EMPTY_WORKSPACES_CACHE")
  fi
#   echo "DEBUG: Empty = [$AEROSPACE_EMPTY_WORKSPACES]"
#   echo "DEBUG: NonEmpty = [$AEROSPACE_NON_EMPTY_WORKSPACES]"
}

# Check if a workspace is empty
is_workspace_empty() {
  local workspace_id="$1"
  [[ $AEROSPACE_EMPTY_WORKSPACES =~ (^|[[:space:]])$workspace_id($|[[:space:]]) ]]
}

init_aerospace() {
    update_workspaces_status;

    # Initialize a listener for Aerospace updates so only that is called once per workspace change
    props=(
        "${EMPTY_WORKSPACE_PROPS[@]}"
        script="$CONFIG_DIR/plugins/aerospace.sh refresh"
    )
    monitor_name="space.aerospace_monitor"
    sketchybar --add item $monitor_name left \
        --subscribe $monitor_name aerospace_workspace_change \
        --set $monitor_name "${props[@]}"

    # Initialize all workspaces
    for sid in $AEROSPACE_WORKSPACES; do
        props=(
            icon="$sid"
            "${EMPTY_WORKSPACE_PROPS[@]}"

            # Default values for spaces that dont change
            background.corner_radius=5
            background.height=20
            label.font="sketchybar-app-font:Regular:12.0"
            click_script="aerospace workspace $sid"
        )

        sketchybar --add item space.$sid left \
            --subscribe space.$sid aerospace_workspace_change \
            --set space.$sid "${props[@]}"
    done

    aerospace_workspace_change
}


aerospace_workspace_change() {
    update_workspaces_status
    AEROSPACE_CURR_WORKSPACE=$(aerospace list-workspaces --focused)

    # Debug: Check if there are 2 monitors
    AEROSPACE_ALT_MONITOR_WORKSPACE=$NO
    if [[ "$AEROSPACE_NUM_MONITORS" -eq 2 ]]; then
      # Debug: Get alternate monitor ID and workspace
      AEROSPACE_ALT_MONITOR=$(aerospace list-monitors --focused no --format %{monitor-id})
      AEROSPACE_ALT_MONITOR_WORKSPACE=$(aerospace list-workspaces --monitor $AEROSPACE_ALT_MONITOR --visible)
    fi

    for sid in $AEROSPACE_WORKSPACES; do
        if [ "$sid" = "$AEROSPACE_CURR_WORKSPACE" ]; then
            is_curr_workspace=$YES
        else
            is_curr_workspace=$NO
        fi

        # Set is_alt_monitor_workspace = (!is_curr_workspace && $sid === $AEROSPACE_ALT_MONITOR_WORKSPACE)
        if [[ "$is_curr_workspace" == "$NO" && "$sid" == "$AEROSPACE_ALT_MONITOR_WORKSPACE" ]]; then
            is_alt_monitor_workspace=$YES
        else
            is_alt_monitor_workspace=$NO
        fi

        if is_workspace_empty "$sid"; then
            is_empty_workspace=$YES
        else
            is_empty_workspace=$NO
        fi

        if [[ "$is_empty_workspace" == "$YES" && "$is_curr_workspace" == "$NO" ]]; then
            props=("${EMPTY_WORKSPACE_PROPS[@]}")
            sketchybar --animate $ANIMATION_TYPE $ANIMATION_DURATION --set space.$sid "${props[@]}" label=""
            continue
        fi

        bg_color=$SPACE_DESELECTED
        icon_color=$SPACE_ICON_DESELECTED
        label_color=$SPACE_LABEL_DESELECTED

        if [[ "$is_curr_workspace" == "$YES" ]]; then
            bg_color=$SPACE_SELECTED
            icon_color=$SPACE_ICON_SELECTED
            label_color=$SPACE_LABEL_SELECTED
        elif [[ "$is_alt_monitor_workspace" == "$YES" ]]; then
            bg_color=$SPACE_ALT_SELECTED
            icon_color=$SPACE_ALT_ICON_SELECTED
            label_color=$SPACE_ALT_LABEL_SELECTED
        fi

        apps=$(aerospace list-windows --workspace "$sid" | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')
        icon_strip="-"
        if [ "${apps}" != "" ]; then
            icon_strip=""
            while read -r app; do
            icon_strip+=" $($CONFIG_DIR/plugins/icon_map_fn.sh "$app")"
            done <<<"${apps}"
        fi

        props=(
            icon.drawing=on
            icon.padding_left=5
            icon.padding_right=5
            icon.color=$icon_color

            label.drawing=on
            label.padding_left=5
            label.padding_right=10
            label.color=$label_color

            background.drawing=on
            background.padding_left=2
            background.padding_right=2
            background.color=$bg_color
        )
        sketchybar --animate $ANIMATION_TYPE $ANIMATION_DURATION --set space.$sid label="$icon_strip" ${props[@]}
    done
}

case "$SENDER" in
  "forced") exit 0
  ;;
  "aerospace_workspace_change") aerospace_workspace_change
  ;;
  *) init_aerospace
  ;;
esac
