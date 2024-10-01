#!/bin/sh
#
# Wrapper script to run Mupen64 from kodi
#

# --- Stop KODI ---
echo "Stopping Kodi service ..."
kodi-send --action="Quit"
sleep 3

# --- Run mupen64 ---
echo "Running Mupen64 ..."
stella -fullscreen 1 "${1}"
sleep 3

# --- Start KODI ---
echo "Starting Kodi service ..."
kodi &
