#!/usr/bin/env bash
# requires scrot & i3lock
# found on reddit.com/r/unixporn/comments/
# 3358vu/i3lock_unixpornworthy_lock_screen

tmpbg="$(mktemp)_screen.png";
# icon="$HOME/dots/lock.png"

scrot "$tmpbg"
convert "$tmpbg" -scale 10% -scale 1000% "$tmpbg"
# convert "$tmpbg" "$icon" -gravity center -composite -matte "$tmpbg"

i3lock -u -i "$tmpbg"
