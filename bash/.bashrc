source ~/.local/share/omakub/defaults/bash/rc

# Editor used by CLI
export EDITOR="nvim"
export SUDO_EDITOR="$EDITOR"

export MESA_D3D12_DEFAULT_ADAPTER_NAME=NVIDIA

source ~/.aliases
eval "$(starship init bash)"
if [[ -z "$ZELLIJ" ]]; then
  if [[ "$ZELLIJ_AUTO_ATTACH" == "true" ]]; then
    zellij attach -c
  else
    zellij
  fi

  if [[ "$ZELLIJ_AUTO_EXIT" == "true" ]]; then
    exit
  fi
fi
