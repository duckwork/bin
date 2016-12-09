#!/bin/bash

i=1;
# FUCKING INTERNET
until ping -c3 http://google.com; do 
    sleep 1.5;
    echo -n "$i ";
    let i+=1;
done;
clear;
echo "HOLY SHIT THE INTERNET"
notify-send "THE INTERNET" "HOLY FUCKING SHIT"
