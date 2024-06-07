#!/bin/sh

# Check username
if [ -z "$1" ]
then
	echo && echo "Please write name of user!" && echo "./$(basename "$0") USERNAME"
	exit 1
fi

# VARS
CHROOTPATH="$HOME/debian_chroot"
DE="startPlasma"

# Functions
start_x11(){
	am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity 
	termux-x11 :0 -ac &
}

start_pulseaudio(){
	pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
	pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1
}

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

start_x11
start_pulseaudio
CHmount
sudo busybox chroot $CHROOTPATH /bin/su - $1 -c "$DE"
CHumount
killall -9 termux-x11 Xwayland pulseaudio virgl_test_server_android termux-wake-lock