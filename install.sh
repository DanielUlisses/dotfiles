#!/usr/bin/env bash

#this script is ready for debian based distros

#parameters
packages_linux="apt-transport-https ca-certificates git gnupg-agent curl software-properties-common jq make zip unzip zsh vim"
packages_codespaces="apt-transport-https ca-certificates git gnupg-agent curl software-properties-common jq make zip unzip zsh vim"
packages_docker="apt-transport-https ca-certificates git gnupg-agent curl software-properties-common jq make  zip unzip zsh vim"
packages_wsl="apt-transport-https ca-certificates git gnupg-agent curl software-properties-common jq make zip unzip zsh vim wslu"
username=danielulisses
email=$username@outlook.com

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


get_platform(){
    PLATFORM="LINUX"
    if grep -q docker /proc/1/cgroup; then 
    PLATFORM="DOCKER"
    echo $PLATFORM
    return 0
    fi

    if [[ "$(uname -r)" == *microsoft* ]]; then 
    PLATFORM="WSL"
    echo $PLATFORM
    return 0
    fi

    if [[ "$(uname -r)" == *azure* ]]; then 
    PLATFORM="CODESPACES"
    echo $PLATFORM
    return 0
    fi

    echo $PLATFORM
    return 0
}

PLATFORM=$(get_platform)

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
    mkdir $HOME/.config
    find . -name '.*' -type f -exec ln -sf "$SCRIPT_DIR/{}" "$HOME/{}" \;    
}

antibody_install() {
    curl -sfL git.io/antibody | sudo sh -s - -b /usr/local/bin
    antibody bundle < $SCRIPT_DIR/zsh_plugins > $HOME/.zsh_plugins.zsh
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
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USER
    sudo curl -sL -o /usr/local/bin/docker-compose $(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep "browser_download_url.*$(uname -s | awk '{print tolower($0)}')-$(uname -m)" | grep -v sha | cut -d: -f2,3 | tr -d \")
    sudo chmod +x /usr/local/bin/docker-compose
}

docker_autostart_wsl() {
    sudo ln -sf $SCRIPT_DIR/wsl.conf /etc/wsl.conf
}

wsl_configure() {
    sudo cp $SCRIPT_DIR/.wslconfig "${windowsUserProfile}/.wslconfig"
}

fonts_install() {
    ln -sf $SCRIPT_DIR/fonts/* $HOME/.fonts
    fc-cache -f -v
}

ccedil() {
    sudo echo GTK_IM_MODULE=cedilla >> /etc/environment
}

change_shell() {
    chsh -s $(which zsh)
}

case $PLATFORM in
"LINUX")
    echo "Linux dotfiles Installation"
    aptintall "$packages_linux"
    read -p "Download the ssh-backup.tar.gz to downloads folder and press enter to continue"
    ssh_configure
    dotfiles_install
    githubcli_setup
    antibody_install
    docker_setup
    fonts_install
    ccedil
    change_shell
    ;;
"CODESPACES")
    echo "Codespaces dotfiles Installation"
    aptintall "$packages_codespaces"
    dotfiles_install
    antibody_install
    ;;
"DOCKER")
    echo "Docker dotfiles Installation"
    aptintall "$packages_docker"
    dotfiles_install
    antibody_install
    ;;
"WSL")
    echo "WSL dotfiles Installation"
    aptintall "$packages_wsl"
    read -p "Download the ssh-backup.tar.gz to downloads folder and press enter to continue"
    ssh_configure
    dotfiles_install
    githubcli_setup
    antibody_install
    docker_setup
    docker_autostart_wsl
    wsl_configure
    change_shell
    ;;
*)
    echo "Error: Invalid argument $PLATFORM ."
    shift
esac