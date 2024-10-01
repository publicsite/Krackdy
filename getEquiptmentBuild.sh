#!/bin/sh

#myBuild options

#environment variables
export myBuildHome="$1"
export myBuildHelpersDir="${myBuildHome}/helpers"
export myBuildSourceDest="${myBuildHome}/sourcedest"
export myBuildExtractDest="${myBuildHome}/extractdest"
export myBuildsDir="${myBuildHome}/myBuildsBuild"

mkdir "$myBuildSourceDest"
mkdir "$myBuildExtractDest"

export J="-j12"

#this would be for binutils search paths, but i am playing my luck to see if i can go without it
#ld --verbose | grep SEARCH_DIR | tr -s ' ;' \\012
export BITS='32'

#architecture='x86' #the architecture of the target (used for building a kernel)
#export architecture

export TARGET="$(gcc -v 2>&1 | grep "^Target: " | cut -c 9-)" #the toolchain we're creating
export BUILD="$(gcc -v 2>&1 | grep "^Target: " | cut -c 9-)" #the toolchain we're compiling from, can be found by reading the "Target: *" field from "gcc -v", or "gcc -v 2>&1 | grep Target: | sed 's/.*: //" for systems with grep and sed

export SYSROOT="${myBuildHome}/rootfs" #the root dir

mkdir "$SYSROOT"

export TEMP_SYSROOT="/"

export PREFIX='/usr' #the location to install to

###	get the programs	###

"${myBuildsDir}/xemu/xemu.myBuild" get
"${myBuildsDir}/xemu/xemu.myBuild" extract
"${myBuildsDir}/xemu/xemu.myBuild" build

"${myBuildsDir}/libretro-super/libretro-super.myBuild" get
"${myBuildsDir}/libretro-super/libretro-super.myBuild" extract
"${myBuildsDir}/libretro-super/libretro-super.myBuild" build

##"${myBuildsDir}/game.libretro.mupen64plus-nx/game.libretro.mupen64plus-nx.myBuild" get
##"${myBuildsDir}/game.libretro.mupen64plus-nx/game.libretro.mupen64plus-nx.myBuild" extract
##"${myBuildsDir}/game.libretro.mupen64plus-nx/game.libretro.mupen64plus-nx.myBuild" build
