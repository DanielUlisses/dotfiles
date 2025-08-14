#!/bin/bash

set -e

function exit_with_message() {
  echo $1
  exit 1
}

#this script is ready for debian based distros
packages_linux="apt-transport-https build-essential libssl-dev ca-certificates git gnupg-agent curl software-properties-common jq make zip unzip bpytop htop gcc fzf cmake clang gettext ripgrep tree wget"
packages_additional=""

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

while [ $# -gt 0 ]; do
  case "$1" in
  --install-packages)
    INSTALL=$2
    shift
    ;;
  --install-additional)
    INSTALL_ADDITIONAL=$2
    shift
    ;;
  --setup-ssh)
    SETUP_SSH=$2
    shift
    ;;
  --setup-dotfiles)
    SETUP_DOTFILES=$2
    shift
    ;;
  --setup-starship)
    SETUP_STARSHIP=$2
    shift
    ;;
  --setup-omakub)
    SETUP_OMAKUB=$2
    shift
    ;;
  --setup-docker)
    SETUP_DOCKER=$2
    shift
    ;;
  --setup-github-cli)
    SETUP_GITHUB_CLI=$2
    shift
    ;;
  --install-nerd-fonts)
    INSTALL_NERD_FONTS=$2
    shift
    ;;
  --change-ccedil)
    CHANGE_CEDILLA=$2
    shift
    ;;
  *)
    echo "Running default options"
    DEFAULT=true
    ;;
  esac
  shift
done

aptintall() {
  packages=$1
  sudo apt install -y $packages
}

omakub_install() {
  export OMAKUB_FIRST_RUN_LANGUAGES=""
  export OMAKUB_FIRST_RUN_DBS=""
  wget -qO- https://omakub.org/install | bash
}

ssh_configure() {
  tar -xzf $HOME/Downloads/ssh-backup.tar.gz -C $HOME
  [[ ! -d $HOME/.ssh ]] && mkdir -p $HOME/.ssh
  mv $HOME/.ssh-backup/* $HOME/.ssh
  chmod 700 $HOME/.ssh
  chmod 600 $HOME/.ssh/*
  chmod 644 $HOME/.ssh/*.pub
}

dotfiles_install() {
  sudo apt update
  sudo apt install -y stow
  [[ -f $HOME/.gitconfig ]] && mv $HOME/.gitconfig $HOME/.gitconfig.bak
  [[ -f $HOME/.bashrc ]] && mv $HOME/.bashrc $HOME/.bashrc.bak
  [[ -f $HOME/.aliases ]] && mv $HOME/.aliases $HOME/.aliases.bak
  stow -v bash
  stow -v git --dotfiles
}

starship_install() {
  curl -fsSL https://starship.rs/install.sh | sh
  echo 'eval "$(starship init bash)"' >>$HOME/.bashrc
  eval "$(starship init bash)"
}

fonts_install() {
  [[ ! -d $HOME/.fonts ]] && mkdir -p $HOME/.fonts || echo "fonts directory available"
  ln -sf $SCRIPT_DIR/fonts/* $HOME/.fonts
  fc-cache -f -v
}

ccedil() {
  sudo echo GTK_IM_MODULE=cedilla >>/etc/environment
}

change_shell() {
  chsh -s $(which bash)
}

echo "executing default actions"
# omakub_install
# starship_install
dotfiles_install

if [ $INSTALL ]; then
  echo "installing packages " $packages_linux
  aptintall "$packages_linux"
  # change_shell
fi

if [ $INSTALL_ADDITIONAL ]; then
  echo "installing additional packages"
  aptintall "$packages_additional"
  devcontainer-cli
  # nodejs_nvm_setup
  # nvim_install
  # tmuxifier_install
#		kitty_install
fi

if [ $SETUP_DOTFILES ]; then
  echo "setting up dotfiles"
  dotfiles_install
fi

if [ $SETUP_STARSHIP ]; then
  echo "setting up starship"
  starship_install
fi

if [ $SETUP_OMAKUB ]; then
  echo "setting up omakub"
  omakub_install
fi

if [ $SETUP_SSH ]; then
  echo "setting up ssh"
  ssh_configure
fi

if [ $SETUP_DOCKER ]; then
  echo "setting up docker"
  docker_setup
fi

if [ $SETUP_GITHUB_CLI ]; then
  echo "setting up github cli"
  githubcli_setup
fi

if [ $INSTALL_NERD_FONTS ]; then
  echo "installing nerd fonts"
  fonts_install
fi

if [ $CHANGE_CEDILLA ]; then
  echo "changing cedilla"
  ccedil
fi

echo "all steps are completed!!!"
