#! /bin/bash

#VARS
name_script="lib/start_environment.sh"
## Colors
n="\e[0m"
b="\e[0;36m"
r="\e[0;31m"
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
	echo
	echo "--- Install apk..."
	sleep 5
	termux-open ./lib/termux-x11/termux-x11-universal.apk
	read -p "Press enter to continue..." s
	echo "--- Install packages..."
	pkg install ./lib/termux-x11/termux-x11*.deb -y
	echo
	
	if [ "$1" == "vanila" ]
	then
		echo "- Generate script to enable UI..."
		echo
		echo "The file is genrate in ./$name_script"
		echo "export XDG_RUNTIME_DIR=${TMPDIR}" > ./$name_script
		echo "sleep 2" >> ./$name_script
		echo "export DISPLAY=:0" >> ./$name_script
		echo "termux-x11 &" >> ./$name_script
		echo "sleep 4" >> ./$name_script
		echo "pulseaudio --start --load='module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1' --exit-idle-time=-1" >> ./$name_script
		echo "xfce4-session --display=:0" >> ./$name_script
		chmod u+x $name_script
		echo
	fi

}

proot_setup(){

	chmod u+x ./lib/proot_scripts/install_proot.sh
	echo
	echo
	echo "- Script install proot"
	./lib/proot_scripts/install_proot.sh
	
}

tweaks(){
	grep "# allow-external-apps" "/data/data/com.termux/files/home/.termux/termux.properties" > /dev/null
	if [ $? == 0 ]
	then
		sed -i s/"# allow-external-apps"/"allow-external-apps"/g "/data/data/com.termux/files/home/.termux/termux.properties"
	fi

}
#DO IT!

toilet_check
banner

case $1 in

	vanila)
		install
		files $1
		tweaks

		echo -e ""$g"Process completed!$n"
		echo
		echo "Frist open app termux-x11"
		echo -e "Before execute $b./install_environment vanila_start$n"
		echo 
	;;

	proot)
		install_proot
		files
		proot_setup
		tweaks

		echo -e ""$g"Process completed! $n"
		echo
		echo "Instrutions to use:"
		echo -e "- Termux-x11: execute $b./install_environment.sh proot_start$n"
		echo 
		echo
	;;

	update_proot)
		proot_setup

		echo
		echo -e ""$g"Process completed!$n"
		echo
	;;

	proot_start)
		echo
		echo " -------------------- "
		echo -e "| "$b"Start proot distro$n |"
		echo " -------------------- "
		echo
		sleep 2
		./lib/proot_scripts/proot_ui.sh
	;;

	vanila_start)
		echo
		echo " -------------- "
		echo -e "| "$b"Start VANILA$n |"
		echo " -------------- "
		echo
		sleep 2
		./$name_script
	;;


	ssh_server)
		./lib/tools/install_ssh_server.sh	
	;;

	?)
		echo
		echo "How to execute"
		echo
		echo " ------- "
		echo -e "| "$g"TOOLS$n |"
		echo " ------- "
		echo -e "$b- <script name> + ssh_server$n: install ssh server"
		echo
		echo " --------- "
		echo -e "| "$g"INSTALL$n |"
		echo " ---------"
		echo -e "$b- <script name> + vanila$n: install without proot"
		echo -e "$b- <script name> + proot $n: install with proot"
		echo -e "$b- <script name> + proot_update$n: update proot"
		echo
		echo " ----------- "
		echo -e "| "$g"Start ENV$n |"
		echo " ----------- "
		echo -e "$b- <script name> + vanila_start$n: start environment installed with option vanilla"
		echo -e "$b- <script name> + proot_start$n: start environment installed with proot distros"
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
