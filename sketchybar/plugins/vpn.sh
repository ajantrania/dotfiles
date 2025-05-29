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

update_vpn