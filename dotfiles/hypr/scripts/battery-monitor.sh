#!/usr/bin/env bash

BAT=$(command ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n 1)
if [[ -z "$BAT" ]]; then
    exit 0
fi

NOTIFIED_20=false
NOTIFIED_15=false
NOTIFIED_5=false
NOTIFIED_3=false

while true; do
    CAPACITY=$(cat "$BAT/capacity")
    STATUS=$(cat "$BAT/status")

    if [[ "$STATUS" == "Discharging" ]]; then
        # Critical: 3% - Initiate emergency shutdown
        if [[ $CAPACITY -le 3 && $NOTIFIED_3 == false ]]; then
            notify-send -u critical "EMERGENCY: Battery Critical - Shutting Down" "Battery at ${CAPACITY}% - System will shutdown NOW to prevent data loss!"
            sleep 5  # Give user 5 seconds to see the notification
            systemctl poweroff
            NOTIFIED_3=true
        # Critical: 5% - Final warning to save work
        elif [[ $CAPACITY -le 5 && $CAPACITY -gt 3 && $NOTIFIED_5 == false ]]; then
            notify-send -u critical "CRITICAL: Battery Extremely Low!" "Only ${CAPACITY}% remaining - SAVE YOUR WORK AND PLUG IN NOW! System will shutdown at 3%."
            NOTIFIED_5=true
        # Warning: 15% - Low battery
        elif [[ $CAPACITY -le 15 && $CAPACITY -gt 5 && $NOTIFIED_15 == false ]]; then
            notify-send -u critical "Battery Low" "Remaining: ${CAPACITY}% - Please plug in soon"
            NOTIFIED_15=true
        # Info: 20% - Battery getting low
        elif [[ $CAPACITY -le 20 && $CAPACITY -gt 15 && $NOTIFIED_20 == false ]]; then
            notify-send -u normal "Battery Low" "Remaining: ${CAPACITY}%"
            NOTIFIED_20=true
        # Reset notifications when battery is charging or above 20%
        elif [[ $CAPACITY -gt 20 ]]; then
            NOTIFIED_20=false
            NOTIFIED_15=false
            NOTIFIED_5=false
            NOTIFIED_3=false
        fi
    else
        # Reset all notifications when plugged in
        NOTIFIED_20=false
        NOTIFIED_15=false
        NOTIFIED_5=false
        NOTIFIED_3=false
    fi

    sleep 60
done
