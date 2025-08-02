#!/bin/sh
#
# Wrapper script to run connection manager from kodi
#

# --- Stop KODI ---
echo "Stopping Kodi service ..."
kodi-send --action="Quit"

# --- Run connman ---
echo "Running antimicrox ..."
antimicrox --hidden
echo "Running on-screen keyboard ..."
onboard &
echo "Running connman ..."
connman-gtk --no-icon
sleep 3

#close antimicrox
kill $(ps ax | grep "antimicrox" | grep -v "grep" | head -n 1 | tr -s ' ' | cut -d ' ' -f2)

#close onscreen keyboard
kill $(ps ax | grep "onboard" | grep -v "grep" | head -n 1 | tr -s ' ' | cut -d ' ' -f2)

# --- Start KODI ---
echo "Starting Kodi service ..."
kodi -fs &
