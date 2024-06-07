#! /bin/bash

#VARS
name_script="lib/start_environment.sh"
## Colors
n="\e[0m"
b="\e[0;36m"
r="\e[0;31m"
o="\e[0;33m"
g="\e[1;32m"

#FUCTIONS

toilet_check(){
	which toilet
	if [ $? != 0 ]
	then
		apt -y install toilet
	fi
}
banner(){
	clear
	echo
	toilet --filter border LOA
	echo -e ""$b"   Linux On Android$n"
}

install(){
	echo
	echo " ================ "
	echo -e " "$b"Install packages $n"
	echo " ================ "
	echo

	pkg install tur-repo && pkg update
	
	pkg install x11-repo pulseaudio -y
	apt install openssl xfce4* firefox chromium -y
}

install_proot(){
	echo
	echo " ================ "
	echo -e " "$b"Install packages $n"
	echo " ================ "
	echo
	pkg install x11-repo pulseaudio -y
	apt install openssl -y
}

files(){
	echo
	echo " ======================== "
	echo -e " "$b"Install termux-x11 files $n"
	echo " ======================== "
	echo

	echo "- Install termux-x11.deb..."
	echo "--- Install apk..."
	sleep 5
	termux-open ./lib/termux-x11/termux-x11-universal.apk
	read -p "Press enter to continue..." s
	echo "--- Install packages..."
	pkg install ./lib/termux-x11/termux-x11*.deb -y
	apt upgrade -y
	echo
	
	if [ "$1" == "vanila" ]
	then
		echo "- Generate script to enable UI..."
		echo
		echo "am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity" > ./$name_script
		echo "export XDG_RUNTIME_DIR=${TMPDIR}" >> ./$name_script
		echo "sleep 2" >> ./$name_script
		echo "export DISPLAY=:0" >> ./$name_script
		echo "termux-x11 &" >> ./$name_script
		echo "sleep 4" >> ./$name_script
		echo "pulseaudio --start --load='module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1' --exit-idle-time=-1" >> ./$name_script
		echo "xfce4-session --display=:0" >> ./$name_script
		chmod u+x $name_script
		cp ./$name_script /data/data/com.termux/files/usr/bin/x11vani
		if [ -d /data/data/com.termux/files/home/.shortcuts ]
		then
			mv ./$name_script /data/data/com.termux/files/home/.shortcuts/x11vani
		else
			mkdir /data/data/com.termux/files/home/.shortcuts
			mv ./$name_script /data/data/com.termux/files/home/.shortcuts/x11vani
		fi
		echo
	fi

}

proot_setup(){

	chmod u+x ./lib/proot_scripts/install_proot.sh
	clear
	echo
	echo " ===================="
	echo -e "$b PRoot Distro install$n"
	echo " ===================="
	echo
	echo -e "- 🟠"$o"Ubuntu$n ------------------------"
	echo -e ""$b"1$n. Desktop Environment: "$b"XFCE4$n"
	echo -e ""$b"2$n. Desktop Environment: "$b"KDE$n"
	echo
	echo -e "- 🔴"$r"Debian$n ------------------------"
	echo -e ""$b"3$n. Desktop Environment: "$b"XFCE4$n"
	echo -e ""$b"4$n. Desktop Environment: "$b"KDE$n"
	echo
	echo -e "- 🔵"$b"ArchLinux$n ---------------------"
	echo -e ""$b"5$n. Desktop Environment: "$b"KDE$n"
	echo -e ""$b"6$n. Desktop Environment: "$b"CuteFish$n"
	echo -e ""$b"7$n. Desktop Environment: "$b"XFCE4$n"
	echo -e ""$b"8$n. Desktop Environment: "$b"LXQT$n"
	echo
	echo -e "- 🍓"$r"Raspberry OS$n ---------------------"
	echo -e ""$b"9$n. Desktop Environment: "$b"LXDE$n"
	echo
	read -p "What distro and DE (Desktop Environment) use (input number 1..9): " s
	case $s in

		1)
			echo
			echo -e "- Installing "$b"Ubuntu$n with DE "$b"XFCE4$n"
			#./lib/proot_scripts/install_proot.sh
			./lib/proot_scripts/ubuntu/install_xfce_vnc_and_x11.sh

		;;

		2)
			echo
			echo -e "- Installing "$b"Ubuntu$n whith DE "$b"KDE$n"
			./lib/proot_scripts/ubuntu/install_kde_vnc_and_x11.sh

		;;

		3)
			echo
			echo -e "- Installing "$b"Debian$n with DE "$b"XFCE4$n"
			#./lib/proot_scripts/install_proot.sh
			./lib/proot_scripts/debian/install_xfce_vnc_and_x11.sh

		;;

		4)
			echo
			echo -e "- Installing "$b"Debian$n whith DE "$b"KDE$n"
			./lib/proot_scripts/debian/install_kde_vnc_and_x11.sh

		;;


		5)
			echo
			echo -e "- Installing "$b"ArchLinux$n whith DE "$b"KDE$n"
			./lib/proot_scripts/arch/install_kde_vnc_and_x11.sh

		;;


		6)
			echo
			echo -e "- Installing "$b"ArchLinux$n whith DE "$b"CuteFish$n"
			./lib/proot_scripts/arch/install_cutefish_vnc_and_x11.sh
		;;

		7)
			echo
			echo -e "- Installing "$b"ArchLinux$n whith DE "$b"XFCE4$n"
			./lib/proot_scripts/arch/install_xfce_vnc_and_x11.sh
		;;

		8)
			echo
			echo -e "- Installing "$b"ArchLinux$n whith DE "$b"LXQT$n"
			./lib/proot_scripts/arch/install_lxqt_vnc_and_x11.sh
		;;

		9)
			echo
			echo -e "- Installing "$r"Raspberry Os$n whith DE "$b"LXDE$n"
			./lib/proot_scripts/raspberry_os/install_lxde_vnc_and_x11.sh
		;;

	esac
	
}

tweaks(){
	grep "# allow-external-apps" "/data/data/com.termux/files/home/.termux/termux.properties" > /dev/null
	if [ $? == 0 ]
	then
		sed -i s/"# allow-external-apps"/"allow-external-apps"/g "/data/data/com.termux/files/home/.termux/termux.properties"
		termux-reload-settings
	fi

}

chroot_debian(){
	lib/chroot_scripts/start_install_debian.sh
}

#DO IT!

toilet_check
banner

case $1 in

	vanila)
		tweaks
		files
		install
		files $1

		echo -e ""$g"Process completed!$n"
		echo
		echo -e "

"$g"x11$n:
1. Execute [x11vani] to start x11 environment and proot distro
2. Open app termux-x11

OR

1. Download "$b"termux:widget$n
2. Add termux widget on your home screen
3. Tap on x11vani
4. Open termux-x11

===================
 Credits: DJMANRI3
==================="
		echo 
	;;

	proot)
		tweaks
		install_proot
		files
		proot_setup

		echo -e ""$g"Process completed! $n"
		echo
	;;


	chroot_debian)
		tweaks
		files
		chroot_debian
		echo -e ""$g"Process completed! $n"
	;;

	proot_backup)
		if [ "$2" == "" ]
		then
			echo
			echo
			echo -e "$r[ERROR]"$n" Not parameter 2!"
			echo "- <script_name> proot_backup <path/name.tar.gz>"
			echo
			echo "Setup storage execute command termux-setup-storage in ~/"
			echo
			echo "Example:"
			echo "- <script_name> proot_backup <~/storage/shared/archKDE.tar.gz>"
			echo
			exit 1
		fi
		echo
		echo
		echo "=============="
		echo -e ""$b"Backup PRoot$n"
		echo "=============="
		echo
		echo
		proot-distro list
		echo
		echo

		read -p "- Alias of distro: " dname
		proot-distro backup --output $2 $dname
		if [ $? != 0 ]
		then
			echo
		        echo -e ""$r"[ERROR]$n Backup of proot distro $dname failled!"
			echo
			exit 1
		else
			echo
		        echo -e ""$g"[OK]$n Backup of proot distro $dname in $2 create"
			echo
			exit 0
		fi


	;;

	proot_restore)
		if [ "$2" == "" ]
		then
			echo
			echo
			echo -e "$r[ERROR]"$n" Not parameter 2!"
			echo "- <script_name> proot_restore <path>"
			echo
			echo "Setup storage execute command termux-setup-storage in ~/"
			echo
			echo "Example:"
			echo "- <script_name> proot_restore <~/storage/shared/archKDE.tar.gz>"
			echo
			exit 1

			echo
			exit 1
		fi
		echo
		echo
		echo "=============="
		echo -e ""$b"Restore PRoot$n"
		echo "=============="
		echo
		echo
		echo -e "- "$b"Install$n packages...  ["$b" tigervnc xorg-xhost proot-distro unzip$n ]"
		pkg install tur-repo 
		apt update && apt install tigervnc xorg-xhost proot-distro unzip x11-repo pulseaudio -y
		echo
		echo -e "- Install termux-x11..." 
		files
		echo -e "- "$b"Mount storage$n..."
		termux-setup-storage
		echo -e "- "$b"Restore$n proot distro..."
		proot-distro restore $2
		echo -e "- Generate command x11arch to start DE (Desktop Environment)..."
		gen_startarch
		if [ $? != 0 ]
		then
		        echo -e ""$r"[ERROR]$n Generate script file of power on arch failled!"
		else
		        echo -e ""$g"[OK]$n Generate script file of power on arch"
		fi

		if [ $? == 0 ]
		then
			echo
			echo -e ""$g"Process completed!$n"
			echo
			exit 0
		else
			echo
			echo -e "$r[ERROR]"$n" Proot Distro no restore"
			echo
			exit 1
		fi
	;;

	update_proot)
		proot_setup

		echo
		echo -e ""$g"Process completed!$n"
		echo
	;;

	ssh_server)
		tweaks
		./lib/tools/install_ssh_server.sh	
	;;

	connect_x11)
		if [ "$2" == -s ]
		then
			echo
			tweaks;
			echo "- Install termux-x11..."
			echo "--- Install apk..."
			sleep 5
			termux-open ./lib/termux-x11/termux-x11-universal.apk
		fi

		./lib/tools/connect_x11.sh $2
	;;

	?)
		echo
		echo "How to execute"
		echo
		echo " ------- "
		echo -e "| "$g"TOOLS$n |"
		echo " ------- "
		echo -e "$b- <script name> + ssh_server$n: install ssh server"
		echo -e "$b- <script name> + connect_x11$n: connect to remote Desktop Environment"
		echo -e "$b- <script name> + connect_x11 -s $n: setup connect to remote Desktop Environment"
		echo
		echo " --------- "
		echo -e "| "$g"INSTALL$n |"
		echo " ---------"
		echo -e "$b- <script name> + vanila$n: install without proot"
		echo -e "$b- <script name> + proot $n: install with proot"
		echo -e "$b- <script_name> + proot_backup <path/name.tar.gz>$n: create backup of proot distro $b(setup storage 'termux-setup-storage')$n"
		echo -e "$b- <script_name> + proot_restore <path/name.tar.gz>$n: restore proot distro $b(setup storage 'termux-setup-storage')$n"
		echo -e "$b- <script name> + proot_update$n: update proot"
		echo -e "$b- <script name> + chroot_debian$n: install chroot of distro debian "$r"[With ROOT]"$b""
		echo
		echo " ----------- "
		echo -e "| "$g"Start ENV$n |"
		echo " ----------- "
		echo -e "$b- x11vani$n: start environment installed with option vanilla"
		echo -e "$b- x11<distro>$n: start environment installed with proot distros"
		echo -e "      "$b"ubun$n: "$o"Ubuntu$n"
		echo -e "      "$b"debi$n: "$r"Debian$n"
		echo -e "      "$b"arch$n: "$b"Archlinux$n"
		echo -e "      "$b"pi$n:   "$r"Raspbian$n"
		echo
		exit 0
	;;

	*)
		echo
		echo
		echo -e "$r[ERROR]"$n" Not parameter!"
		echo
		echo "If you need help execute <script name> + ?"
		echo
		exit 1
	;;
esac
