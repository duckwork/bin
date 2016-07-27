#!/usr/bin/env dash

wallfile="${XDG_DATA_HOME:-$HOME/.local/share}/wallpaper.jpg"

curl -fLo "$wallfile" \
    http://source.unsplash.com/random/1366x768

[ $? -eq 0 ] && hsetroot -full $wallfile;
