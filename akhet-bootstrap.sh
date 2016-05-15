#!/bin/bash

if [[ "$AKHETBASE_VNCPASS" == "" ]] ; then
   echo "Missing AKHETBASE_VNCPASS"
   exit 1
fi

if test ! -d /var/run/akhet
then
   echo "Missing /var/run/akhet directory"
   exit 1
fi
ls -al /root/
if test ! -d /root/.vnc
then
   echo "Missing /root/.vnc directory"
   exit 1
fi

/usr/bin/openssl req -new -x509 -days 365 -nodes -out /self.pem -keyout /self.pem -batch &
touch /var/run/akhet/certs

python /websockify/websockify.py 6080 127.0.0.1:5900 -v --cert=/self.pem --key=/self.pem -D
touch /var/run/akhet/websockify

x11vnc -storepasswd $AKHETBASE_VNCPASS /root/.vnc/passwd
touch /var/run/akhet/vnc-pass

Xorg +extension GLX +extension RANDR +extension RENDER  -config /etc/X11/xorg.conf :0 &
touch /var/run/akhet/x11-host

if [[ "$AKHETBASE_USER_LABEL" != "" ]] ; then
    usermod -c "$AKHETBASE_USER_LABEL" user
fi

for gid in $AKHETBASE_GIDs ; do
    getent group $gid || groupadd -g $gid g$gid
    adduser user $(getent group $gid | awk -F":" '{ print $1 }')
done

usermod -u $AKHETBASE_UID user

chown user:user /home/user

usermod -l $AKHETBASE_USER user

touch /var/run/akhet/user-setup

/usr/local/bin/supervisord -c /etc/supervisor/supervisord.conf
touch /var/run/akhet/supervisor

if [[ "$AKHETBASE_SHARED" == "1" ]] ; then
 SHARED="-shared"
else
 SHARED="-nevershared -dontdisconnect"
fi

if [[ "$AKHETBASE_NOTIMEOUT" != "1" ]] ; then
    for i in $(seq 1 3) ; do
        x11vnc -flag /var/run/akhet/vnc-server -rfbport 5900 -usepw -display :0 -noxdamage -xrandr $SHARED -timeout 60 -ping 1 -repeat
    done
else
    x11vnc -flag /var/run/akhet/vnc-server -rfbport 5900 -usepw -display :0 -noxdamage -xrandr $SHARED -forever -ping 1 -repeat
fi
