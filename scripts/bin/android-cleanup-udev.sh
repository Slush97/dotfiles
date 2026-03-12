#!/usr/bin/env bash
# Wrapper called by udev — runs cleanup in background after device connects
# udev rules run as root with no user environment, so we need to set things up

export HOME=/home/esoc
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Wait a moment for ADB to recognize the device
sleep 5

sudo -u esoc /home/esoc/bin/android-cleanup.sh >> /tmp/android-cleanup.log 2>&1
