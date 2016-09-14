#!/bin/bash
# a cd-betterizer

usage() {
    echo " Usage: $0 [-p] <dir>";
    exit $1;
}
finish() { ls -FH --color=auto; }

MKPARENT=0;
[[ "${1}" == "-p" ]] && {
    MKPARENT=1;
    shift;
}
test $# -eq 1 || usage 3;

if pushd "$1" >/dev/null 2>&1; then
    finish;
else
    case "$MKPARENT" in
        0)
            echo "Cannot access '${1}'";
            exit 1;
            ;;
        1)
            if mkdir -p "$1" >/dev/null 2>&1; then
                pushd "$1" >/dev/null;
                finish;
            else
                echo "Cannot make dir '${1}'";
                exit 2;
            fi
            ;;
    esac
fi
