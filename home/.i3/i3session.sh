#!/bin/bash

# Variables that do not depend on X are previously set from ~/.profile

export VIM_ORIG_WINID=$(xdotool getactivewindow)

# Display setup
if [[ ${FQDN} = ${LTOP} ]]; then
  xrandr | grep ${LTOPHDMI} | grep " connected "
  if [[ $? -eq 0 ]]; then
    xrandr --output ${LTOPEDP1} --primary --mode 1920x1080 --pos 0x1080 --rotate normal --output ${LTOP_HDMI} --mode 1920x1080 --pos -1920x0 --rotate right
  else
    xrandr --output ${LTOPEDP1} --primary --mode 1920x1080 --pos 0x0 --rotate normal --output ${LTOP_HDMI} --off
  fi
fi

if [[ ${FQDN} = ${DTOP} ]]; then
  xrandr | grep ${DTOPHDMI} | grep " connected "
  if [[ $? -eq 0 ]]; then
    xrandr --output ${DTOPDP} --primary --mode 1920x1080 --pos 0x0 --rotate normal --output ${DTOPHDMI} --mode 1920x1080 --pos -1920x0 --rotate normal
  else
    xrandr --output ${DTOPDP} --primary --mode 1920x1080 --pos 0x0 --rotate normal --output ${DTOPHDMI} --off
  fi
fi

# Additional Variables
#current_resolution=`xdpyinfo | sed -n 's/.*dim.* \([0-9]*x[0-9]*\) .*/\1/pg' | tr '\n' ' '`; # Set variable for current resolution, for use in Conky (or whatever else)

# Reload ~/.Xresources
if [[ -r ~/.Xresources ]] ; then xrdb ~/.Xresources ; fi

# keyboard auto repeat
xset r on
xset r rate 250 60

# mouse / pointing device acceleration
xset m 3 1

# System bell in X (on/off)
if [[ ${SYSBELL} = 'true' ]]; then
  xset b on
  xset +b
else
  xset b off
  xset -b
fi

# Enable or disable screen blanking.
if [[ ${BLANKING} = 'true' ]]; then
  xset s on +dpms       # allow screensaver.
  xset dpms 600 600 600 # enable DPMS (Energy Star) features.
  xset s blank          # allow blanking of the video device.
else
  xset s off -dpms   # disable screensaver.
  xset dpms 0 0 0    # disable DPMS (Energy Star) features.
  xset s noblank     # disable blanking of the video device.
fi

# Enable or disable number lock by default, depends on numlockx
if [[ -x `which numlockx` ]]; then
   if [[ ${NUMLOCK} = 'true' ]]; then numlockx on ; fi
   if [[ ${NUMLOCK} = 'false' ]]; then numlockx off ; fi
fi


# Enable or disable touchpad by default, depends on synclient.
if [[ -x `which synclient` ]]; then
  if [[ ${TOUCHPAD} = 'true' ]]; then synclient TouchpadOff=0 ; fi
  if [[ ${TOUCHPAD} = 'false' ]]; then synclient TouchpadOff=1 ; fi
fi

# Set background, depends on nitrogen or x11-server-utils
if [[ ${BACKGROUND} = 'wallpaper' ]] && [[ -x `which nitrogen` ]]; then nitrogen --restore ; fi
if [[ ${BACKGROUND} = 'solid' ]] && [[ -x `which xsetroot` ]]; then xsetroot -solid "$BACKGROUND_COLOR" ; fi

# Terminal, depends on rxvt-unicode
# if [[ -x `which urxvtd` ]]; then
#     if [[ ! $(pgrep -u $EUID -d' ' urxvtd) ]]; then
#         urxvtd --quiet --opendisplay --fork
#         urxvtc
#     else
#         kill -9 $(pgrep -u $EUID -d' ' urxvtd)
#         urxvtd --quiet --opendisplay --fork
#         urxvtc
#     fi
# fi

# MPD
# if [[ -x `which mpd` ]] && [[ ! $(pgrep -u $EUID -d' ' mpd) ]]; then mpd ; fi

# NCMPCPP, depends on rxvt-unicode, mpd, ncmpcpp
# if [[ -x `which urxvtd` ]] &&
#    [[ -x `which mpd` ]] &&
#    [[ $(pgrep -u $EUID -d' ' mpd) ]] &&
#    [[ -x `which ncmpcpp` ]]; then
#         if [[ ! $(pgrep -u $EUID -d' ' ncmpcpp) ]]; then
#             urxvtc -pe -tabbed -e ncmpcpp
#         else
#             kill -9 $(pgrep -u $EUID -d' ' urxvtd)
#             urxvtc -pe -tabbed -e ncmpcpp
#         fi
# fi

# Start X session daemons from ~/.xsession.d/
if [ -d "$HOME/.xsession.d" ]; then
  for script in "$HOME/.xsession.d/"*; do
    [ -x "$script" ] && "$script"
  done
fi
