#!/bin/bash

source "$CONFIG_DIR/colors.sh"

# Icon mapping for VPN status
ICON_VPN_OFF="󰲛"
ICON_VPN_ON_EXIT_NODE_OFF="󰛳"
ICON_VPN_ON_EXIT_NODE_ON="󰒄"

# Icon mapping for country
ICON_COUNTRY_US="🇺🇸"
ICON_COUNTRY_JP="🇯🇵"

# Cache file location
CACHE_DIR="$CONFIG_DIR/cache"
CACHE_FILE="$CACHE_DIR/vpn_status.cache"

# Ensure cache directory exists
mkdir -p "$CACHE_DIR"

# Function to normalize tailscale status by removing traffic stats
normalize_tailscale_status() {
    local status="$1"
    # Remove tx/rx values and relay information
    echo "$status" | sed -E 's/relay "[^"]*", tx [0-9]+ rx [0-9]+//g' | sed -E 's/tx [0-9]+ rx [0-9]+//g'
}

# Function to read from cache
read_cache() {
    if [ -f "$CACHE_FILE" ]; then
        source "$CACHE_FILE"
    else
        CACHED_TAILSCALE_STATUS=""
        CACHED_GEO_LOCATION=""
    fi
}

# Function to write to cache
write_cache() {
    echo "CACHED_TAILSCALE_STATUS='$CACHED_TAILSCALE_STATUS'" > "$CACHE_FILE"
    echo "CACHED_GEO_LOCATION='$CACHED_GEO_LOCATION'" >> "$CACHE_FILE"
}

# Function to update VPN status
update_vpn() {
    # Read cached values
    read_cache

    # Check if tailscale is running
    TAILSCALE_STATUS=$(/usr/local/bin/tailscale status 2>/dev/null)

    # Normalize the status for comparison
    NORMALIZED_STATUS=$(normalize_tailscale_status "$TAILSCALE_STATUS")
    NORMALIZED_CACHED_STATUS=$(normalize_tailscale_status "$CACHED_TAILSCALE_STATUS")

    # Only update geo location if normalized tailscale status changed or no cached location
    if [ "$NORMALIZED_STATUS" != "$NORMALIZED_CACHED_STATUS" ] || [ -z "$CACHED_GEO_LOCATION" ]; then
        GEO_LOCATION=$(/usr/bin/curl ipinfo.io/country 2>/dev/null)
        CACHED_GEO_LOCATION="$GEO_LOCATION"
    else
        GEO_LOCATION="$CACHED_GEO_LOCATION"
    fi

    # Update cache with full status
    CACHED_TAILSCALE_STATUS="$TAILSCALE_STATUS"
    write_cache

    if [[ "$GEO_LOCATION" == "US" ]]; then
        COUNTRY=$ICON_COUNTRY_US
    elif [[ "$GEO_LOCATION" == "JP" ]]; then
        COUNTRY=$ICON_COUNTRY_JP
    else
        COUNTRY="$GEO_LOCATION"
    fi

    if [[ "$TAILSCALE_STATUS" == *"Tailscale is stopped"* ]]; then
        # Tailscale is not running
        sketchybar --set $NAME icon=$ICON_VPN_OFF icon.color=$WARM_GRAY icon.highlight=off label=$COUNTRY
    elif [[ "$TAILSCALE_STATUS" == *"; exit node;"* ]]; then
        # Tailscale is running with exit node active
        sketchybar --set $NAME icon=$ICON_VPN_ON_EXIT_NODE_ON icon.color=$ORANGE icon.highlight=off label=$COUNTRY
    else
        # Tailscale is running without exit node
        sketchybar --set $NAME icon=$ICON_VPN_ON_EXIT_NODE_OFF icon.color=$LABEL_COLOR icon.highlight=off label=$COUNTRY
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