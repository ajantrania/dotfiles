#!/bin/bash

source "$CONFIG_DIR/colors.sh"

# Icon mapping for VPN status
ICON_VPN_OFF="󰲛"
ICON_VPN_ON_EXIT_NODE_OFF="󰛳"
ICON_VPN_ON_EXIT_NODE_ON="󰒄"

# Function to update VPN status
update_vpn() {
  # Check if tailscale is running
  TAILSCALE_STATUS=$(tailscale status 2>/dev/null)

  if [[ "$TAILSCALE_STATUS" == *"Tailscale is stopped"* ]]; then
    # Tailscale is not running
    sketchybar --set $NAME icon=$ICON_VPN_OFF icon.color=$WARM_GRAY icon.highlight=off label=""
  elif [[ "$TAILSCALE_STATUS" == *"; exit node;"* ]]; then
    # Tailscale is running with exit node active
    sketchybar --set $NAME icon=$ICON_VPN_ON_EXIT_NODE_ON icon.color=$ORANGE icon.highlight=off label=""
  else
    # Tailscale is running without exit node
    sketchybar --set $NAME icon=$ICON_VPN_ON_EXIT_NODE_OFF icon.color=$LABEL_COLOR icon.highlight=off label=""
  fi
}

# Define default properties as an array
declare -a DEFAULT_POPUP_PROPS=(
    icon.font=sketchybar-app-font:Regular:12.0
    icon.color=$FRONT_APP_POPUP_ICON
    icon.drawing=on
    icon.padding_left=5
    icon.padding_right=0

    label.drawing=on
    label.font="Hack Nerd Font:Regular:14.0"
    label.color=$ORANGE
    label.padding_left=5
    label.padding_right=10

    background.drawing=on
    background.color=$FRONT_APP_POPUP_BACKGROUND
    background.padding_left=0
    background.padding_right=0
    background.height=30
    width=250
)

# Update on script launch
if [ "$SENDER" = "routine" ] || [ "$SENDER" = "forced" ]; then
  update_vpn
fi

# Handle mouse events for VPN status
case "$SENDER" in
  "mouse.entered")
    # Get current Tailscale status
    TAILSCALE_STATUS=$(tailscale status 2>&1)

    # Show popup with appropriate message based on status
    sketchybar --set "$NAME" popup.drawing=on

    # Determine popup content based on Tailscale status
    if [[ "$TAILSCALE_STATUS" == *"Tailscale is stopped"* ]]; then
      # Tailscale is not running
      POPUP_LABEL="Tailscale off"
    elif [[ "$TAILSCALE_STATUS" == *"; exit node;"* ]]; then
      # Extract exit node name
      EXIT_NODE=$(echo "$TAILSCALE_STATUS" | grep -E "; exit node;" | awk '{print $2}')
      POPUP_LABEL="Using $EXIT_NODE"
    else
      # Tailscale is running without exit node
      POPUP_LABEL="No Exit Node"
    fi

    # Create the popup with determined label
    sketchybar --add item vpn.status popup."$NAME" \
      --set vpn.status label="$POPUP_LABEL" \
        "${DEFAULT_POPUP_PROPS[@]}"
    ;;

  "mouse.exited"|"mouse.clicked")
    echo "Mouse exited or clicked event triggered"
    # Hide popup when mouse exits or when clicked
    sketchybar --set "$NAME" popup.drawing=off
    ;;
esac