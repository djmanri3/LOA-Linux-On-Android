#!/bin/sh

# Check username
if [ -z "$1" ]
then
	echo && echo "Please write name of user!" && echo "./$(basename "$0") USERNAME"
	exit 1
fi

# VARS
CHROOTPATH="/data/data/com.termux/files/home/debian_chroot"

# Functions
CHmount(){
	sudo busybox mount -o remount,dev,suid /data
	sudo busybox mount --bind /dev $CHROOTPATH/dev
	sudo busybox mount --bind /sys $CHROOTPATH/sys
	sudo busybox mount --bind /proc $CHROOTPATH/proc
	sudo busybox mount -t devpts devpts $CHROOTPATH/dev/pts
	sudo mkdir -p $CHROOTPATH/dev/shm
	sudo busybox mount -t tmpfs -o size=256M tmpfs $CHROOTPATH/dev/shm
	sudo busybox mount --bind /sdcard $CHROOTPATH/sdcard
	sudo busybox mount --bind $PREFIX/tmp $CHROOTPATH/tmp
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

# DO IT
CHmount
sudo busybox chroot $CHROOTPATH /bin/su - $1
CHumount
