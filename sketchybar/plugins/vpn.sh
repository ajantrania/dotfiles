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

# Cache expiry time in seconds
CACHE_EXPIRY=60  # 1 minute

# Ensure cache directory exists
mkdir -p "$CACHE_DIR"

# Function to normalize tailscale status by removing traffic stats
normalize_tailscale_status() {
    local status="$1"
    # Remove tx/rx values and relay information
    echo "$status" | sed -E 's/relay "[^"]*", tx [0-9]+ rx [0-9]+//g' | sed -E 's/tx [0-9]+ rx [0-9]+//g'
}

# Function to detect generic VPN status via interface detection
detect_vpn_interface() {
    # Check for VPN by looking for utun interfaces with IP addresses
    # Tailscale uses 100.64.0.0/10 range (100.64.x.x to 100.127.x.x)
    # Nord and others often use 10.0.0.0/8 range
    if ifconfig | grep -A3 "^utun" | grep -q "inet 100\."; then
        echo "tailscale"
    elif ifconfig | grep -A3 "^utun" | grep -q "inet 10\."; then
        echo "vpn"
    else
        echo "none"
    fi
}

# Function to check if cache is expired
is_cache_expired() {
    local cache_time="$1"
    local current_time=$(date +%s)
    local age=$((current_time - cache_time))
    [ $age -gt $CACHE_EXPIRY ]
}

# Function to read from cache
read_cache() {
    if [ -f "$CACHE_FILE" ]; then
        source "$CACHE_FILE"
    else
        CACHED_TAILSCALE_STATUS=""
        CACHED_VPN_INTERFACE=""
        CACHED_GEO_LOCATION=""
        CACHE_TIMESTAMP=0
    fi
}

# Function to write to cache
write_cache() {
    local timestamp=$(date +%s)
    echo "CACHED_TAILSCALE_STATUS='$CACHED_TAILSCALE_STATUS'" > "$CACHE_FILE"
    echo "CACHED_VPN_INTERFACE='$CACHED_VPN_INTERFACE'" >> "$CACHE_FILE"
    echo "CACHED_GEO_LOCATION='$CACHED_GEO_LOCATION'" >> "$CACHE_FILE"
    echo "CACHE_TIMESTAMP=$timestamp" >> "$CACHE_FILE"
}

# Function to update VPN status
update_vpn() {
    # Read cached values
    read_cache

    # Check if tailscale is running first (primary method)
    TAILSCALE_STATUS=$(/usr/local/bin/tailscale status 2>/dev/null)

    # Detect VPN via interface as fallback
    VPN_INTERFACE=$(detect_vpn_interface)

    # Normalize the tailscale status for comparison
    NORMALIZED_STATUS=$(normalize_tailscale_status "$TAILSCALE_STATUS")
    NORMALIZED_CACHED_STATUS=$(normalize_tailscale_status "$CACHED_TAILSCALE_STATUS")

    NEED_GEO_UPDATE=false

    if [ -n "$TAILSCALE_STATUS" ] && [ "$NORMALIZED_STATUS" != "$NORMALIZED_CACHED_STATUS" ]; then
        # Tailscale status changed
        NEED_GEO_UPDATE=true
    elif [ "$VPN_INTERFACE" != "$CACHED_VPN_INTERFACE" ]; then
        # VPN interface changed (for Nord or when Tailscale is stopped)
        NEED_GEO_UPDATE=true
    elif is_cache_expired "$CACHE_TIMESTAMP"; then
        # Cache expired
        NEED_GEO_UPDATE=true
    elif [ -z "$CACHED_GEO_LOCATION" ]; then
        # No cached location
        NEED_GEO_UPDATE=true
    fi

    # Update geo location if needed
    if [ "$NEED_GEO_UPDATE" = true ]; then
        # Fetch location and strip any whitespace/newlines
        GEO_LOCATION=$(/usr/bin/curl -s --max-time 2 ipinfo.io/country 2>/dev/null | tr -d '\n\r ')
        CACHED_GEO_LOCATION="$GEO_LOCATION"
    else
        GEO_LOCATION="$CACHED_GEO_LOCATION"
    fi

    # Update cache
    CACHED_TAILSCALE_STATUS="$TAILSCALE_STATUS"
    CACHED_VPN_INTERFACE="$VPN_INTERFACE"
    write_cache

    # Set country icon
    if [[ "$GEO_LOCATION" == "US" ]]; then
        COUNTRY=$ICON_COUNTRY_US
    elif [[ "$GEO_LOCATION" == "JP" ]]; then
        COUNTRY=$ICON_COUNTRY_JP
    else
        COUNTRY="$GEO_LOCATION"
    fi

    # Update sketchybar based on VPN status
    if [ -n "$TAILSCALE_STATUS" ] && [[ "$TAILSCALE_STATUS" != *"Tailscale is stopped"* ]]; then
        # Tailscale is running (use CLI for detailed status)
        if [[ "$TAILSCALE_STATUS" == *"; exit node;"* ]]; then
            # Tailscale with exit node
            sketchybar --set $NAME icon=$ICON_VPN_ON_EXIT_NODE_ON icon.color=$ORANGE icon.highlight=off label=$COUNTRY
        else
            # Tailscale without exit node
            sketchybar --set $NAME icon=$ICON_VPN_ON_EXIT_NODE_OFF icon.color=$LABEL_COLOR icon.highlight=off label=$COUNTRY
        fi
    elif [ "$VPN_INTERFACE" = "vpn" ]; then
        # Generic VPN detected (Nord, etc.)
        sketchybar --set $NAME icon=$ICON_VPN_ON_EXIT_NODE_ON icon.color=$LABEL_COLOR icon.highlight=off label=$COUNTRY
    elif [ "$VPN_INTERFACE" = "tailscale" ]; then
        # Tailscale detected via interface but no CLI (shouldn't happen normally)
        sketchybar --set $NAME icon=$ICON_VPN_ON_EXIT_NODE_OFF icon.color=$LABEL_COLOR icon.highlight=off label=$COUNTRY
    else
        # No VPN active
        sketchybar --set $NAME icon=$ICON_VPN_OFF icon.color=$WARM_GRAY icon.highlight=off label=$COUNTRY
    fi
}

update_vpn