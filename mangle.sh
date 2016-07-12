#!/bin/bash
# from /u/gottabeme

if [[ $1 =~ [0-9]+ ]]; then
    section=$1;
    shift;
fi

args=("$@");
while ! command man -w $(echo "${args[@]}" | tr " " "-") &>/dev/null; do
    patterns+=( ${args[-1]} );
    unset args[-1];
done

if [[ ${patterns[@]} ]]; then
# TODO: change `less -RFX` to $PAGER after finding out what RFX does
    grepCommand="| grep -i -C4 --color=always -- ${patterns[@]} | less -RFX";
else
    grepCommand="| less -RFX";
fi

eval "command man $section ${args[@]} $grepCommand";
