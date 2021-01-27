# Go variable
export GOPATH=$HOME/go

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$HOME/bin:/usr/local/go/bin:$HOME/go/bin:/$HOME/.local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="random"
ZSH_THEME_RANDOM_QUIET=true

HIST_STAMPS="mm/dd/yyyy"

# Useful shortcuts
alias c='clear'
alias src='source ~/.zshrc'

# Kill process by name
k () {
	kill -9 $(pgrep $1)
}

# Push faster
push () {
	git add -A && git commit -m "$1" && git push
}

alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'

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

# NeoVim
alias vim='nvim'
alias imv='nvim'
alias ivm='nvim'

# Path to cheat config file
export CHEAT_CONFIG_PATH="$HOME/COFFRE/MEMENTO/conf.yml"
