[[ -f ~/.local/share/omakub/defaults/bash/rc ]] && \
  source ~/.local/share/omakub/defaults/bash/rc || \
  source ~/.alternate_bash

# Editor used by CLI
export EDITOR="nvim"
export SUDO_EDITOR="$EDITOR"

export MESA_D3D12_DEFAULT_ADAPTER_NAME=NVIDIA

source ~/.aliases

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
