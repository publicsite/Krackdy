#!/bin/sh
#
# Wrapper script to run Mupen64 from kodi
#

# --- Stop KODI ---
echo "Stopping Kodi service ..."
kodi-send --action="Quit"
sleep 3

# --- Run mupen64 ---
echo "Running pcsxr ..."
if [ "$(printf "%s" "${1}" | rev | cut -d '.' -f 1)" = "rar" ]; then 
mkdir -p /tmp/pcsxrExtract
unrar x "${1}" /tmp/pcsxrExtract
theimage="$(find /tmp/pcsxrExtract -type f -name "*.mdf" | head -n 1)"
if [ "$theimage" = "" ]; then
theimage="$(find /tmp/pcsxrExtract -type f -name "*.bin" | head -n 1)"
fi
if [ "$theimage" = "" ]; then
theimage="$(find /tmp/pcsxrExtract -type f -name "*.img" | head -n 1)"
fi
pcsxr -cdfile "${theimage}"
rm -rf /tmp/pcsxrExtract
fi
sleep 3

# --- Start KODI ---
echo "Starting Kodi service ..."
kodi -fs &
