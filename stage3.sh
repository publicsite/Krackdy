#!/bin/sh
#stage3 :- customises a vanilla rootfs

if [ "$1" = "" ]; then
	echo "Argv1: <arch>"
	echo "eg. \"i386\""
	exit
else
	THEARCH="$1"
fi

if [ "$(echo "$2" | cut -c 1-12)" != "linux-image-" ]; then
	echo "Argv2: the name of the kernel package for your architecture"
	echo "eg. \"linux-image-686\""
	exit
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

#fix permissions problems
chmod -Rv 700 /var/cache/apt/archives/partial/

chown -Rv _apt:root /var/cache/apt/archives/partial/

#add messagebus group
/usr/sbin/groupadd messagebus

export DEBIAN_FRONTEND=noninteractive
export LC_ALL=C
export LANG=C
export LANGUAGE=C

echo 'nameserver 1.1.1.1' > /etc/resolv.conf

apt update -y

#this stuff doesn't like chroots, so we get rid of it for the purposes of building
apt-get -y autoremove  exim4-config exim4-base exim4-daemon-light exim4-config-2 exim4

#update the system
apt-get -y upgrade

if [ "$THEARCH" = "i*86" ] || [ "$THEARCH" = "x86_64" ]; then
apt-get -m -y install grub-efi-ia32
fi

apt-get -m -y install efibootmgr \
systemd \
default-logind \
task-english \
alsa-utils \
live-config \
xdg-utils \
xorg \
xserver-xorg-input-all \
xserver-xorg-video-all \
va-driver-all \
pulseaudio \
pavucontrol \
gparted \
htop \
firmware-linux-free \
grub2 xorriso mtools \
busybox \
acl \
kodi kodi-game-libretro kodi-eventclients-kodi-send \
connman-gtk \
epiphany-browser onboard at-spi2-core openbox bluez-obexd python3-bluez bluez-firmware bluez \
libqt5webenginewidgets5 libqt5charts5 \
retroarch sakura \
mupen64plus-ui-console mupen64plus-video-all mupen64plus-rsp-all mupen64plus-input-all mupen64plus-audio-all \
gngb \
libslirp0 libpcap-dev

#transmission-gtk \

apt-get -m -y install --no-install-recommends \
"$2" \
console-setup-mini \
pciutils \
wget \
nano \
vim \
file \
iputils-ping \
locales \
whois \
telnet \
aptitude \
lsof \
time \
tnftp \
xserver-xorg-input-synaptics \
sudo \
fdisk \
less \
connman \
dns323-firmware-tools \
firmware-linux-free \
grub-firmware-qemu \
sigrok-firmware-fx2lafw \
amd64-microcode \
bluez-firmware \
dahdi-firmware-nonfree \
firmware-amd-graphics \
firmware-atheros \
firmware-bnx2 \
firmware-bnx2x \
firmware-brcm80211 \
firmware-cavium \
firmware-intel-sound \
firmware-iwlwifi \
firmware-libertas \
firmware-linux \
firmware-linux-nonfree \
firmware-misc-nonfree \
firmware-myricom \
firmware-netronome \
firmware-netxen \
firmware-qcom-media \
firmware-qlogic \
firmware-realtek \
firmware-samsung \
firmware-siano \
firmware-ti-connectivity \
firmware-zd1211 \
intel-microcode \
tzdata

#native linux games that use gamepad (list is 7 years old but nm)
apt-get -m -y install a7xpg \
dangen \
defendguin \
dodgindiamond2 \
dreamchess \
freedink \
jumpnbump \
marsshooter \
neverball \
neverputt \
noiz2sa \
pangzero \
parsec47 \
plee-the-bear \
powermanga \
rrootage \
seahorse-adventures \
solarwolf \
supertux \
tecnoballz \
xblast-tnt \
xjokes \
supertuxkart

##libretro stuff
#apt-get -m -y install \
#libretro-beetle-psx \
#libretro-bsnes \
#libretro-genesisplusgx \
#libretro-mame \
#libretro-mame2003 \
#libretro-mame2010 \
#libretro-mupen64plus-next \
#libretro-nestopia \
#libretro-mgba \
#libretro stella

echo "TYPE PASSWORD FOR USER: root"
passwd root

echo "TYPE PASSWORD FOR USER: kodi"
adduser kodi

gpasswd -a kodi sudo
/usr/sbin/groupadd power
gpasswd -a kodi power
gpasswd -a kodi users
gpasswd -a kodi bluetooth
gpasswd -a kodi plugdev
gpasswd -a kodi video
/usr/sbin/groupadd lpadmin
gpasswd -a kodi lpadmin

if [ -f "/etc/sudoers" ]; then
	if [ "$(grep "%users ALL = NOPASSWD:/usr/lib/${THEARCH}-linux-gnu/xfce4/session/xfsm-shutdown-helper" /etc/sudoers)" = "" ]; then

	echo "" >> /etc/sudoers
	echo "# Allow members of group sudo to execute any command" >> /etc/sudoers
	echo "%sudo   ALL=(ALL:ALL) ALL" >> /etc/sudoers
	echo "" >> /etc/sudoers
	echo "# Allow anyone to shut the machine down" >> /etc/sudoers
	echo "%users ALL = NOPASSWD:/usr/lib/${THEARCH}-linux-gnu/xfce4/session/xfsm-shutdown-helper" >> /etc/sudoers

	fi
else
	echo "" > /etc/sudoers
	echo "# Allow members of group sudo to execute any command" >> /etc/sudoers
	echo "%sudo   ALL=(ALL:ALL) ALL" >> /etc/sudoers
	echo "" >> /etc/sudoers
	echo "# Allow anyone to shut the machine down" >> /etc/sudoers
	echo "%users ALL = NOPASSWD:/usr/lib/${THEARCH}-linux-gnu/xfce4/session/xfsm-shutdown-helper" >> /etc/sudoers
fi

if [ -f "rootfs/usr/share/X11/xorg.conf.d/40-libinput.conf" ]; then
	#delete this because we will write to it
	if [ -f "rootfs/etc/X11/xorg.conf.d/40-libinput.conf" ]; then
	rm "rootfs/etc/X11/xorg.conf.d/40-libinput.conf"
	fi
	OLD_IFS="$IFS"
	IFS="$(printf "\n")"
	cat "rootfs/usr/share/X11/xorg.conf.d/40-libinput.conf" | while read line; do
		if [ "$line" = "        Identifier \"libinput touchpad catchall\"" ]; then
			echo "$line" >> "rootfs/etc/X11/xorg.conf.d/40-libinput.conf"
			echo "        Option \"Tapping\" \"on\"" >> "rootfs/etc/X11/xorg.conf.d/40-libinput.conf"
		else
			echo "$line" >> "rootfs/etc/X11/xorg.conf.d/40-libinput.conf"
		fi
	done
	IFS="$OLD_IFS"
fi

#for some reasons the permissions got changed once, so I set them here just to be safe
chown root:messagebus /usr/lib/dbus-1.0/dbus-daemon-launch-helper
chmod 4754 /usr/lib/dbus-1.0/dbus-daemon-launch-helper


chown -R kodi:kodi /home/kodi
chmod u+w /home/kodi

chmod 1777 /tmp

chmod 4755 /usr/bin/sudo
chmod 4755 /usr/bin/pkexec

#https://forums.debian.net/viewtopic.php?t=123694
systemctl set-default multi-user.target

sudo apt-get install -y patch

apt-get clean

cd /workdir
chown kodi:kodi "/workdir"
su kodi -c "/workdir/getEquiptmentHost.sh /workdir"
/workdir/installEquiptmentHost.sh /workdir

mkdir /home/kodi/AEL-ROMs

mkdir /home/kodi/AEL-ROMs/linux-native
cd /home/kodi/AEL-ROMs/linux-native
printf "/usr/games/a7xpg" > a7xpg.linux-native
printf "/usr/games/dangen" > dangen.linux-native
which defendguin > defendguin.linux-native
printf "/usr/games/dodgindiamond2" > dodgindiamond2.linux-native
printf "/usr/games/dreamchess" > dreamchess.linux-native
printf "/usr/games/freedink" > freedink.linux-native
printf "/usr/games/jumpnbump" > jumpnbump.linux-native
printf "/usr/games/marsshooter" > marsshooter.linux-native
printf "/usr/games/neverball" > neverball.linux-native
printf "/usr/games/neverputt" > neverputt.linux-native
printf "/usr/games/noiz2sa" > noiz2sa.linux-native
printf "/usr/games/pangzero" > pangzero.linux-native
printf "/usr/games/parsec47" > parsec47.linux-native
printf "/usr/games/plee-the-bear" > plee-the-bear.linux-native
printf "/usr/games/powermanga" > powermanga.linux-native
printf "/usr/games/rrootage" > rrootage.linux-native
printf "/usr/games/seahorse-adventures" > seahorse-adventures.linux-native
printf "/usr/games/solarwolf" > solarwolf.linux-native
printf "/usr/games/supertux2" > supertux.linux-native
printf "/usr/games/tecnoballz" > tecnoballz.linux-native
printf "/usr/games/xblast-tnt" > xblast-tnt.linux-native
which xjokes > xjokes.linux-native
printf "/usr/games/supertuxkart" > supertuxkart.linux-native

mkdir /home/kodi/AEL-ROMs/microsoft-og-xbox
mkdir /home/kodi/AEL-ROMs/atari-2600
mkdir /home/kodi/AEL-ROMs/sony-psx
mkdir /home/kodi/AEL-ROMs/sega-genesis
mkdir /home/kodi/AEL-ROMs/nintendo-snes
mkdir /home/kodi/AEL-ROMs/nintendo-n64
mkdir /home/kodi/AEL-ROMs/nintendo-nes
mkdir /home/kodi/AEL-ROMs/gameboy
mkdir /home/kodi/AEL-ROMs/gameboy-colour
mkdir /home/kodi/AEL-ROMs/gameboy-advance
mkdir /home/kodi/AEL-ROMs/mame

mkdir /home/kodi/AEL-assets
mkdir /home/kodi/AEL-assets/linux-native
mkdir /home/kodi/AEL-assets/microsoft-og-xbox
mkdir /home/kodi/AEL-assets/atari-2600
mkdir /home/kodi/AEL-assets/sony-psx
mkdir /home/kodi/AEL-assets/sega-genesis
mkdir /home/kodi/AEL-assets/nintendo-snes
mkdir /home/kodi/AEL-assets/nintendo-n64
mkdir /home/kodi/AEL-assets/nintendo-nes
mkdir /home/kodi/AEL-assets/gameboy
mkdir /home/kodi/AEL-assets/gameboy-colour
mkdir /home/kodi/AEL-assets/gameboy-advance
mkdir /home/kodi/AEL-assets/mame


chown -R kodi:kodi /home/kodi/AEL-ROMs
chown -R kodi:kodi /home/kodi/AEL-assets

rm /etc/resolv.conf
rm -rf /tmp/*

if [ -f "/root/.bash_history" ]; then 
	rm /root/.bash_history
fi

#unmount stuff
umount /proc
umount /sys
umount /dev/pts
