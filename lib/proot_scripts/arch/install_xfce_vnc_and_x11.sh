#!/bin/bash
#VARS

distro_name=archlinux
proot_folder=/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/archlinux
proot_out=$PREFIX/bin
proot_in=$proot_folder/usr/local/bin
ui="startxfce4 --display=:0"
ui_package="xfce4"
ui_name="XFCE4"
ui_install="install_$ui_name.sh"
ui_vnc="startxfce4"
vnc_package=tigervnc

## Colors
n="\e[0m"
b="\e[0;36m"
r="\e[0;31m"
g="\e[1;32m"


# Install proot arch
function setup {
	apt update && apt install tigervnc xorg-xhost proot-distro -y
	proot-distro install archlinux
}

# Install Desktop Environment
function gen_install {
	echo '## Colors' > $proot_folder/root/$ui_install
	echo 'n="\e[0m"'  >> $proot_folder/root/$ui_install
	echo 'b="\e[0;36m"' >> $proot_folder/root/$ui_install
	echo 'r="\e[0;31m"' >> $proot_folder/root/$ui_install
	echo 'g="\e[1;32m"' >> $proot_folder/root/$ui_install
	echo "uname=$uname">> $proot_folder/root/$ui_install
	echo "ui_name=$ui_name">> $proot_folder/root/$ui_install
	echo "clear" >> $proot_folder/root/$ui_install
	echo 'echo -e ""$b"INTO PROOT DISTRO$n  "$g"ArchLinux$n..."' >> $proot_folder/root/$ui_install
	echo "echo" >> $proot_folder/root/$ui_install
	echo 'echo -e "- "$g"Upgrade$n "$b"ArchLinux$n"' >>$proot_folder/root/$ui_install
	echo "pacman -Syu --noconfirm" >> $proot_folder/root/$ui_install
	echo "echo" >> $proot_folder/root/$ui_install
	echo 'echo -e "- "$g"Installing$n "$b"$ui_name $n"' >> $proot_folder/root/$ui_install
	echo "pacman -S --noconfirm xorg lightdm $ui_package dolphin icu chromium pulseaudio sudo $vnc_package" >> $proot_folder/root/$ui_install
	echo "echo">> $proot_folder/root/$ui_install
	echo 'echo -e "- "$b"Create local user$n"'>> $proot_folder/root/$ui_install
	echo 'mkdir /home/$uname && useradd $uname -b /home/ && chown $uname:$uname /home/$uname'>> $proot_folder/root/$ui_install
	echo 'echo -e "---- "$g"Set password$n for "$b"local user$n"' >> $proot_folder/root/$ui_install
	echo 'passwd $uname' >> $proot_folder/root/$ui_install
	echo 'echo -e "---- "$g"Add user$n to "$b"sudoers$n"'>> $proot_folder/root/$ui_install
	echo 'echo "$uname ALL=("ALL:ALL") ALL" >> /etc/sudoers' >> $proot_folder/root/$ui_install
	echo 'echo -e "- "$g"Fix$n "$b"chromium$n run..."' >> $proot_folder/root/$ui_install
	echo "sed 's/chromium %U/chromium %U --no-sandbox/' /usr/share/applications/chromium.desktop > ./chromium.desktop" >> $proot_folder/root/$ui_install
	echo "mv ./chromium.desktop /usr/share/applications/chromium.desktop" >> $proot_folder/root/$ui_install
	echo 'echo -e "- Config "$b"VNC$n..."' >> $proot_folder/root/$ui_install
	echo 'echo "geometry=1920x1080" >> /etc/tigervnc/vncserver-config-defaults' >> $proot_folder/root/$ui_install
	echo 'echo -e "- Configure "$g"password$n to conect "$b"VNC$n..."' >> $proot_folder/root/$ui_install
	echo "vncpasswd" >> $proot_folder/root/$ui_install
	chmod u+x $proot_folder/root/$ui_install
}

# Fuera de proot (x11)
function gen_startarch {
	echo "am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity" > $proot_out/x11arch
	echo "pulseaudio --start --load='module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1' --exit-idle-time=-1" >> $proot_out/x11arch
	echo "proot-distro login archlinux --shared-tmp --user $uname -- x11start" >> $proot_out/x11arch
	chmod u+x $proot_out/x11arch
	if [ -d /data/data/com.termux/files/home/.shortcuts ]
	then
		cp $proot_out/x11arch /data/data/com.termux/files/home/.shortcuts/x11arch
	else
		mkdir /data/data/com.termux/files/home/.shortcuts
		cp $proot_out/x11arch /data/data/com.termux/files/home/.shortcuts/x11arch
	fi
}

# Dentro de proot (x11)
function gen_startx11 {
	echo "export PULSE_SERVER=127.0.0.1" > $proot_in/x11start
	echo "export XDG_RUNTIME_DIR=${TMPDIR}" >> $proot_in/x11start
	echo "export DISPLAY=:0" >> $proot_in/x11start
	echo "termux-x11 &" >>  $proot_in/x11start
	echo "sleep 4" >> $proot_in/x11start
	echo "dbus-launch --exit-with-session $ui" >> $proot_in/x11start
	chmod u+x $proot_in/x11start
}

# Fuera de proot (vnc)
function gen_startarchvnc {
        echo "pulseaudio --start --load='module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1' --exit-idle-time=-1" > $proot_out/vncarch
        echo "proot-distro login $distro_name --shared-tmp -- runuser -l $uname -c vncstart" >> $proot_out/vncarch
        chmod u+x $proot_out/vncarch
}

# Dentro de proot (vnc)
function gen_startvnc {
        echo "ui_vnc=$ui_vnc" > $proot_in/vncstart
        echo "mkdir ~/.vnc" >> $proot_in/vncstart
        echo "rm -rf /tmp/.X3-lock" >> $proot_in/vncstart
        echo "rm -rf /tmp/.X11-unix/X3" >> $proot_in/vncstart
        echo "rm ~/.vnc/*.pid" >> $proot_in/vncstart
        echo "echo startxfce4 > ~/.vnc/xstartup" >> $proot_in/vncstart
        echo "chmod u+x ~/.vnc/xstartup" >> $proot_in/vncstart
        echo "vncserver :3 && bash" >> $proot_in/vncstart
        chmod u+x $proot_in/vncstart
}

function install_ui {
	echo
	echo "Install $ui_name..."
	echo
	proot-distro login archlinux --shared-tmp -- runuser -l root -c ./$ui_install
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
	echo -e ""$r"[ERROR]$n Generate script file of install packages in arch failled!"
else
	echo -e ""$g"[OK]$n Generate script file of install packages in arch"
fi

gen_startarch
if [ $? != 0 ]
then
	echo -e ""$r"[ERROR]$n Generate script file of power on arch failled!"
else
	echo -e ""$g"[OK]$n Generate script file of power on arch"
fi

gen_startx11
if [ $? != 0 ]
then
	echo -e ""$r"[ERROR]$n Generate script file to start DE x11 failled!"
else
	echo -e ""$g"[OK]$n Generate script file to start DE x11"
fi

gen_startarchvnc
if [ $? != 0 ]
then
	echo -e ""$r"[ERROR]$n Generate script file to start arch vnc failled!"
else
	echo -e ""$g"[OK]$n Generate script file to start arch vnc"
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
1. Execute [vncdebi] to start vnc server and proot distro
2. Open VNC client and connect to localhost:3

"$g"x11$n:
1. Execute [x11debi] to start x11 environment and proot distro
2. Open app termux-x11

OR

1. Download "$b"termux:widget$n
2. Add termux widget on your home screen
3. Tap on x11arch
4. Open termux-x11

===================
 Credits: DJMANRI3
===================


"
