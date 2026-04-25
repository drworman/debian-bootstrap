#!/bin/sh

xinitdir="/etc/X11/xinit"

# start some nice programs

if [ -d "$xinitdir"/xinitrc.d ] ; then
	for f in "$xinitdir/xinitrc.d"/?*.sh ; do
		[ -x "$f" ] && . "$f"
	done
	unset f
fi

# xrdb: For i3wm, call from i3sessions.sh
# uncomment below fo rother WMs or DEs

#exec xrdb ~/.Xresources

# Desktop environment: i3, gnome-session-manager, etc.
exec /usr/bin/i3
