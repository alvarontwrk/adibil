#!/bin/sh

sudo apt update
sudo apt install -y git zsh

config() {
    git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME "$@"
}

git clone --bare https://github.com/alvarontwrk/dotfiles.git $HOME/.dotfiles
mv .bashrc .bashrc.bak
config checkout
config config --local status.showUntrackedFiles no

zshpath=$(which zsh)
sudo sed -i 's@'"$HOME"'.*@'"$HOME"':'"$zshpath"'@g' /etc/passwd

wget -qO- https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | bash --keep-zshrc
mv .zshrc.pre-oh-my-zsh .zshrc
mkdir -p .cache/zsh
touch .cache/zsh/history

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

