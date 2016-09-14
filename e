#!/bin/bash
# an editor-betterizer

_editor="${EDITOR:-/usr/bin/vim}";
for file in $@;
do
    if ! [ -f "$file" ]; then
        continue;
    else
        if ! [ -w "$file" ]; then
            local editor="/usr/bin/sudoedit";
            break;
        fi;
    fi;
done;
editor=${editor:-$_editor};
$editor $@
