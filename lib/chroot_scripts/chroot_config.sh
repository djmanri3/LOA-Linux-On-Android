#! /bin/bash

# VARS
PACKAGES="nano vim net-tools sudo git"
DNS="8.8.8.8"

# Functions
network (){
    echo "- Config network..."
    echo "nameserver $DNS" > /etc/resolv.conf
    echo "127.0.0.1 localhost" > /etc/hosts

    groupadd -g 3003 aid_inet
    groupadd -g 3004 aid_net_raw
    groupadd -g 1003 aid_graphics
    usermod -g 3003 -G 3003,3004 -a _apt
    usermod -G 3003 -a root && echo
}

update_install_pkg(){
    echo "- Update chroot distro..."
    apt update && apt upgrade && echo

    echo "- Install packages..."
    apt install $PACKAGES -y && echo
}

create_user(){
    echo "- Create user..."
    read -p "Name of user: " NAME
    groupadd storage && groupadd wheel
    useradd -m -g users -G wheel,audio,video,storage,aid_inet -s /bin/bash $NAME
    echo && echo "Add pasword to user $NAME:"
    passwd $NAME && echo
    echo "- Add $NAME to sudoers..."
    echo "$NAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && echo
}

fix(){
    echo "- Fix permissions..."
    chmod 755 / /bin /lib
}

# Do IT

#clear
echo
echo " -------------------- "
echo "| Into CHROOT distro |"
echo " -------------------- "
echo

network
update_install_pkg
create_user
fix