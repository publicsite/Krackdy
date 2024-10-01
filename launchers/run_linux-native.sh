#!/bin/sh
#
# Wrapper script to run native linux game from kodi
#

# --- Stop KODI ---
echo "Stopping Kodi service ..."
kodi-send --action="Quit"
sleep 3

# --- Run native game ---
echo "Running native game $1 ..."
$(cat "$1")
sleep 3

# --- Start KODI ---
echo "Starting Kodi service ..."
kodi &