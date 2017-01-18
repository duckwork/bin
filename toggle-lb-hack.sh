#/bin/sh

panel=lemonbar;

if pgrep $panel; then
    killall $panel; 
    xmonadctl unset-struts;
else
    xmonadctl set-struts; 
    xmonad --restart;
fi
