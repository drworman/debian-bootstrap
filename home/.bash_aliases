# ~/.bash_aliases

# Git Tools

# Synchronizes all local branches to your private git instance.
gsync() {
    ~/.local/bin/git-sync "$@"
}

# Mirrors your local repo to your private git instance.
# This is potentially destructive.
gmirror() {
    ~/.local/bin/git-mirror "$@"
}

# First runs gsync, then gmirror.
gpublish() {
    ~/.local/bin/git-publish "$@"
}

# Create an archive of a repository, following the .gitignore
gcollect() {
    ~/.local/bin/git-collect "$@"
}

# Use a template to create a new git repository and initialize it.
ginit() {
    ~/.local/bin/git-init "$@"
}

# Color ls
if [ -x /usr/bin/dircolors ]; then
    if [ -r ~/.dircolors ]; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi
    alias egrep='egrep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias grep='grep --color=auto'
    alias l='ls -CF --color=auto'
    alias la='ls -AFl --color=auto'
    alias ll='ls -alhF --color=auto'
    alias ls='ls -ACF --color=auto'
else
    alias l='ls -CF'
    alias la='ls -AFl'
    alias ll='ls -alhF'
    alias ls='ls -ACF'
fi

# Compile alias
alias compile=compile
compile() {
    g++ "$1" -o "$2"
}

# General
alias getip="dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | rev | cut -c2- | rev | cut -c2-"
alias so="source ~/.bashrc"
alias t="tmux"
alias v="vim"
alias c="clear"
alias g="grep"
alias htopu="htop -u $(whoami)"
alias quit="exit"
alias tmovie="mplayer -vo caca $1"
alias chrome="/usr/bin/google-chrome-stable"

randpass() {
  passwd=$(< /dev/urandom tr -cd "[:alnum:]" | head -c "$1")
  spchar=$(< /dev/urandom tr -cd "[:punct:]" | head -c 1)
  pos=$((RANDOM % $1))
  echo "${passwd:0:pos}${spchar}${passwd:pos+1:$1}"
}

mnt() {
  sudo mount -t auto /dev/"$1" ~/disk
  sudo chown -R "$EUID":"$EGID" ~/disk
}

mcd() {
  mkdir "$@" && cd "$_"
}

