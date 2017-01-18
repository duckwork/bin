#!/bin/sh

while sleep 60; do
    # things to do every minute
    if xrandr 2>/dev/null; then
        xmonadctl refresh-panel;
    else
        exit;
    fi
done
