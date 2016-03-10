#!/bin/bash

# If not running X, exit (TODO: make it work w/o X!)
[[ -z $DISPLAY ]] && echo "No display!" && exit 3

bmks="${SURF_BMARKS:-$XDG_CONFIG_HOME/surf/bookmarks}"
hist="${SURF_HISTORY:-$XDG_DATA_HOME/surf/history}"
srch="${SURF_SEARCH_HISTORY:-$XDG_DATA_HOME/surf/search_history}"
DMENU="dmenu -l 10 -p ://"

for f in $bmks $hist $srch; do
  [[ -f $f ]] || touch $f;
done

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
    echo "${u}" >>$srch;
    echo "http://www.duckduckgo.com/?q=$(rawurlencode "${u}")"
  fi
}

function clean_files
{
  sed '/duckduckgo.com/d' "$hist" >/tmp/shist && \
      mv /tmp/shist "$hist";
  sed '/^[ 	]/d' "$srch" >/tmp/hsrch && \
      mv /tmp/hsrch "$srch";
}

function expose
{ # <files...>
  cat "$@" | sort | uniq -c | sort -r | sed 's/ \+[0-9]\+ \+//';
}

function runtabbed
{ # <xidfile> <uri>
  tabbed -cdn tabbed-surf -r 2 surf -e '' "$2" > "$1" 2>/dev/null &
}

function new_surf
{ # <uri>
  xidfile="/tmp/tabbed-surf.xid"
  u="$(uri "$@")"
  if [[ ! -r "$xidfile" ]]; then
    runtabbed $xidfile "${u}"
  else
    xid=$(cat "$xidfile")
    if ! xprop -id "$xid" >/dev/null 2>&1; then
      runtabbed $xidfile "${u}"
    else
      surf -e "$xid" "${u}" >/dev/null 2>&1 &
    fi
   xdo activate --sync "$xid"
  fi
}

function mod_surf
{ # <xid> <get_prop> <set_prop>
  prop="$( ( xprop -id $1 $2 \
           | sed "s/^$2(STRING) = \(\"\?\)\(.*\)\1$/\2/" \
           | xargs -0 printf %b \
           && expose $bmks $hist $srch \
           ) | $DMENU )" && prop="$(uri "${prop}")";
  [[ $? == 0 ]] && xprop -id $1 -f $3 8s -set $3 "${prop}"
}

# MAIN
case "$1" in
  '-setprop')
    shift;
    mod_surf $@ && exit 0;
    ;;
  '-dmenu')
    uri="$(expose $bmarks $hist $srch | $DMENU)";
    [ $? -ne 0 ] && exit $?;
    new_surf "$uri";
    ;;
  '-cf') clean_files ;;
  *) new_surf "$@" ;;
esac
