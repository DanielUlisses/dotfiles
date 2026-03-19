# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

source /usr/share/git/completion/git-prompt.sh
PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '
export SSH_AUTH_SOCK=~/.1password/agent.sock
source ~/.aliases

export PATH="$HOME/.local/bin:$PATH"
export ANDROID_HOME="$HOME/Android/Sdk"
