#VARS
## Colors
n="\e[0m"
b="\e[0;36m"
g="\e[1;32m"

#DO IT!

echo 
echo "- Clone repo..."
echo "=============================================="
echo

cd lib/
git clone "https://github.com/RandomCoderOrg/fs-manager-udroid"

echo
echo "=============================================="
echo
echo "- Install udroid"
echo "==============================================="
echo

cd "fs-manager-udroid"
./install.sh
cd ..

echo
echo "=============================================="
echo
echo -e "- Install:"
echo -e "Distro: "$b"Ubuntu jammy$n"
echo -e "Desktop Environment: "$b"XFCE4$n..."
echo "=============================================="
echo

udroid install jammy:xfce4

echo
echo "=============================================="
echo
echo "Start udroid xfce:"
echo -e ""$b"udroid -l jammy:xfce4$n"
