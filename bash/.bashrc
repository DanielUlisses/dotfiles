source ~/.local/share/omarchy/default/bash/rc
export LIBVIRT_DEFAULT_URI="qemu:///system"

source /usr/share/git/completion/git-prompt.sh
PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '
export SSH_AUTH_SOCK=~/.1password/agent.sock
source ~/.aliases
