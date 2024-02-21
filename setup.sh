#!/bin/sh

# mkdir src; cd src; git clone https://github.com/WalkingDisaster/wth.git;cd wth;. setup.sh;

GREEN='\033[0;32m'
NC='\033[0m' # No Color

printf "${GREEN}Prerequisites${NC}\n"
sudo apt upgrade
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-$(lsb_release -cs)-prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/dotnetdev.list'
sudo apt update

echo "${GREEN}.Net 6${NC}\n"
sudo apt install -y dotnet-sdk-6.0

echo "${GREEN}Functions${NC}\n"
sudo apt install azure-functions-core-tools-4

echo "${GREEN}Node.js${NC}\n"
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc
nvm install --lts

echo "${GREEN}VSCode${NC}\n"
code --install-extension ms-dotnettools.vscode-dotnet-runtime
code --install-extension ms-dotnettools.csdevkit
code --install-extension ms-vscode.vscode-node-azure-pack
code --install-extension ms-vscode-remote.remote-containers
code --install-extension davidanson.vscode-markdownlint
code --install-extension gruntfuggly.todo-tree

echo "${GREEN}Global Git settings${NC}\n"
git config --global init.defaultBranch main
git config --global user.email michael.meadows@insight.com
git config --global user.name "Michael Meadows"

echo "${GREEN}SSH${NC}\n"
mkdir ~/.ssh
cp /mnt/c/Users/micha/.ssh/* ~/.ssh
cd ~ && chmod 600 ~/.ssh/* && chmod 700 ~/.ssh && chmod 644 ~/.ssh/*.pub

echo "${GREEN}Some more Git${NC}\n"
git remote remove origin
git remote add origin git@github.com:WalkingDisaster/wth.git

echo "${GREEN}The Code${NC}\n"
mkdir ~/temp
cd ~/temp
git init
git remote add origin https://github.com/microsoft/WhatTheHack.git
git pull origin master --depth 1
cp ~/temp/015-Serverless/Student/Resources/* ~/src/wth -r
rm ~/temp -rfd

echo "${GREEN}Oh my ZSH${NC}\n"
sudo apt install fonts-powerline -y
sudo apt install -qq zsh -y
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
sed -i 's/robbyrussell/agnoster/g' ~/.zshrc | bash
env zsh

