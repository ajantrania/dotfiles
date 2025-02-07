#!/usr/bin/env bash
source "$HOME/.config/sketchybar/colors.sh" # Loads all defined colors
FONT="Hack Nerd Font"
TIMER_PID_FILE="/tmp/sketchybar_popup_timer.pid"

# Define default properties as an array
declare -a DEFAULT_POPUP_PROPS=(
    icon.font=sketchybar-app-font:Regular:12.0
    icon.color=$SPACE_ICON_SELECTED
    icon.drawing=on
    icon.padding_left=5
    icon.padding_right=0

    label.drawing=on
    label.font="$FONT:Regular:14.0"
    label.color=$SPACE_LABEL_SELECTED
    label.padding_left=5
    label.padding_right=10

    background.drawing=on
    background.color=$SPACE_SELECTED
    background.padding_left=0
    background.padding_right=0
    background.height=30
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
        sleep 5
        sketchybar --set front_app popup.drawing=off
        rm "$TIMER_PID_FILE"
    } &
    echo $! > "$TIMER_PID_FILE"
}

get_windows() {
  current_app="$INFO"
  current_workspace=$(aerospace list-workspaces --focused)
  max_width=0

  # Process all window information in a single jq call
  while IFS=$'\t' read -r app_name window_title window_id; do
      app_icon="$($CONFIG_DIR/plugins/icon_map_fn.sh "$app_name")"

      # Highlight the current window
      if [ "$app_name" = "$current_app" ]; then
        props=(
          "${DEFAULT_POPUP_PROPS[@]}"
          label.color=$WINDOW_LABEL_SELECTED
          icon.color=$WINDOW_ICON_SELECTED
        )
      else
        props=(
          "${DEFAULT_POPUP_PROPS[@]}"
        )
      fi

      # Create a unique item name for this window
      item_name="fa_popup.$window_id"

      # Add the item to sketchybar
      sketchybar --add item "$item_name" popup.front_app \
        --set "$item_name" \
          icon="$app_icon" \
          label="$app_name - $window_title" \
          click_script="aerospace focus --window-id $window_id" \
          "${props[@]}"

    done < <(aerospace list-windows --workspace $current_workspace --json | \
         jq -r '.[] | [.["app-name"], .["window-title"], .["window-id"]] | @tsv')
}

update_front_app() {
  app_icon="$($CONFIG_DIR/plugins/icon_map_fn.sh $INFO)"
  sketchybar --set "$NAME" icon="$app_icon" label="$INFO"

  # Remove any items in the popup
  sketchybar --remove /fa_popup.*/ >>/dev/null

  get_windows
}

popup() {
    if [ "$1" = "toggle" ]; then
        if [ "$(sketchybar --query front_app | jq -r '.popup.drawing')" = "true" ]; then
            popup off
        else
            popup on
        fi
    else
        if [ "$1" = "on" ]; then
            sketchybar --set "$NAME" popup.drawing="$1"
            start_timer
        else
            sketchybar --set "$NAME" popup.drawing="$1"
            kill_timer
        fi
    fi
}

case "$SENDER" in
"mouse.entered")
  popup on
  ;;
"mouse.exited" | "mouse.exited.global")
  popup off
  ;;
"mouse.clicked")
  popup toggle
  ;;
"front_app_switched")
    update_front_app
  ;;
esac