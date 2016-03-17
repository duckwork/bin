#!/bin/bash

# If not running X, exit (TODO: make it work w/o X!)
[[ -z $DISPLAY ]] && echo "No display!" && exit 3

bmks="$XDG_CONFIG_HOME/surf/bookmarks";
hist="$XDG_DATA_HOME/surf/history";
xidf="/tmp/tabbed-surf.xid";
sdir="$XDG_DATA_HOME/surf/sessions";
DMENU="dmenu -i -l 10 -sf #8eb2a4";

for f in $bmks $hist; do
  [[ -f $f ]] || touch $f;
done
[[ -d $sdir ]] || mkdir -p $sdir;

function rawurlencode
{ # <string>
  local str="$(sed 's/^[ 	]\+//' <<<$1)"
  local strlen="${#str}"
  local encoded=""
  local pos c o

  for (( pos=0; pos<strlen; pos++ )); do
    c=${str:$pos:1}
    case "$c" in
      [-_.~a-zA-Z0-9]) o="${c}" ;;
      *) printf -v o '%%%02x' "'$c" ;;
    esac
    encoded="${encoded}${o}"
  done
  echo "${encoded}"
}

function uri
{ # <uri>
  u="$@";
  [[ -z "$u" ]] && return 1
  ur='((https?|ftp|file)://)?[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*\.[-A-Za-z0-9\+&@#/%=~_|]'
  if [[ "${u}" =~ $ur ]]; then
    echo "$u";
  else
    echo "${u}" >>$hist;
    echo "http://www.duckduckgo.com/?q=$(rawurlencode "${u}")"
  fi
}

function clean_hist
{
  grep -v 'duckduckgo.com' "$hist" >/tmp/surfhist && \
      mv /tmp/surfhist "$hist";
  grep -v 'about:blank' "$hist" >/tmp/surfhist && \
      mv /tmp/surfhist "$hist";
}

function expose_files
{
  cat "$bmks";
  sort "$hist" | uniq -c | sort -rh \
    | sed 's/^.*[0-9]\+ //' | grep -v 'duckduckgo.com';
}

function expose_tabs
{ # <xid>
  xwininfo -children -id $1 \
    | grep '^     0x' \
    | sed -e's@^ *\(0x[0-9a-f]*\) "\([^"]*\)".*@__tab: \1 \2@'
}

function contains
{ # <item> <array>
  local e
  for e in "${@:2}"; do
    [[ "$e" == "$1" ]] && return 0;
  done
  return 1;
}

function runtabbed
{ # <xidfile> <uri>
  tabbed -cdn tabbed-surf -r 2 surf -e '' "$2" > "$1" 2>/dev/null &
}

function new_surf
{ # <uri>
  u="$(uri "$@")"
  if [[ ! -r "$xidf" ]]; then
    runtabbed $xidf "${u}"
  else
    xid=$(cat "$xidf")
    if ! xprop -id "$xid" >/dev/null 2>&1; then
      runtabbed $xidf "${u}"
    else
      surf -e "$xid" "${u}" >/dev/null 2>&1 &
    fi
   xdo activate "$xid"
  fi
}

function tab_select
{ # <xid>
  p="$( ( expose_tabs "$1" \
        && expose_files \
        ) | $DMENU -p ://)";
  [ $? -ne 0 ] && exit $?;
  if [[ "$p" =~ ^0x ]]; then
    # Set tabbed _TABBED_SELECT_TAB property
    xprop -id "$1" -f _TABBED_SELECT_TAB 8s -set _TABBED_SELECT_TAB "${p%% }";
  else
    new_surf "$p";
  fi
}

function save_session
{ # <xid> <file>
  touch "$2";
  xwininfo -children -id "$1" \
    | awk '/     0x/{print $1}' \
    | xargs -n1 xprop -id \
    | grep _SURF_URI | sed 's/^.* = "\(.*\)"$/\1/' \
    >> "$2"
}

function load_session
{ # <file>
  cat "$1" | \
    while read line; do
      new_surf "$line";
      sleep 0.25; # otherwise they won't attach right
    done
}

function replace_session
{ # <xid> <session>
    xwininfo -children -id "$1" | awk '/^     0x/{print $1}' \
      >> /tmp/surf.killlist;
    load_session "$2";
    cat /tmp/surf.killlist | while read win; do
      xdo kill $win;
    done
    rm /tmp/surf.killlist;
}

function set_surf_prop
{ # <xid> <get_prop> <set_prop>
  prop="$( ( xprop -id $1 $2 \
           | sed "s/^$2(STRING) = \(\"\?\)\(.*\)\1$/\2/" \
           | xargs -0 printf %b \
           && expose_files \
           ) | $DMENU -p ://)" && prop="$(uri "${prop}")";
  [[ $? == 0 ]] && xprop -id $1 -f $3 8s -set $3 "${prop}"
}

# MAIN
case "$1" in
  '-setprop')
    shift;
    set_surf_prop $@;
    ;;
  '-tab')
    shift;
    tab_select "$1";
    ;;
  '-addhist')
    shift;
    echo "$@" >> "$hist";
    ;;
  '-dmenu')
    u="$(expose_files | $DMENU -p ://)";
    [ $? -ne 0 ] && exit $?;
    new_surf "$u";
    ;;
  '-c')
    clean_hist && echo "History cleaned.";
    ;;
  '-ssave')
    shift;
    s="$(ls -1 $sdir | $DMENU -p Ssave:)";
    save_session $1 "${sdir}/${s// /==}";
    ;;
  '-sload')
    shift;
    s="$(ls -1 $sdir | sed 's/==/ /g' | $DMENU -p Sload:)";
    if pgrep -x tabbed >/dev/null; then
      replace_session "$(cat $xidf)" "${sdir}/${s// /==}";
    else
      load_session "${sdir}/${s// /==}";
    fi
    ;;
  '-sc')
    rm ${sdir}/* && echo "Sessions cleared.";
    ;;
  *) 
    new_surf "$@"
    ;;
esac
