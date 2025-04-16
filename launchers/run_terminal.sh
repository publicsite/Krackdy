#!/bin/sh
#
# Wrapper script to run terminal emulator from kodi
#

# --- Stop KODI ---
echo "Stopping Kodi service ..."
kodi-send --action="Quit"

# --- Run terminal emulator ---
echo "Running antimicrox ..."
antimicrox --hidden
echo "Running onscreen keyboard"
onboard &
echo "Running terminal emulator ..."
xfce4-terminal
sleep 3

#close antimicrox
kill $(ps ax | grep "antimicrox" | grep -v "grep" | head -n 1 | tr -s ' ' | cut -d ' ' -f2)

#close onscreen keyboard
kill $(ps ax | grep "onboard" | grep -v "grep" | head -n 1 | tr -s ' ' | cut -d ' ' -f2)

# --- Start KODI ---
echo "Starting Kodi service ..."
kodi &
