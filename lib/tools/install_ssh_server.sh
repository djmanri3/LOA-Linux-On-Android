#! /bin/bash

#VARS
USER=`whoami`

## Colors
n="\e[0m"
b="\e[0;36m"
r="\e[0;31m"
g="\e[1;32m"

#DO IT!

echo
echo "Apps necesary:"
echo "- Termux:api"
echo
echo -e ""$b"Install termux-api...$n"

grep "# allow-external-apps" "/data/data/com.termux/files/home/.termux/termux.properties" > /dev/null
if [ $? == 0 ]
then
	sed -i s/"# allow-external-apps"/"allow-external-apps"/g "/data/data/com.termux/files/home/.termux/termux.properties"
fi

termux-open ./lib/tools/termux-api.apk
read -p "Please press enter to continue..." s
clear
echo -e ""$b"Install SSH server in Android$n"
read -p "- Port of ssh (Port > 1024): " PORT
echo
echo -e "- Install pacakges... ("$b"wget curl vim openssh termux-auth termux-api$n)"
echo "======================================================="
echo
pkg update && pkg upgrade && pkg install wget curl vim openssh termux-auth termux-api -y
echo
echo "======================================================="
echo
echo -e "$b- Configure SSH server...$n"
echo "Port $PORT" >> $PREFIX/etc/ssh/sshd_config
if [ $? == 0 ]
then
	echo -e "$g- OK$n"
else
	echo -e "$r- FAIL!$n"
	echo
	exit 1
fi
echo
echo -e "- Change password of user "$b"$USER"$n" for SSH conect:"
passwd
echo
echo "- Start server (command sshd)..."
echo
sshd
IP=`termux-wifi-connectioninfo | grep ip | cut -d":" -f2 | cut -d"," -f1 | cut -d'"' -f2`
if [ $? == 0 ]
then
	echo -e "[Server SSH in port "$b"$PORT"$n" started!]"
	echo -e "- For connect= "$b"ssh $USER@$IP -p $PORT"$n""
	echo
else
	echo -e "[Server SSH "$r"not started :("$n"]"
	echo "- Try to execute script another one"
	echo
fi
