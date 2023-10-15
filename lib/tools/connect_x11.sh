#! /bin/bash

# VARS
## Colors
n="\e[0m"
b="\e[0;36m"
r="\e[0;31m"
o="\e[0;33m"
g="\e[1;32m"

##Vars of script
IP_AUDIO=`termux-wifi-connectioninfo | grep ip | cut -d":" -f2 | cut -d"," -f1 | cut -d'"' -f2`
IP_AUT=$(echo $IP_AUDIO | cut -d"." -f1-3)

# FUNCTIONS
function x11-start() {
	ps -ef | grep -v grep | grep "com.termux.x11.Loade" > /dev/null
	if [ $? != 0 ]
	then
		echo -e "- Execute "$g"termux-x11$n..."
		termux-x11 :0 -ac &
		PIDX11=$!
		export DISPLAY=:0
	fi
}

function pulse-audio() {
	ps -ef | grep -v grep | grep "pulseaudio" > /dev/null
	if [ $? != 0 ]
	then
		echo -e "- Execute "$g"pulseaudio$n..."
		pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=$IP_AUDIO auth-anonymous=1" --exit-idle-time=-1 &
	fi
}

function subprocess() {
	echo -e "- Kill "$g"termux-x11$n..." 
	kill $PIDX11
	echo -e "- Kill "$g"pulseaudio$n..."
	pkill pulseaudio
}

function setup() {
	echo "- Install termux-api..."
	echo "--- Install apk..."
	sleep 5
	termux-open ./lib/tools/termux-api.apk
	read -p "    Press enter to continue.."
	echo "--- Install package of termux-api..."
	apt install termux-api
	echo
	echo -e "- Relaunch script "$b"whitout option -s$n"
	exit 0
}
# DO IT!

if [ "$1" == -s ]
then
	setup
fi

echo
echo " ------------- "
echo -e "| "$b"Connect X11$n |"
echo " ------------- "
echo    "----------------------------------"
read -p "- Username: " USER
read -p "- IP: $IP_AUT." IP
read -p "- Command start env: " CMD
echo    "----------------------------------"
CMD="export PULSE_SERVER=$IP_AUDIO && $CMD"
IP=$(echo "$IP_AUT.$IP")

echo 
x11-start
pulse-audio
echo -e "- Start session of X11 forwarding whith SSH... ("$b"exit: ctrl+c or logout in session$n)"
echo && echo    "----------------------------------"
ssh -XY $USER@$IP $CMD
echo && echo    "----------------------------------" && echo

subprocess;
echo

