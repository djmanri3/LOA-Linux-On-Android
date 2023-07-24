#!/bin/bash
#VARS

proot_folder=/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/archlinux
proot_out=$PREFIX/bin
proot_in=$proot_folder/usr/local/bin
ui="plasma_session"

# Install proot arch

apt update && apt install tigervnc xorg-xhost proot-distro -y

proot-distro install archlinux

# Install KDE Plasma

echo "pacman -Sy plasma-desktop dolphin firefox konsole tigervnc pulseaudio" > $proot_folder/root/install_kde.sh

chmod u+x $proot_folder/root/install_kde.sh

# Fuera de proot (x11)
echo "export DISPLAY=:1" > $proot_out/x11arch
echo "termux-x11 &"  >> $proot_out/x11arch
echo "pulseaudio --start --load='module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1' --exit-idle-time=-1" >> $proot_out/x11arch
echo "proot-distro login archlinux --shared-tmp -- runuser -l root -c x11start" >> $proot_out/x11arch

chmod u+x $proot_out/x11arch

# Dentro de proot (x11)
echo "export PULSE_SERVER=127.0.0.1" > $proot_in/x11start
echo "export DISPLAY=:1" >> $proot_in/x11start
echo "export XDG_RUNTIME_DIR=${TMPDIR}" >> $proot_in/x11start
echo "sleep 4" >> $proot_in/x11start
echo "dbus-launch --exit-with-session $ui" >> $proot_in/x11start

chmod u+x $proot_in/x11start

# Fuera de proot (vnc)

echo "vncserver -geometry 1920x1080 -listen tcp :1" > $proot_out/archvnc
echo "pulseaudio --start --load='module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1' --exit-idle-time=-1" >> $proot_out/archvnc
echo "DISPLAY=:1 xhost +" >> $proot_out/archvnc
echo "proot-distro login archlinux --shared-tmp" >> $proot_out/archvnc

chmod u+x $proot_out/archvnc

# Dentro de proot (vnc)

echo "rm /run/dbus/pid" > $proot_in/vncstart
echo "dbus-daemon --system" >> $proot_in/vncstart
echo "sleep 4" >> $proot_in/vncstart
echo "DISPLAY=:1 dbus-launch $ui" >> $proot_in/vncstart

chmod u+x $proot_in/vncstart

echo
echo
echo
echo "
- Steps:

VNC:
1. Execute [archvnc] to start vnc server and proot distro
2. Next install kde environment, execute [./install_kde.sh] (wait...)
3. To start environment execute [vncstart]
4. End execute [vncserver -kill :1]

x11:
1. Execute [x11arch] to start x11 environment and proot distro
2. Next install kde environment, execute [./install_kde.sh] (wait...)
3. To start environment execute [x11start]

===================
 Credits: DJMANRI3
===================


"

