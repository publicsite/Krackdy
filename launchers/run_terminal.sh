#!/bin/sh
#
# Wrapper script to run terminal emulator from kodi
#

# --- Stop KODI ---
echo "Stopping Kodi service ..."
kodi-send --action="Quit"

# --- Run mupen64 ---
echo "Running onscreen keyboard"
onboard &
echo "Running sakura ..."
sakura
sleep 3

# --- Start KODI ---
echo "Starting Kodi service ..."
kodi &

#close onscreen keyboard
kill $(ps ax | grep "onboard" | grep -v "grep" | head -n 1 | tr -s ' ' | cut -d ' ' -f2)
