#!/bin/bash

if [[ "$1" == "exit" ]]; then
    echo ":: Exit"
    sleep 1
    killall -9 Hyprland 
    sleep 2
fi

if [[ "$1" == "lock" ]]; then
    echo ":: Lock"
    sleep 1
    hyprlock    
fi

if [[ "$1" == "reboot" ]]; then
    echo ":: Reboot"
    sleep 1
    systemctl reboot
fi

if [[ "$1" == "shutdown" ]]; then
    echo ":: Shutdown"
    sleep 1
    systemctl poweroff
fi

if [[ "$1" == "suspend" ]]; then
    echo ":: Suspend"
    sleep 1
    systemctl suspend    
fi

if [[ "$1" == "hibernate" ]]; then
    echo ":: Hibernate"
    sleep 1
    systemctl hibernate    
fi
