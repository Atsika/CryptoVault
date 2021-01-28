# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.

prompt_color='\[\033[;94m\]'
info_color='\[\033[1;31m\]'
prompt_symbol=💀
PS1=$prompt_color'┌──('$info_color'\u${prompt_symbol}\h'$prompt_color')-[\[\033[0;1m\]\w'$prompt_color']\n'$prompt_color'└─'$info_color'\$\[\033[0m\] '

# umask 022

# You may uncomment the following lines if you want `ls' to be colorized:
export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'
#
# Some more alias to avoid making mistakes:
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Colorize the grep command output for ease of use (good for log files)
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

#readable output
alias df='df -h'

# Clear shortcut
alias c='clear'

# cd +ls -l
function cl () {
    cd "$1";
    ls -l    
}

# EXTRACT
ex () {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)     echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# TRASH CLI "desctivé pour le tp de linux"
alias rm="trash-put"
alias rmlist="trash-list"
alias rest="restore-trash"
alias empty="trash-empty"

# NAVIGATION
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../../../'
alias ....='cd ../../../../'
alias .....='cd ../../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../..'

# Sync history
export PROMPT_COMMAND='history -a;history -n'

# MKDIR
alias mkdir="mkdir -vp"

# SHUTDOWN/REBOOT
alias shut="shutdown now"
alias reb="reboot"

# WEB SERVER
function serv {
    declare -a state
    state=( $(ip a | grep -m1 "state UP" | awk -F" " '{print $2}' | sed 's/://g') $(ip a | grep -m1 "tun0" | awk -F" " '{print $2}' | sed 's/://g') )
    for i in "${state[@]}"
    do
       if [ ! -z "$i" ]; then
            echo "$i  $(ip a show $i | grep -w "inet" | awk -F" " '{print $2}')"
       fi
    done
    python3 -m http.server $1
}

# TASSIN3 WITH OUT SELINUX if error ==> before run "sudo setenforce 0" and after "sudo setenforce 1"
tassin3 () { 
    podman run --rm -v $HOME/.gnupg:/root/.gnupg:rw,Z -v $(pwd):/report:rw,Z -ti tassin3 "$@"
}

## GIT PUSH
push () {
    git pull && git add -A && git commit -m "commit $(date)" && git push
}

## inotifywait + tassin build dont forget do setenforce 1 when you are done
build () {
#    sudo setenforce 0
    while inotifywait -e modify ./* 
    do 
        notify-send "Building" && tassin3 build && notify-send "Finished"  
    done
}

# Xclip
alias clip='xclip -r -sel c'

# sudo
alias suod='sudo'
alias sodu='sudo'
alias sduo='suod'
alias sdou='suod'

# Path to cheat config file
export CHEAT_CONFIG_PATH="$HOME/COFFRE/MEMENTO/conf.yml"
