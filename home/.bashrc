# ~/.bashrc

# Bail if not interactive
[[ $- != *i* ]] && return

# -------------------------
# History
# -------------------------
HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
HISTCONTROL=ignoreboth
shopt -s histappend
shopt -s checkwinsize

# -------------------------
# Prompt
# -------------------------

export PS1="[\u@\h:\w] ➜ "
# Renders as:
# [user@localhost:~/] ➜

# export PS1="┌─ \u@$(hostname -f) [\w] ──> "
# Renders as:
# ┌─ alice@localhost.domain [~/projects/demo] ──>

# export PS1="┌── \u@$(hostname -f)[\w]\n└─> "
# Renders as:
# ┌── user@localhost.domain[~/]
# └─> 

# export PS1="➜ \u@\h :: \w $ "
# Renders as:
# ➜ user@localhost :: ~/projects/demo $

# -------------------------
# Aliases and functions
# -------------------------
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# -------------------------
# Bash completion
# -------------------------
_service_fn() {
    local cur prev
    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    if [ $COMP_CWORD -eq 1 ]; then
        COMPREPLY=( $(compgen -W "$(ls /etc/init.d)" -- "$cur") )
    elif [ $COMP_CWORD -eq 2 ]; then
        COMPREPLY=( $(compgen -W "start stop restart pause zap status ineed iuse needsme usesme broken" -- "$cur") )
    else
        COMPREPLY=( $(compgen -f -- "$cur") )
    fi
    return 0
}

complete -F _service_fn service

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

complete -cf sudo
complete -cf man
complete -cf killall
complete -cf pkill
complete -cf fakeroot
complete -cf respawn
complete -cf pgrep
