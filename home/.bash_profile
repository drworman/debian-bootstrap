# ~/.bash_profile

# Source standard profile if it exists
if [ -f "$HOME/.profile" ]; then
    . "$HOME/.profile"
fi

# -------------------------
# Environment Variables
# -------------------------

# Edit these to suit your preferences.

# numberlock status, requires setleds installed
export NUMLOCK='false'
# system beep, requirese setterm
export SYSBELL='false'
# laptop touchpad on or off, requires synaptics installed
export TOUCHPAD='false'

# Locale
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8


# Your preferred GUI web browser
export BROWSER=google-chrome

# Your preferred terminal editor
export EDITOR="vim"

# Your actual email address
export EMAIL_ADDR="user@domain.tld"

# Your GitHub Token
export GITHUB_TOKEN=""

# Your local bin directory
export LOCALBIN="$HOME/.local/bin"

# Java
export JAVA_HOME="/usr/lib/jvm/default-java"
export LD_LIBRARY_PATH="$JAVA_HOME/jre/lib/amd64"

# Preferred SDL Audio Driver
export SDL_AUDIODRIVER="alsa"

# Preferred GUI Editor
export VISUAL=vim

# Background type
export BACKGROUND='solid'

# ACPI Screen Blanking
export BLANKING='true'

# variable for your primary laptop fully qualified domain name
export LTOP='localhost.localmachine.tld'

# vars for laptop display (internal, external port)
export LTOPEDP1="eDP1"
export LTOPHDMI="HDMI2"

# variable for your primary desktop fully qualified domain name
export DTOP='localhost.localmachine.tld'

# vars for desktop video output
export DTOPDP="DP-0"
export DTOPHDMI="HDMI-0"

# Do not change these
export EGID=$(id -G | awk '{print $1}')
export FQDN=$(hostname -f)
export GPG_TTY=$(tty)
export REALNAME=$(getent passwd "$USER" | cut -d ':' -f 5 | cut -d ',' -f 1)
export XDG_SESSION_TYPE=x11
export GDK_BACKEND=x11

# -------------------------
# Host-specific overrides
# -------------------------

# Laptop specific preferences
if [[ $FQDN == "$LTOP" ]]; then
  BACKGROUND='solid'
  BLANKING='false'
  NUMLOCK='false'
  SYSBELL='false'
  TOUCHPAD='false'
fi

# Desktop specific preferences
if [[ $FQDN == "$DTOP" ]]; then
  BACKGROUND='solid'
  BLANKING='false'
  NUMLOCK='false'
  SYSBELL='false'
  TOUCHPAD='false'
fi

[[ -n "$REALNAME" ]] && export REALNAME

# -------------------------
# PATH Builder (clean + safe + automatic)
# -------------------------

# Start clean
PATH_BASE="/bin:/opt/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/games"
PATH="$PATH_BASE"

# Helper: add dir if valid and not already present
path_add() {
  local dir="$1"

  [[ -d "$dir" ]] || return

  # Skip obvious garbage
  case "$dir" in
    */.git*|*/__pycache__*|*/node_modules*|*/venv*|*/env*|*/build*|*/dist*|*/docs*)
      return
      ;;
  esac

  # Deduplicate
  [[ ":$PATH:" == *":$dir:"* ]] && return

  PATH="$PATH:$dir"
}

# Helper: only add dirs that actually contain executables
path_add_if_execs() {
  local dir="$1"

  [[ -d "$dir" ]] || return

  if find "$dir" -maxdepth 1 -type f -executable 2>/dev/null | grep -q .; then
    path_add "$dir"
  fi
}

# -------------------------
# Explicit
# -------------------------
path_add "$HOME/.local/bin"

# -------------------------
# Smart discovery (shallow only)
# -------------------------

# Scan first-level subdirs of ~/.local/bin
for d in "$HOME/.local/bin"/*; do
  path_add_if_execs "$d"
done

# Targeted deeper scan (ONLY where it makes sense)
# path_add_if_execs "$HOME/.local/bin/"

# -------------------------
# Export
# -------------------------
export PATH

# Disable system beep if SYSBELL=false
if [ "$SYSBELL" = "true" ]; then
    setterm -blength 100
else
    setterm -blength 0
fi

# Numlock
if [ "$NUMLOCK" = "true" ]; then
    setleds +num < /dev/tty$(fgconsole)
else
    setleds -num < /dev/tty$(fgconsole)
fi

# GNOME keyring
eval $(gnome-keyring-daemon --components=pkcs11,secrets,gpg --start)
export GNOME_KEYRING_CONTROL GNOME_KEYRING_PID

# SSH keychain
KEYS=$(find ~/.ssh -maxdepth 1 -type f ! -name "authorized_keys*" ! -name "*.pub" ! -name "known_hosts" ! -name "allowed_signers" ! -name "config" -printf "%f ")

if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(keychain --eval --quiet $KEYS)"
fi

source ~/.keychain/$HOSTNAME-sh

# -------------------------
# Source bashrc for interactive shells
# -------------------------
if [ -n "$BASH_VERSION" ] && [[ $- == *i* ]]; then
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# Start X automatically on tty1
if [[ -z "$DISPLAY" && $(tty) == /dev/tty1 ]]; then
    startx
    logout
fi
