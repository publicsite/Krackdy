#!/bin/sh
#
# Wrapper script to run Mupen64 from kodi
#

# --- Stop KODI ---
echo "Stopping Kodi service ..."
kodi-send --action="Quit"
sleep 3

# --- Run OG xemu ---
echo "Running xemu ..."
xemu -dvd_path "${1}" -fullscreen
sleep 3

# --- Start KODI ---
echo "Starting Kodi service ..."
kodi &