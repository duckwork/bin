#!/bin/bash

# package query (find)

pacman -Ss "$@" || echo "Nothing in repos." >/tmp/pq
cower -s "$@"   || echo "Nothing in aur."  >>/tmp/pq

[[ -f /tmp/pq ]] && cat /tmp/pq && rm /tmp/pq && exit 1

exit 0
