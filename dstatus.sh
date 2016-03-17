sep="│";

datetime() {
  while true; do
    datetime="$(date +'%a %H:%M')";
    sleep 40;
  done
}

battery() {
  while true; do
    if [[ $(cat /sys/class/power_supply/AC/online) == '0' ]]; then
      # on battery power
      bnow=$(cat /sys/class/power_supply/BAT0/energy_now);
      bful=$(cat /sys/class/power_supply/BAT0/energy_full_design);
      bat="$(echo "scale=2;$bnow / $bful" | bc)";
      case "${bat#?}" in
        9[0-9]*) bat="$(printf '\uE254')" ;;
        8[0-9]*) bat="$(printf '\uE253')" ;;
        7[0-9]*) bat="$(printf '\uE252')" ;;
        6[0-9]*) bat="$(printf '\uE251')" ;;
        5[0-9]*) bat="$(printf '\uE250')" ;;
        4[0-9]*) bat="$(printf '\uE24F')" ;;
        3[0-9]*) bat="$(printf '\uE24E')" ;;
        2[0-9]*) bat="$(printf '\uE24D')" ;;
        1[0-9]*) bat="$(printf '\uE24C')" ;;
        *)       bat="$(printf '\uE242')" ;;
      esac
      bat="${bat} ${sep}"
    else
      # on AC
      bat="";
    fi
    sleep 30;
  done
}

# # Spin them up
# battery; 
# datetime;

# # Put them on the bar
# while true; do
#   xsetroot -name "$battery" "$datetime";
# done
