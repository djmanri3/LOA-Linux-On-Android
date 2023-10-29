#!/bin/bash
#VARS

distro_name="pi"
distro_url_aarch64='"http://downloads.raspberrypi.org/raspios_lite_arm64/root.tar.xz"'
distro_sha256_aarch64='"db1b538171f40bc5f8980e3ce8153cf840627351e9c5dc2e5862f1284bc36c4b"'
distro_url_arm='"http://downloads.raspberrypi.org/raspios_lite_armhf/root.tar.xz"'
distro_sha256_arm='"bf0414505a0c7ec078cb909cd6af0ebd9fefaebf9b66fd710459bfe42efff0a9"'

proot_folder=/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/$distro_name
proot_out=$PREFIX/bin
proot_in=$proot_folder/usr/local/bin

ui="startlxde-pi"
ui_package="raspberrypi-ui-mods*"
ui_name="startlxde-pi"
ui_install="install_$ui_name.sh"
vnc_package=tightvncserver
ui_vnc="startlxde-pi"

## Colors
n="\e[0m"
b="\e[0;36m"
r="\e[0;31m"
g="\e[1;32m"


# Install proot rasbian
function setup {
	apt update && apt install tigervnc xorg-xhost proot-distro -y
	cat << EOF > $PREFIX/etc/proot-distro/pi.sh
DISTRO_NAME=$distro_name
TARBALL_URL['aarch64']=$distro_url_aarch64
TARBALL_SHA256['aarch64']=$distro_sha256_aarch64
TARBALL_URL['arm']=$distro_url_arm
TARBALL_SHA256['arm']=$distro_sha256_arm
EOF
	proot-distro install $distro_name
	cp lib/proot_scripts/.data/install_chromium.sh $proot_folder/root/
	chmod u+x $proot_folder/root/install_chromium.sh
}

# Install Desktop Environment
function gen_install {
	cat << EOF > $proot_folder/root/$ui_install
distro_name=$distro_name
## Colors
n="\e[0m"
b="\e[0;36m"
r="\e[0;31m"
g="\e[1;32m"
uname=$uname
ui_name=$ui_name
ui_package=$ui_package
EOF

	cat << "EOF" >> $proot_folder/root/$ui_install
clear
echo -e ""$b"INTO PROOT DISTRO$n "$g" $distro_name $n..."
echo
echo -e "- "$g"Upgrade$n "$b" $distro_name $n"
apt update && apt upgrade -y
echo
echo -e "- "$g"Installing$n "$b"$ui_name $n"
apt install -y xorg sddm $ui_package pulseaudio sudo $vnc_package lxterminal neofetch
echo
echo -e "- "$b"Create local user$n"
mkdir /home/$uname && useradd $uname -b /home/ -s /bin/bash && chown $uname:$uname /home/$uname
echo -e "---- "$g"Set password$n for "$b"local user$n"
passwd $uname
echo -e "---- "$g"Add user$n to "$b"sudoers$n"
echo "$uname ALL=("ALL:ALL") ALL" >> /etc/sudoers
echo -e "- "$g"Install$n "$b"chromium$n run..."
./install_chromium.sh
EOF
	chmod u+x $proot_folder/root/$ui_install
}

# Fuera de proot (x11)
function gen_startpi {
	cat << EOF > $proot_out/x11pi
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity
pulseaudio --start --load='module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1' --exit-idle-time=-1
proot-distro login $distro_name --shared-tmp --user $uname -- x11start
EOF
	
	chmod u+x $proot_out/x11pi
	if [ -d /data/data/com.termux/files/home/.shortcuts ]
	then
		cp $proot_out/x11pi /data/data/com.termux/files/home/.shortcuts/x11pi
	else
		mkdir /data/data/com.termux/files/home/.shortcuts
		cp $proot_out/x11pi /data/data/com.termux/files/home/.shortcuts/x11pi
	fi
}

# Dentro de proot (x11)
function gen_startx11 {
	cat << EOF > $proot_in/x11start
export PULSE_SERVER=127.0.0.1
export XDG_RUNTIME_DIR=${TMPDIR}
export DISPLAY=:0
termux-x11 &
sleep 4
dbus-launch --exit-with-session $ui
EOF
	chmod u+x $proot_in/x11start
}

# Fuera de proot (vnc)
function gen_startubunvnc {
	cat << EOF > $proot_out/vncpi
pulseaudio --start --load='module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1' --exit-idle-time=-1
proot-distro login $distro_name --shared-tmp -- runuser -l $uname -c vncstart
EOF
    chmod u+x $proot_out/vncpi
}

# Dentro de proot (vnc)
function gen_startvnc {
	cat << EOF >  $proot_in/vncstart
mkdir ~/.vnc
rm -rf /tmp/.X3-lock
rm -rf /tmp/.X11-unix/X3
rm ~/.vnc/*.pid
echo "$ui_vnc" > ~/.vnc/xstartup
chmod u+x ~/.vnc/xstartup
vncserver :3 -geometry 1920x1080 && bash
EOF
    chmod u+x $proot_in/vncstart
}

function install_ui {
	echo
	echo "Install $ui_name..."
	echo
	proot-distro login $distro_name --shared-tmp -- runuser -l root -c ./$ui_install
}

setup
if [ $? != 0 ]
then
	echo
	echo -e ""$r"[ERROR]$n Setup of packages failled!"
else
	echo
	echo -e ""$g"[OK]$n Setup sucesfull!"
fi

echo 
read -p "Name do you want for proot user: " uname

gen_install
if [ $? != 0 ]
then
	echo -e ""$r"[ERROR]$n Generate script file of install packages in debian failled!"
else
	echo -e ""$g"[OK]$n Generate script file of install packages in Raspbian Os"
fi

gen_startpi
if [ $? != 0 ]
then
	echo -e ""$r"[ERROR]$n Generate script file of power on debian failled!"
else
	echo -e ""$g"[OK]$n Generate script file of power on Raspbian Os"
fi

gen_startx11
if [ $? != 0 ]
then
	echo -e ""$r"[ERROR]$n Generate script file to start DE x11 failled!"
else
	echo -e ""$g"[OK]$n Generate script file to start DE x11"
fi

gen_startubunvnc
if [ $? != 0 ]
then
	echo -e ""$r"[ERROR]$n Generate script file to start debian vnc failled!"
else
	echo -e ""$g"[OK]$n Generate script file to start Raspbian Os vnc"
fi

gen_startvnc
if [ $? != 0 ]
then
	echo -e ""$r"[ERROR]$n Generate script file to start DE vnc failled!"
else
	echo -e ""$g"[OK]$n Generate script file to start DE vnc"
fi

install_ui
if [ $? != 0 ]
then
	echo -e ""$r"[ERROR]$n Generate script file to install DE failled!"
else
	echo -e ""$g"[OK]$n Generate script file to install DE"
fi

echo
echo
echo
echo -e "
- Steps:

"$b"VNC$n:
1. Execute [vncpi] to start vnc server and proot distro
2. Open VNC client and connect to localhost:3

"$g"x11$n:
1. Execute [x11pi] to start x11 environment and proot distro
2. Open app termux-x11

OR

1. Download "$b"termux:widget$n
2. Add termux widget on your home screen
3. Tap on x11pi
4. Open termux-x11

===================
 Credits: DJMANRI3
===================


"


