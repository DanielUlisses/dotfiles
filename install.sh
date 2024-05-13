#!/bin/bash

set -e

function exit_with_message() {
		echo $1
		exit 1
}

#this script is ready for debian based distros
packages_linux="apt-transport-https build-essential libssl-dev ca-certificates git gnupg-agent curl software-properties-common jq make zip unzip zsh htop gcc fzf cmake clang gettext ripgrep tree"
packages_additional="tmux wl-clipboard"

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

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

ssh_configure() {
    tar -xzf $HOME/Downloads/ssh-backup.tar.gz -C $HOME
    [[ ! -d $HOME/.ssh ]] && mkdir -p $HOME/.ssh
    mv $HOME/.ssh-backup/* $HOME/.ssh
    chmod 700 $HOME/.ssh
    chmod 600 $HOME/.ssh/*
    chmod 644 $HOME/.ssh/*.pub
}

dotfiles_install() {
    mkdir -p $HOME/.config
    find . -name '.*' -type f -exec ln -sf "$SCRIPT_DIR/{}" "$HOME/{}" \;
}

antibody_install() {
    # curl -sfL git.io/antibody | sudo sh -s - -b /usr/local/bin
    antibody bundle < $SCRIPT_DIR/zsh_plugins > $HOME/.zsh_plugins.zsh
}

nvim_install() {
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
    tar -C /opt -xzf nvim-linux64.tar.gz
    ln -s /opt/nvim-linux64/bin/nvim /usr/bin/nvim
    git clone https://github.com/DanielUlisses/lazy.nvim ~/.config/nvim
}

nvim_clone_config() {
  if [ ! -d ~/.config/nvim ]; then
		git clone https://github.com/DanielUlisses/lazy.nvim ~/.config/nvim
	else
		git -C ~/.config/nvim pull
	fi
}

githubcli_setup() {
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt update \
    && sudo apt install gh -y
}

docker_setup() {
    # Add Docker to sources.list
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker $USER
    sudo curl -sL -o /usr/local/bin/docker-compose $(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep "browser_download_url.*$(uname -s | awk '{print tolower($0)}')-$(uname -m)" | grep -v sha | cut -d: -f2,3 | tr -d \")
    sudo chmod +x /usr/local/bin/docker-compose
}

nodejs_nvm_setup() {
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
    source ~/.bashrc
    nvm install 18
    nvm use 18
}

devcontainer-cli() {
    npm install -g @devcontainers/cli
}

fonts_install() {
    ln -sf $SCRIPT_DIR/fonts/* $HOME/.fonts
    fc-cache -f -v
}

ccedil() {
    sudo echo GTK_IM_MODULE=cedilla >> /etc/environment
}

tmuxifier_install() {
	git clone https://github.com/jimeh/tmuxifier.git ~/.tmuxifier
}

change_shell() {
    chsh -s $(which zsh)
}

echo "executing default actions"
dotfiles_install
antibody_install
nvim_clone_config

if [ $INSTALL ]; then
		echo "installing packages"
		aptintall $packages_linux
		change_shell
fi

if [ $INSTALL_ADDITIONAL ]; then
		echo "installing additional packages"
		aptintall $packages_additional
		nvim_install
		devcontainer-cli
		tmuxifier_install
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
