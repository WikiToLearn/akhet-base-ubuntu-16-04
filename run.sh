#!/bin/bash

if [[ "$VNCPASS" == "" ]] ; then
 exit 1
fi

/usr/bin/openssl req -new -x509 -days 365 -nodes -out /self.pem -keyout /self.pem -batch &
python /websockify/websockify.py 6080 127.0.0.1:5900 -v --cert=/self.pem --key=/self.pem -D

mkdir /root/.vnc/
x11vnc -storepasswd $VNCPASS /root/.vnc/passwd

Xorg +extension GLX +extension RANDR +extension RENDER  -config /etc/X11/xorg.conf :0 &

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf

chown user:user /home/user

if [[ "$SHARED" == "1" ]] ; then
 SHARED="-shared"
else
  SHARED="-nevershared -dontdisconnect"
fi

if [[ "$NOTIMEOUT" != "1" ]] ; then
 for i in $(seq 1 3) ; do
  x11vnc -rfbport 5900 -usepw -display :0 -shared -noxdamage -xrandr $SHARED -timeout 60 -ping 1 -repeat
 done
else
 x11vnc -rfbport 5900 -usepw -display :0 -shared -noxdamage -xrandr $SHARED -forever -ping 1 -repeat
fi
