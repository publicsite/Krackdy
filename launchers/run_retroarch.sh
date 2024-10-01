#!/bin/sh
#
# Wrapper script to run Retroarch in LibreELEC
#
RETROARCH_EXECUTABLE="/home/kodi/bin/retroarch"
LIBRETRO_CORES_DIR="/home/kodi/bin/libretro/"

# --- Stop KODI ---
echo "Stopping Kodi service ..."
kodi-send --action="Quit"
sleep 3

# --- Run retroarch ---
echo "Running Retroarch ..."
$RETROARCH_EXECUTABLE -L $LIBRETRO_CORES_DIR/$1_libretro.so -f -v "$2"
sleep 3

# --- Start KODI ---
echo "Starting Kodi service ..."
kodi &
