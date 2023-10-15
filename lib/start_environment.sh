export XDG_RUNTIME_DIR=/data/data/com.termux/files/usr/tmp
sleep 2
export DISPLAY=:0
termux-x11 &
sleep 4
pulseaudio --start --load='module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1' --exit-idle-time=-1
xfce4-session --display=:0
