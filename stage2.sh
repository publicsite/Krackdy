#!/bin/sh
#stage2 :- debootstraps a vanilla rootfs for the appropriate architecture

#enter directory containing this script
cd $(dirname $(realpath $0))

if [ "$1" = "" ]; then
	echo "Argv1: <arch>"
	echo "eg. \"i386\""
	exit
else
	THEARCH="$1"
fi

#we mount the stuff for apt
mount none -t proc /proc
mount none -t sysfs /sys
mkdir -p /dev/pts
mount none -t devpts /dev/pts


#create /dev/null and /dev/zero
rm /dev/null
rm /dev/zero
mknod -m 666 /dev/null c 1 3
mknod -m 666 /dev/zero c 1 5
mknod -m 666 /dev/random c 1 8
mknod -m 666 /dev/urandom c 1 9
chown root:root /dev/null /dev/zero /dev/random /dev/urandom

#create /dev/null and /dev/zero

#fix for git's sake
export TMPDIR="/tmp/"
if [ ! -d "${TMPDIR}" ]; then 
mkdir "${TMPDIR}"

fi

chown root:root "${TMPDIR}"
chmod 1777 "${TMPDIR}"

#fix sudoers
	echo "" >> /etc/sudoers
	echo "# Allow members of group sudo to execute any command" >> /etc/sudoers
	echo "%sudo   ALL=(ALL:ALL) ALL" >> /etc/sudoers
	echo "" >> /etc/sudoers
	echo "# Allow anyone to shut the machine down" >> /etc/sudoers
	echo "%users ALL = NOPASSWD:/usr/lib/${THEARCH}-linux-gnu/xfce4/session/xfsm-shutdown-helper" >> /etc/sudoers



#fix permissions problems
chmod -Rv 700 /var/cache/apt/archives/partial/

chown -Rv root:root /var/cache/apt/archives/partial/

THEMIRROR="http://ftp.debian.org/debian/"

mkdir "${PWD}/rootfs"

apt-get update

apt-get install -m -y debootstrap

#for u-boot
apt-get -m -y install build-essential bison flex libssl-dev

#for efilinux
apt-get -m -y install gnu-efi

#to restore permissions
apt-get -m -y install acl

###for dooble
##apt-get -m -y install make g++ qt5-qmake qtbase5-dev libqt5charts5 libqt5charts5-dev libqt5qml5 libqt5webenginewidgets5 qtwebengine5-dev libqt5webengine5 qtwebengine5-dev-tools
###for tianocore
##apt-get -m -y install uuid-dev python3 python-is-python3 nasm

debootstrap --arch=${THEARCH} --variant=minbase --components=main,contrib,non-free-firmware --include=ifupdown testing "${PWD}/rootfs" "${THEMIRROR}"

printf "deb %s testing main contrib non-free-firmware\n" "${THEMIRROR}" > rootfs/etc/apt/sources.list
printf "deb-src %s testing main contrib non-free-firmware\n" "${THEMIRROR}" >> rootfs/etc/apt/sources.list

printf "krackedy-iso\n" > "rootfs/etc/hostname"
chmod 644 "rootfs/etc/hostname"
chown root:root "rootfs/etc/hostname"

printf "127.0.0.1\tlocalhost\n" > "rootfs/etc/hosts"
printf "127.0.1.1\tlive-hybrid-iso\n" >> "rootfs/etc/hosts"
printf "::1\t\tlocalhost ip6-localhost ip6-loopback\n" >> "rootfs/etc/hosts"
printf "ff02::1\t\tip6-allnodes\n" >> "rootfs/etc/hosts"
printf "ff02::2\t\tip6-allrouters\n" >> "rootfs/etc/hosts"
chmod 644 "rootfs/etc/hosts"
chown root:root "rootfs/etc/hosts"

#for xemu
apt-get install -y libslirp-dev unzip libglu1-mesa libegl-mesa0 libglib2.0-dev pkg-config git build-essential libsdl2-dev libepoxy-dev libpixman-1-dev libgtk-3-dev libssl-dev libsamplerate0-dev libpcap-dev ninja-build python3-yaml libslirp-dev

#for libretro cores
apt-get install -y libavutil-dev libavcodec-dev libavformat-dev libswresample-dev libswscale-dev

thepwd="$PWD"
cd /usr/lib/x86_64-linux-gnu
sudo ln -sf libGLU.so.1 libGLU.so
cd "$thepwd"

#for kodi game

sudo apt-get install -y cmake kodi-addons-dev

##run build scripts in the outer rootfs
echo "SET PASSWORD FOR USER BUILD"
adduser kodi
su kodi -c "/workdir/getEquiptmentBuild.sh /workdir"
/workdir/installEquiptmentBuild.sh /workdir

#unmount stuff
umount /proc
umount /sys
umount /dev/pts