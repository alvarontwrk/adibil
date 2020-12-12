#!/bin/bash

# IF I DO EVERYTHING WITH SUDO, ALL FILES WILL BE OWNED BY ROOT
# IMPORTANT: for an unattended installation change timeout or NOPASSWD directive
# check with 'id'
# need to add zsh to /etc/passwd
echo "[adibil] Checking UID..."
shopt -s nocasematch

uid=$(id -u)
arch=$(uname -m)

if [[ $uid == 0 ]]; then
    read -p "WARNING: running as root. Continue? [y/N] " asroot
    asroot=${asroot:-n}
    if [[ $asroot == 'n' ]] || [[ $asroot == 'no' ]]; then
        echo "Installation aborted"
        exit
    fi
fi

echo "[adibil] Starting installation..."

echo "[adibil] Changin sudoers for an unattended installation..."
sudo sed -i 's/ALL$/NOPASSWD: ALL/g' /etc/sudoers

# add apt sources
# add non-free and contrib packages
echo "[adibil] Adding non-free and contrib packages to source..."
sudo sed -i 's/main/main non-free contrib/g' /etc/apt/sources.list

deb_metasploit='deb http://downloads.metasploit.com/data/releases/metasploit-framework/apt buster main'
deb_spotify='deb http://repository.spotify.com stable non-free'
deb_vbox='deb http://download.virtualbox.org/virtualbox/debian buster contrib' 
deb_docker='deb https://download.docker.com/linux/debian buster stable'

echo "[adibil] Adding extra sources..."
echo $deb_metasploit | sudo tee /etc/apt/sources.list.d/metasploit-framework.list
echo $deb_spotify | sudo tee /etc/apt/sources.list.d/spotify.list
echo $deb_vbox | sudo tee /etc/apt/sources.list.d/virtualbox.list
if [[ $arch == 'x86_64' ]]; then
    echo $deb_docker | sudo tee /etc/apt/sources.list.d/docker.list
fi

# need to add signatures
echo "[adibil] Adding apt signatures..."
sudo apt -y install gnupg2
echo "[adibil] Adding metasploit signature..."
wget -qO- https://apt.metasploit.com/metasploit-framework.gpg.key | sudo apt-key add -
echo "[adibil] Adding spotify signature..."
wget -qO- https://download.spotify.com/debian/pubkey_0D811D58.gpg | sudo apt-key add - 
echo "[adibil] Adding vbox signatures..."
wget -qO- https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo apt-key add -
wget -qO- https://www.virtualbox.org/download/oracle_vbox.asc | sudo apt-key add -
if [[ $arch == 'x86_64' ]]; then
    echo "[adibil] Adding docker signatures..."
    wget -qO- https://download.docker.com/linux/debian/gpg | sudo apt-key add
fi

# apt upgrade
echo "[adibil] Updating repositories..."
sudo apt update
echo "[adibil] Upgrading packages..."
sudo apt -y upgrade

# TODO
# install environment
# install tools
# read the packages.list file and format it for apt install
mkdir /tmp/adibil
wget -qO /tmp/adibil/packages.list https://gitlab.com/alvarontwrk/adibil/raw/master/packages.list
packages=$(grep -Eo '^.* #' /tmp/adibil/packages.list | tr -d ' #' | tr '\n' ' '\')
# for now lets skip docker and virtualbox
#packages=$(grep -v docker /tmp/adibil/packages.list | grep -Eo '^.* #' | tr -d '#' | tr '\n' ' '\')
#packages=$(echo $packages | sed 's/virtualbox-6.0//g')
# when wireshark is being installed, a blue prompt shows up, maybe --assume-yes
# skip this (or --assume-no (?))
for i in $packages; do echo "[adibil] Installing $i..."; sudo apt install -y $i; done
#sudo apt -y --ignore-missing install $packages

# get dotfiles
config() {
    git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME "$@"
}

# have to think about the ssh key: its more secure to generate a new one
# do i have to automate it?
# maybe using http for cloning and then keep warning the user to change it to
# ssh with a line of code in .zshrc
# if we use ssh here we need to accept the fingerprint: StrictHostKeyChecking no
# maybe with ssh config file
echo "[adibil] Cloning dotfiles..."
git clone --bare https://github.com/alvarontwrk/dotfiles.git $HOME/.dotfiles
echo "[adibil] Deleting previous .bashrc..."
rm .bashrc
echo "[adibil] Updating files..."
config checkout
config config --local status.showUntrackedFiles no

#echo "[adibil] Changing shell to zsh..."
zshpath=$(which zsh)
sudo sed -i 's@'"$HOME"'.*@'"$HOME"':'"$zshpath"'@g' /etc/passwd

#echo "[adibil] Changing default browser..."
#xdg-settings set default-web-browser firefox-esr.desktop

# install oh-my-zsh
echo "[adibil] Installing oh-my-zsh..."
wget -qO- https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | bash
mv .zshrc.pre-oh-my-zsh .zshrc

# set home 
# bin dicts dload mnt pic projects scripts src uni vbox
echo "[adibil] Setting home structure..."
mkdir bin dicts dload mnt pic projects src uni
git clone https://gitlab.com/alvarontwrk/scripts.git
xdg-user-dirs-update --set PICTURE $HOME/pic
xdg-user-dirs-update --set DOWNLOAD $HOME/dload

echo "[adibil] Setting wallpaper..."
script='#!/bin/bash\nfeh --bg-scale "$HOME/pic/wallpaper.jpg"' 
echo -e $script >> .fehbg
chmod +x .fehbg

echo "[adibil] Cleaning..."
rm -rf /tmp/adibil/
sudo sed -i 's/NOPASSWD: ALL$/ALL/g' /etc/sudoers

# TODO
# get own scripts and wallpaper (where?)
# disable useless services
# add user to groups (wireshark, docker(if docker))
# create symbolic links in ~/bin
# it would be interesting to have it integrated with lyo so it automatically
# copies the sshkey between the systems
# have to setup compose key
# for now lets keep it simple and just perform a basic installation (?)
