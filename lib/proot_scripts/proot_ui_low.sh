#! /bin/bash

distro=`ls /data/data/com.termux/files/usr/var/lib/udroid/installed-filesystems/`
proot="/data/data/com.termux/files/usr/var/lib/udroid/installed-filesystems/$distro/root"
proot_root="/data/data/com.termux/files/usr/var/lib/udroid/installed-filesystems/$distro/"
BIN_NAME=`echo $0 | cut -d"." -f2 | cut -d"/" -f2`

clear
echo "LOW PROFILE!"
echo
echo "Steps start UX:"
echo "- Open app XServer XSDL"
echo "- Execute start"
echo
echo "Steps to install chromium:"
echo "- execute ./install_chromium.sh"
echo

if [ -f "$proot/start_low.sh" ]
then
    echo
else
    chmod u+x .data/start_low.sh
    cp  ".data/start_low.sh" "$proot_root/usr/local/bin/start_low"
fi

if [ -f "$proot/install_chromium.sh" ]
then
    echo
else
    chmod u+x install_chromium.sh
    cp  ".data/install_chromium.sh" "$proot"
fi

udroid -l jammy:xfce4 << EOF
start_low
EOF

# Install as bin
if [ -f $PREFIX/bin/$BIN_NAME ]
then
        echo
else
        cp ./$0 $PREFIX/bin/$BIN_NAME
fi
