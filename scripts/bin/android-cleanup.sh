#!/usr/bin/env bash
# android-cleanup.sh — run after every phone reboot to kill telemetry/bloat
# Usage: ./android-cleanup.sh
# Auto-run: triggered by udev when phone connects (see /etc/udev/rules.d/99-android-cleanup.rules)

set -euo pipefail

DEVICE="75f408ba"

wait_for_device() {
    echo "[*] Waiting for device to be ready..."
    adb -s "$DEVICE" wait-for-device
    # Wait for boot to complete
    until [ "$(adb -s "$DEVICE" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ]; do
        sleep 2
    done
    echo "[*] Device ready."
}

disable_pkg() {
    local pkg="$1"
    result=$(adb -s "$DEVICE" shell pm disable-user --user 0 "$pkg" 2>&1)
    echo "  [disable] $pkg → $result"
}

restrict_pkg() {
    local pkg="$1"
    adb -s "$DEVICE" shell am set-standby-bucket "$pkg" restricted 2>/dev/null
    adb -s "$DEVICE" shell am force-stop "$pkg" 2>/dev/null
    echo "  [restrict+stop] $pkg"
}

clear_accessibility() {
    adb -s "$DEVICE" shell settings delete secure enabled_accessibility_services 2>/dev/null
    echo "  [cleared] accessibility services"
}

echo "=== Android Cleanup ==="

wait_for_device

echo ""
echo "[1] Clearing accessibility services (screen readers/overlays)..."
clear_accessibility

echo ""
echo "[2] Disabling telemetry packages..."
disable_pkg com.wikibuy.prod.main
disable_pkg com.qualcomm.qti.devicestatisticsservice
disable_pkg com.google.android.adservices.api
disable_pkg com.oplus.athena
disable_pkg com.oplus.obrain
disable_pkg com.oplus.dmp

echo ""
echo "[3] Restricting social media background activity..."
restrict_pkg com.facebook.katana
restrict_pkg com.instagram.android
restrict_pkg com.twitter.android
restrict_pkg com.linkedin.android

echo ""
echo "[4] Killing OnePlus analytics (protected, can't fully disable)..."
restrict_pkg com.oplus.aiunit
restrict_pkg com.oplus.cosa

echo ""
echo "[5] Killing Microsoft Phone Link screen mirror..."
restrict_pkg com.microsoft.appmanager

echo ""
echo "=== Done ==="
