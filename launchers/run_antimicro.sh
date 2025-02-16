#!/bin/sh
#
# Wrapper script to run connection manager from kodi
#

# --- Stop KODI ---
echo "Stopping Kodi service ..."
kodi-send --action="Quit"

# --- Run antimicro ---
echo "Running on-screen keyboard"
onboard &
echo "Running antimicro GUI ..."
antimicrox
sleep 3

#close onscreen keyboard
kill $(ps ax | grep "onboard" | grep -v "grep" | head -n 1 | tr -s ' ' | cut -d ' ' -f2)

# --- Start KODI ---
echo "Starting Kodi service ..."
kodi &

