#!/bin/bash

CURRENT_DEVICE=$(SwitchAudioSource -c)

if [[ $CURRENT_DEVICE == "WH-1000XM5" ]]; then
  sketchybar --set $NAME drawing=on
else
  sketchybar --set $NAME drawing=off
fi