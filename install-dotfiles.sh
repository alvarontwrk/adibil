#!/bin/sh

sudo apt update
sudo apt install -y git zsh

config() {
    git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME "$@"
}

mv .bashrc .bashrc.bak
mv .zshrc .zshrc.bak
mv .tmux.conf .tmux.conf.bak
git clone --bare https://github.com/alvarontwrk/dotfiles.git $HOME/.dotfiles
config checkout
config config --local status.showUntrackedFiles no

zshpath=$(which zsh)
sudo sed -i 's@'"$HOME"'.*@'"$HOME"':'"$zshpath"'@g' /etc/passwd

wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O /tmp/install-oh-my-zsh.sh
rm -rf $HOME/.oh-my-zsh
CHSH=yes RUNZSH=yes KEEP_ZSHRC=yes sh /tmp/install-oh-my-zsh.sh
mkdir -p .cache/zsh
touch .cache/zsh/history

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

