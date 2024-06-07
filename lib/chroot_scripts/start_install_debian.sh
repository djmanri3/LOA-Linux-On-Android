#!/bin/sh

# VARS
HOME="/data/data/com.termux/files/home"
CHROOTPATH="/data/data/com.termux/files/home/debian_chroot"
CHROOTURL="https://github.com/djmanri3/Debian_Build/releases/download/12.0/debian-bookworm-arm64.tar.gz"
FILENAME="debian12-arm64.tar.gz"

# Funtions
download(){
	echo && echo "- Download image..."
	mkdir -p $CHROOTPATH
	sudo wget $CHROOTURL -q --show-progress && echo
}

descompres(){
	echo "- Extract image..."
	sudo tar xpf $FILENAME -C $CHROOTPATH/ --numeric-owner
	sudo cp lib/chroot_scripts/chroot_config.sh $CHROOTPATH/ && sudo chmod u+x $CHROOTPATH/chroot_config.sh
	sudo rm -rf $FILENAME
}

fix(){
	echo "- Fix errors..."
	sudo sed -i "5d" $CHROOTPATH/etc/pam.d/su-l
	#sudo echo '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' >> $CHROOTPATH/etc/profile

	sudo mkdir -p $CHROOTPATH/dev $CHROOTPATH/sys $CHROOTPATH/proc $CHROOTPATH/dev/pts $CHROOTPATH/sdcard $CHROOTPATH/tmp
	sudo mkdir -p $CHROOTPATH/dev/shm
}

CHmount(){
	sudo busybox mount -o remount,dev,suid /data

	sudo busybox mount --bind /dev $CHROOTPATH/dev
	sudo busybox mount --bind /sys $CHROOTPATH/sys
	sudo busybox mount --bind /proc $CHROOTPATH/proc
	sudo busybox mount -t devpts devpts $CHROOTPATH/dev/pts

	sudo busybox mount -t tmpfs -o size=256M tmpfs $CHROOTPATH/dev/shm

	sudo busybox mount --bind /sdcard $CHROOTPATH/sdcard
	sudo busybox mount --bind $PREFIX/tmp $CHROOTPATH/tmp
}

sudo busybox mount -t tmpfs -o size=256M tmpfs $HOME/debian-chroot/dev/shm

chroot_config(){
	sudo busybox chroot $CHROOTPATH /bin/su - root -c "/chroot_config.sh"
	echo "- Install Desktop Environment"
	read -p "What Desktop Environment install? [kde, xfce4] " DE
	case $DE in
		kde)
			sudo busybox chroot $CHROOTPATH /bin/su - root -c "apt install kde-plasma-desktop dbus-x11 -y"
			sudo cp lib/chroot_scripts/.data/startPlasma $CHROOTPATH/usr/bin && sudo chmod 777 $CHROOTPATH/usr/bin/startPlasma
			cp lib/chroot_scripts/chroot-debian-KDE.sh $PREFIX/bin/chroot-debian-KDE && chmod u+x $PREFIX/bin/chroot-debian-KDE
		;;

		xfce4)
			sudo busybox chroot $CHROOTPATH /bin/su - root -c "apt install xfce4 dbus-x11 -y"
			sudo cp lib/chroot_scripts/.data/startXfce $CHROOTPATH/usr/bin && sudo chmod 777 $CHROOTPATH/usr/bin/startXfce
			cp lib/chroot_scripts/chroot-debian-XFCE.sh $PREFIX/bin/chroot-debian-KDE && chmod u+x $PREFIX/bin/chroot-debian-XFCE
		;;
	esac

	cp lib/chroot_scripts/chroot-debian.sh $PREFIX/bin/chroot-debian && chmod u+x $PREFIX/bin/chroot-debian
}

CHumount(){
	sudo busybox umount $CHROOTPATH/dev/shm
	sudo busybox umount $CHROOTPATH/dev/pts
	sudo busybox umount $CHROOTPATH/dev
	sudo busybox umount $CHROOTPATH/proc
	sudo busybox umount $CHROOTPATH/sys
	sudo busybox umount $CHROOTPATH/sdcard
	sudo busybox umount $CHROOTPATH/tmp
}

# Do IT!

clear
echo && echo "Chroot Installing" && echo
apt install tsu -y
download
if [ $? != 0 ]
then
	echo "[ERROR] Download error!"
	exit 1
fi
descompres
if [ $? != 0 ]
then
	echo "[ERROR] Descompress error!"
	exit 1
fi
fix
CHmount
chroot_config
CHumount

