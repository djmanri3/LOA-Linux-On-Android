#! /bin/bash
#pulseaudio --start --load='module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1' --exit-idle-time=-1

# Use whith app xdls

export DISPLAY=127.0.0.1:0
export PULSE_SERVER=tcp:127.0.0.1:4713
xfce4-session
