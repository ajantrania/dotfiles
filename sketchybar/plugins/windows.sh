#!/usr/bin/env bash
source "$HOME/.config/sketchybar/colors.sh"
FONT="Hack Nerd Font"
TIMER_PID_FILE="/tmp/sketchybar_windows_popup_timer.pid"

# Define default properties for the popup items
declare -a DEFAULT_POPUP_PROPS=(
    width=600
    padding_left=0
    padding_right=0
    background.padding_left=0
    background.padding_right=0
    background.height=30
    background.corner_radius=0
    background.drawing=on
)

declare -a WORKSPACE_HEADER_PROPS=(
    icon.font="$FONT:Bold:12.0"
    icon.padding_left=10
    icon.padding_right=0
    label.drawing=off
)

declare -a MONITOR_1_HEADER_PROPS=(
    background.color=$MONITOR_1_BACKGROUND
    label.color=$MONITOR_1_LABEL
    icon.color=$MONITOR_1_ICON
)

declare -a MONITOR_2_HEADER_PROPS=(
    background.color=$MONITOR_2_BACKGROUND
    label.color=$MONITOR_2_LABEL
    icon.color=$MONITOR_2_ICON
)

declare -a WINDOW_ITEM_PROPS=(
    icon.font="sketchybar-app-font:Regular:13.0"
    icon.color=$SPACE_ICON_DESELECTED
    icon.padding_left=10
    icon.padding_right=5
    label.font="$FONT:Bold:12.0"
    label.color=$SPACE_LABEL_DESELECTED
    label.padding_left=0
    label.padding_right=5
    background.color=$SPACE_DESELECTED
)

kill_timer() {
    if [ -f "$TIMER_PID_FILE" ]; then
        pid=$(cat "$TIMER_PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
        fi
        rm "$TIMER_PID_FILE"
    fi
}

start_timer() {
    kill_timer  # Kill any existing timer first
    {
        sleep 60
        sketchybar --set windows popup.drawing=off
        rm "$TIMER_PID_FILE"
    } &
    echo $! > "$TIMER_PID_FILE"
}

create_windows_popup() {
    # Get and store monitor IDs
    monitors=()
    while IFS= read -r line; do
        monitors+=("$line")
    done < <(aerospace list-monitors --json | jq -r '.[].["monitor-id"]')

    # Build popup
    build_start=$(perl -MTime::HiRes=time -e 'printf "%.9f\n", time')

    for monitor_id in "${monitors[@]}"; do
        monitor_label="󰍹 $monitor_id"

        # Get and store workspaces for this monitor
        workspaces=()
        while IFS= read -r workspace; do
            [ -n "$workspace" ] && workspaces+=("$workspace")
        done < <(aerospace list-workspaces --monitor "$monitor_id" --empty no)

        for workspace in "${workspaces[@]}"; do
            if [ "$monitor_id" = "1" ]; then
                monitor_props=("${MONITOR_1_HEADER_PROPS[@]}")
            else
                monitor_props=("${MONITOR_2_HEADER_PROPS[@]}")
            fi

            sketchybar --animate sin 30 --add item "windows.popup.monitor.$monitor_id.workspace.$workspace" popup.windows \
                      --set "windows.popup.monitor.$monitor_id.workspace.$workspace" \
                           icon="$monitor_label Workspace $workspace" \
                           "${DEFAULT_POPUP_PROPS[@]}" \
                           "${WORKSPACE_HEADER_PROPS[@]}" \
                           "${monitor_props[@]}"

            # Get and store windows for this workspace
            windows=()
            while IFS= read -r window; do
                [ -n "$window" ] && windows+=("$window")
            done < <(aerospace list-windows --workspace "$workspace" --json | jq -c '.[]')

            for window in "${windows[@]}"; do
                window_id=$(echo "$window" | jq -r '."window-id"')
                app_name=$(echo "$window" | jq -r '."app-name"')
                window_title=$(echo "$window" | jq -r '."window-title"')
                app_icon="$($CONFIG_DIR/plugins/icon_map_fn.sh "$app_name")"

                sketchybar --animate sin 30 --add item "windows.popup.$window_id" popup.windows \
                          --set "windows.popup.$window_id" \
                               icon="$app_icon" \
                               label="$app_name - $window_title" \
                               click_script="aerospace focus --window-id $window_id" \
                               "${DEFAULT_POPUP_PROPS[@]}" \
                               "${WINDOW_ITEM_PROPS[@]}"
            done
        done
    done
}

popup() {
    if [ "$1" = "toggle" ]; then
        if [ "$(sketchybar --query windows | jq -r '.popup.drawing')" = "on" ]; then
            popup off
        else
            popup on
        fi
    else
        if [ "$1" = "on" ]; then
            # Clear existing popup
            sketchybar --remove '/windows.popup.*/'
            sketchybar --set windows popup.drawing=on
            create_windows_popup
            start_timer
        else
            if [ "$(sketchybar --query windows | jq -r '.popup.drawing')" = "on" ]; then
              sketchybar --animate sin 30 --set windows popup.drawing=off
              kill_timer
            fi
        fi
    fi
}

case "$SENDER" in
"mouse.exited.global")
    popup off
    ;;
"mouse.clicked")
    popup toggle
    ;;
esac