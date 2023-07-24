#! /bin/bash
#VARS
distro=`ls /data/data/com.termux/files/usr/var/lib/udroid/installed-filesystems/`
proot="/data/data/com.termux/files/usr/var/lib/udroid/installed-filesystems/$distro/root"
BIN_NAME=`echo $0 | cut -d"." -f2 | cut -d"/" -f2`

pulseaudio --start --load='module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1' --exit-idle-time=-1

export XDG_RUNTIME_DIR=${TMPDIR}
export DISPLAY=:0
termux-x11 &

if [ -f "$proot/start.sh" ]
then
    echo
else
    cp  "lib/proot_scripts/.data/start.sh" "$proot"
    chmod u+x $proot/start.sh
fi

if [ -f "$proot/install_chromium.sh" ]
then
    echo
else
    cp  "lib/proot_scripts/.data/install_chromium.sh" "$proot"
    chmod u+x $proot/install_chromium.sh
fi

udroid -l jammy:xfce4 << EOF
./start.sh
EOF

# Install as bin
if [ -f $PREFIX/bin/$BIN_NAME ]
then
	echo
else
	cp ./$0 $PREFIX/bin/$BIN_NAME
fi
