#!/bin/sh
#stage1 :- downloads a iso and extracts the root filesystem, then runs the later stages.

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

#to extract rootfs from iso
sudo apt-get -y install squashfs-tools

#enter directory containing this script
cd $(dirname $(realpath $0))

thepwd="${PWD}"

wget "https://jenkins.linuxcontainers.org/job/image-debian/architecture=amd64,release=trixie,variant=default/3190/artifact/rootfs.tar.xz"
sudo mkdir "${thepwd}/mountpoint"
cd mountpoint
sudo tar -xf ../rootfs.tar.xz
cd ..

#create /etc/resolv.conf for the outer rootfs
sudo rm "${thepwd}/mountpoint/etc/resolv.conf"
cat /etc/resolv.conf | sudo tee "${thepwd}/mountpoint/etc/resolv.conf"

#copy build scripts to the outer rootfs
sudo cp -a "${thepwd}/myBuildsBuild" "${thepwd}/mountpoint/workdir"
sudo cp -a "${thepwd}/helpers" "${thepwd}/mountpoint/workdir"
sudo cp -a "${thepwd}/getEquiptmentBuild.sh" "${thepwd}/mountpoint/workdir"
sudo cp -a "${thepwd}/installEquiptmentBuild.sh" "${thepwd}/mountpoint/workdir"
sudo chmod +x "${thepwd}/mountpoint/workdir/getEquiptmentBuild.sh"
sudo chmod +x "${thepwd}/mountpoint/workdir/installEquiptmentBuild.sh"

##stage 2 - run stage two in the outer rootfs
##sudo mkdir "${thepwd}/mountpoint/workdir"
sudo cp -a stage2.sh "${thepwd}/mountpoint/workdir/"
chmod +x "${thepwd}/mountpoint/workdir/stage2.sh"
sudo chroot "${thepwd}/mountpoint" /workdir/stage2.sh "${THEARCH}"

#FIXME: install xemu within this script!#sudo chroot ${thepwd}/mountpoint /workdir/installEquiptmentBuild.sh /workdir

sudo mkdir -p "${thepwd}/mountpoint/workdir/rootfs/workdir"
##sudo chroot "${thepwd}/mountpoint/workdir/rootfs" chown kodi:kodi "${thepwd}/mountpoint/workdir/rootfs/workdir"

#copy some config files to /etc/skel in the inner rootfs
sudo mkdir -p "${thepwd}/mountpoint/workdir/rootfs/etc/skel/Desktop"
sudo mkdir -p "${thepwd}/mountpoint/workdir/rootfs/etc/skel/.config"
#FIXME: xinitrc#sudo cp -a "${thepwd}/.xinitrc" "${thepwd}/mountpoint/workdir/rootfs/etc/skel/"
#FIXME sudo chmod 700 "${thepwd}/mountpoint/workdir/rootfs/etc/skel/.xinitrc"
sudo cp -a "${thepwd}/.xinitrc" "${thepwd}/mountpoint/workdir/rootfs/etc/skel/"
sudo cp -a "${thepwd}/.profile" "${thepwd}/mountpoint/workdir/rootfs/etc/skel/"
sudo chmod 700 "${thepwd}/mountpoint/workdir/rootfs/etc/skel/.xinitrc"
sudo chmod 700 "${thepwd}/mountpoint/workdir/rootfs/etc/skel/.profile"
sudo ln -s .xinitrc "${thepwd}/mountpoint/workdir/rootfs/etc/skel/.xsession"
sudo chmod 700 "${thepwd}/mountpoint/workdir/rootfs/etc/skel/.xsession" "${thepwd}/mountpoint/workdir/rootfs/etc/skel/.xinitrc"
sudo mkdir -p "${thepwd}/mountpoint/workdir/rootfs/etc/skel/.config/gtk-3.0"
sudo cp -a "${thepwd}/gtk-configs/gtk.css" "${thepwd}/mountpoint/workdir/rootfs/etc/skel/.config/gtk-3.0/"
sudo cp -a "${thepwd}/gtk-configs/settings.ini" "${thepwd}/mountpoint/workdir/rootfs/etc/skel/.config/gtk-3.0/"
sudo cp -a "${thepwd}/gtk-configs/.gtkrc-2.0" "${thepwd}/mountpoint/workdir/rootfs/etc/skel/"

#copy some config files to /root in the inner rootfs
sudo mkdir -p "${thepwd}/mountpoint/workdir/rootfs/root/Desktop"
sudo mkdir -p "${thepwd}/mountpoint/workdir/rootfs/root/.config"

#write an xinitrc for root user that opens a terminal for installing
echo '#!/bin/sh' | sudo tee "${thepwd}/mountpoint/workdir/rootfs/root/.xinitrc"
echo 'sakura &' | sudo tee "${thepwd}/mountpoint/workdir/rootfs/root/.xinitrc"
echo 'exec xfce4-session' | sudo tee "${thepwd}/mountpoint/workdir/rootfs/root/.xinitrc"
sudo chmod 700 "${thepwd}/mountpoint/workdir/rootfs/root/.xinitrc"

##sudo cp -a ${thepwd}/.profile "${thepwd}/mountpoint/workdir/rootfs/root/"
sudo chmod 700 "${thepwd}/mountpoint/workdir/rootfs/root/.xinitrc"
##sudo chmod 700 "${thepwd}/mountpoint/workdir/rootfs/root/.profile"
sudo ln -s .xinitrc "${thepwd}/mountpoint/workdir/rootfs/root/.xsession"
sudo chmod 700 "${thepwd}/mountpoint/workdir/rootfs/root/.xsession" "${thepwd}/mountpoint/workdir/rootfs/root/.xinitrc"
sudo mkdir -p "${thepwd}/mountpoint/workdir/rootfs/root/.config/gtk-3.0"
sudo cp -a "${thepwd}/gtk-configs/gtk.css" "${thepwd}/mountpoint/workdir/rootfs/root/.config/gtk-3.0/"
sudo cp -a "${thepwd}/gtk-configs/settings.ini" "${thepwd}/mountpoint/workdir/rootfs/root/.config/gtk-3.0/"
sudo cp -a "${thepwd}/gtk-configs/.gtkrc-2.0" "${thepwd}/mountpoint/workdir/rootfs/root/"

#copy touchpad tap-to-click xorg setting to /usr/share/X11/xorg.conf.d in the inner rootfs
sudo mkdir -p "${thepwd}/mountpoint/workdir/rootfs/usr/share/X11/xorg.conf.d"
sudo cp "${thepwd}/50-synaptics.conf" "${thepwd}/mountpoint/workdir/rootfs/usr/share/X11/xorg.conf.d/50-synaptics.conf"

#create /etc/resolv.conf for inner rootfs
cat /etc/resolv.conf | sudo tee "${thepwd}/mountpoint/workdir/rootfs/etc/resolv.conf"

#copy build scripts to inner rootfs
sudo mkdir -p "${thepwd}/mountpoint/workdir/rootfs/workdir/"
sudo cp -a "${thepwd}/myBuildsHost" "${thepwd}/mountpoint/workdir/rootfs/workdir/"
sudo cp -a "${thepwd}/helpers" "${thepwd}/mountpoint/workdir/rootfs/workdir/"
sudo cp -a "${thepwd}/getEquiptmentHost.sh" "${thepwd}/mountpoint/workdir/rootfs/workdir/"
sudo cp -a "${thepwd}/installEquiptmentHost.sh" "${thepwd}/mountpoint/workdir/rootfs/workdir/"
sudo chmod +x "${thepwd}/mountpoint/workdir/rootfs/workdir/getEquiptmentHost.sh"
sudo chmod +x "${thepwd}/mountpoint/workdir/rootfs/workdir/installEquiptmentHost.sh"

#run stage three in the inner rootfs
sudo cp "${thepwd}/stage3.sh" "${thepwd}/mountpoint/workdir/rootfs/workdir/"
sudo chmod +x "${thepwd}/mountpoint/workdir/rootfs/workdir/stage3.sh"
sudo chroot "${thepwd}/mountpoint/workdir/rootfs" /workdir/stage3.sh "${THEARCH}" "$2"


##AEL ROM launchers start##
sudo cp -a "${thepwd}/launchers/run_retroarch.sh" "${thepwd}/mountpoint/workdir/rootfs/usr/bin/run_retroarch.sh"
sudo chmod 0755 "${thepwd}/mountpoint/workdir/rootfs/usr/bin/run_retroarch.sh"
sudo chroot "${thepwd}/mountpoint/workdir/rootfs" chown root:root "/usr/bin/run_retroarch.sh"

sudo cp -a "${thepwd}/launchers/run_mupen64.sh" "${thepwd}/mountpoint/workdir/rootfs/usr/bin/run_mupen64.sh"
sudo chmod 0755 "${thepwd}/mountpoint/workdir/rootfs/usr/bin/run_mupen64.sh"
sudo chroot "${thepwd}/mountpoint/workdir/rootfs" chown root:root "/usr/bin/run_mupen64.sh"

sudo cp -a "${thepwd}/launchers/run_linux-native.sh" "${thepwd}/mountpoint/workdir/rootfs/usr/bin/run_linux-native.sh"
sudo chmod 0755 "${thepwd}/mountpoint/workdir/rootfs/usr/bin/run_linux-native.sh"
sudo chroot "${thepwd}/mountpoint/workdir/rootfs" chown root:root "/usr/bin/run_linux-native.sh"

sudo cp -a "${thepwd}/run_xemu.sh" "${thepwd}/mountpoint/workdir/rootfs/usr/bin/run_xemu.sh"
sudo chmod 0755 "${thepwd}/mountpoint/workdir/rootfs/usr/bin/run_xemu.sh"
sudo chroot "${thepwd}/mountpoint/workdir/rootfs" chown root:root "/usr/bin/run_xemu.sh"

sudo cp -a "${thepwd}/launchers/run_connman.sh" "${thepwd}/mountpoint/workdir/rootfs/usr/bin/run_connman.sh"
sudo chmod 0755 "${thepwd}/mountpoint/workdir/rootfs/usr/bin/run_connman.sh"
sudo chroot "${thepwd}/mountpoint/workdir/rootfs" chown root:root "/usr/bin/run_connman.sh"

sudo cp -a "${thepwd}/launchers/run_stella.sh" "${thepwd}/mountpoint/workdir/rootfs/usr/bin/run_stella.sh"
sudo chmod 0755 "${thepwd}/mountpoint/workdir/rootfs/usr/bin/run_stella.sh"
sudo chroot "${thepwd}/mountpoint/workdir/rootfs" chown root:root "/usr/bin/run_stella.sh"

sudo cp -a "${thepwd}/launchers/run_terminal.sh" "${thepwd}/mountpoint/workdir/rootfs/usr/bin/run_terminal.sh"
sudo chmod 0755 "${thepwd}/mountpoint/workdir/rootfs/usr/bin/run_terminal.sh"
sudo chroot "${thepwd}/mountpoint/workdir/rootfs" chown root:root "/usr/bin/run_terminal.sh"

sudo cp -a "${thepwd}/launchers/run_volumecontrol.sh" "${thepwd}/mountpoint/workdir/rootfs/usr/bin/run_volumecontrol.sh"
sudo chmod 0755 "${thepwd}/mountpoint/workdir/rootfs/usr/bin/run_volumecontrol.sh"
sudo chroot "${thepwd}/mountpoint/workdir/rootfs" chown root:root "/usr/bin/run_volumecontrol.sh"

sudo cp -a "${thepwd}/launchers/run_webbrowser.sh" "${thepwd}/mountpoint/workdir/rootfs/usr/bin/run_webbrowser.sh"
sudo chmod 0755 "${thepwd}/mountpoint/workdir/rootfs/usr/bin/run_webbrowser.sh"
sudo chroot "${thepwd}/mountpoint/workdir/rootfs" chown root:root "/usr/bin/run_webbrowser.sh"

##AEL ROM launchers end##

##back up permissions that have sbit set to restore later upon installation
sudo echo '#!/bin/sh' | sudo tee "${thepwd}/mountpoint/workdir/rootfs/getperms.sh"
sudo echo 'cd /' | sudo tee -a "${thepwd}/mountpoint/workdir/rootfs/getperms.sh"
sudo echo 'getfacl -R . > /saved-permissions' | sudo tee -a "${thepwd}/mountpoint/workdir/rootfs/getperms.sh"
sudo chmod +x "${thepwd}/mountpoint/workdir/rootfs/getperms.sh"
sudo chroot "${thepwd}/mountpoint/workdir/rootfs" ./getperms.sh

sudo rm "${thepwd}/mountpoint/workdir/rootfs/getperms.sh"

#clean up any scripts inside the inner rootfs
sudo rm -rf "${thepwd}/mountpoint/workdir/rootfs/workdir"

#stage 4 - run from the extracted iso
cd "${thepwd}"
sudo cp stage4.sh "${thepwd}/mountpoint/workdir/"
sudo cp initOverlay.sh "${thepwd}/mountpoint/workdir/"
sudo cp installToHDD.sh "${thepwd}/mountpoint/workdir/"
sudo chmod +x "${thepwd}/mountpoint/workdir/stage4.sh"
sudo chroot "${thepwd}/mountpoint" /workdir/stage4.sh "${THEARCH}"