#!/bin/bash
# group-app-accordion.sh
# Groups all windows of the focused app in the current workspace into an accordion

# Get the focused window's app-bundle-id
FOCUSED_APP=$(aerospace list-windows --focused --format '%{app-bundle-id}')
FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)

if [ -z "$FOCUSED_APP" ]; then
    echo "No focused window"
    exit 1
fi

# Get all window IDs for this app in the current workspace
WINDOW_IDS=$(aerospace list-windows --workspace "$FOCUSED_WORKSPACE" --format '%{app-bundle-id}|%{window-id}' | \
    grep "^${FOCUSED_APP}|" | \
    cut -d'|' -f2)

# Count windows
WINDOW_COUNT=$(echo "$WINDOW_IDS" | wc -l | tr -d ' ')

if [ "$WINDOW_COUNT" -lt 2 ]; then
    echo "Only $WINDOW_COUNT window(s) of $FOCUSED_APP in workspace $FOCUSED_WORKSPACE, nothing to group"
    exit 0
fi

# Get OTHER windows (not the target app) in this workspace
OTHER_WINDOW_IDS=$(aerospace list-windows --workspace "$FOCUSED_WORKSPACE" --format '%{app-bundle-id}|%{window-id}' | \
    grep -v "^${FOCUSED_APP}|" | \
    cut -d'|' -f2)

# Get total windows to calculate moves needed
TOTAL_WINDOWS=$(aerospace list-windows --workspace "$FOCUSED_WORKSPACE" --format '%{window-id}' | wc -l | tr -d ' ')
MOVES_NEEDED=$((TOTAL_WINDOWS - 1))

# Step 1: Move all OTHER windows to the far right
for OTHER_ID in $OTHER_WINDOW_IDS; do
    aerospace focus --window-id "$OTHER_ID"
    for j in $(seq 1 $MOVES_NEEDED); do
        aerospace move right
    done
done

# Step 2: Focus any target window and apply accordion
FIRST_WINDOW=$(echo "$WINDOW_IDS" | head -n1)
aerospace focus --window-id "$FIRST_WINDOW"
aerospace layout accordion horizontal
