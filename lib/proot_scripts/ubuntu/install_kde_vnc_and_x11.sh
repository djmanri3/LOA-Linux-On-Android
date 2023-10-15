#!/bin/bash
#VARS

distro_name="ubuntu"
proot_folder=/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu
proot_out=$PREFIX/bin
proot_in=$proot_folder/usr/local/bin
ui="startplasma-x11 --display=:0"
ui_package="plasma-desktop konsole dolphin "
ui_name="KDE"
ui_install="install_$ui_name.sh"

## Colors
n="\e[0m"
b="\e[0;36m"
r="\e[0;31m"
g="\e[1;32m"


# Install proot arch
function setup {
	apt update && apt install tigervnc xorg-xhost proot-distro -y
	proot-distro install $distro_name
}

# Install Desktop Environment
function gen_install {
	cp ./lib/proot_scripts/.data/install_chromium.sh $proot_folder/root/
	echo "distro_name=$distro_name" > $proot_folder/root/$ui_install
	echo '## Colors' >> $proot_folder/root/$ui_install
	echo 'n="\e[0m"'  >> $proot_folder/root/$ui_install
	echo 'b="\e[0;36m"' >> $proot_folder/root/$ui_install
	echo 'r="\e[0;31m"' >> $proot_folder/root/$ui_install
	echo 'g="\e[1;32m"' >> $proot_folder/root/$ui_install
	echo "uname=$uname">> $proot_folder/root/$ui_install
	echo "ui_name=$ui_name">> $proot_folder/root/$ui_install
	echo "clear" >> $proot_folder/root/$ui_install
	echo 'echo -e ""$b"INTO PROOT DISTRO$n "$g" $distro_name $n..."' >> $proot_folder/root/$ui_install
	echo "echo" >> $proot_folder/root/$ui_install
	echo 'echo -e "- "$g"Upgrade$n "$b" $distro_name $n"' >>$proot_folder/root/$ui_install
	echo "apt update #&& apt upgrade -y" >> $proot_folder/root/$ui_install
	echo "echo" >> $proot_folder/root/$ui_install
	echo 'echo -e "- "$g"Installing$n "$b"$ui_name $n"' >> $proot_folder/root/$ui_install
	echo "apt install -y xorg sddm $ui_package pulseaudio sudo" >> $proot_folder/root/$ui_install
	echo "echo">> $proot_folder/root/$ui_install
	echo 'echo -e "- "$b"Create local user$n"'>> $proot_folder/root/$ui_install
	echo 'mkdir /home/$uname && useradd $uname -b /home/ -s /bin/bash && chown $uname:$uname /home/$uname'>> $proot_folder/root/$ui_install
	echo 'echo -e "---- "$g"Set password$n for "$b"local user$n"' >> $proot_folder/root/$ui_install
	echo 'passwd $uname' >> $proot_folder/root/$ui_install
	echo 'echo -e "---- "$g"Add user$n to "$b"sudoers$n"'>> $proot_folder/root/$ui_install
	echo 'echo "$uname ALL=("ALL:ALL") ALL" >> /etc/sudoers' >> $proot_folder/root/$ui_install
	echo 'echo -e "- "$g"Install$n "$b"chromium$n ..."' >> $proot_folder/root/$ui_install
	echo './install_chromium.sh' >> $proot_folder/root/$ui_install
	chmod u+x $proot_folder/root/$ui_install
}

# Fuera de proot (x11)
function gen_startubun {
	echo "am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity" > $proot_out/x11ubun
	echo "pulseaudio --start --load='module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1' --exit-idle-time=-1" >> $proot_out/x11ubun
	echo "proot-distro login $distro_name --shared-tmp -- runuser -l $uname -c x11start" >> $proot_out/x11ubun
	chmod u+x $proot_out/x11ubun
	if [ -d /data/data/com.termux/files/home/.shortcuts ]
	then
		cp $proot_out/x11ubun /data/data/com.termux/files/home/.shortcuts/x11ubun
	else
		mkdir /data/data/com.termux/files/home/.shortcuts
		cp $proot_out/x11ubun /data/data/com.termux/files/home/.shortcuts/x11ubun
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
	echo -e ""$r"[ERROR]$n Generate script file of install packages in arch failled!"
else
	echo -e ""$g"[OK]$n Generate script file of install packages in arch"
fi

gen_startubun
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

"$g"x11$n:
1. Execute [x11debi] to start x11 environment and proot distro
2. Open app termux-x11

OR

1. Download "$b"termux:widget$n
2. Add termux widget on your home screen
3. Tap on x11ubun
4. Open termux-x11

===================
 Credits: DJMANRI3
===================


"
