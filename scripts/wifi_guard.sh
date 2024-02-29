#!/usr/bin/env bash
# Ensure wifi remains connected even when it randomly drops intermittently

set -euo pipefail

WIFI_SSID=${WIFI_SSID:-'CENTCOM-5G'}

get_current_ssid(){
    networksetup -getairportnetwork en0 | cut -d: -f2 | xargs
}

set_current_ssid(){
    ssid=$1
    networksetup -setairportnetwork en0 "$ssid"
}

guard(){
    ssid=$(get_current_ssid)
    if [ "$ssid" != "$WIFI_SSID" ]; then
        set_current_ssid "$WIFI_SSID"
        printf x
    else
        printf .
    fi
    sleep 1
}

while true; do guard; done
