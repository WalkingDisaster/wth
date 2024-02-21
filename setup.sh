#!/bin/sh

echo Prerequisites
sudo apt-get upgrade
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-$(lsb_release -cs)-prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/dotnetdev.list'
sudo apt-get update

echo .Net 6
sudo apt-get install -y dotnet-sdk-6.0

echo Functions
sudo apt-get install azure-functions-core-tools-4

echo Node.js
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc
nvm install --lts

echo VSCode
code --install-extension ms-dotnettools.vscode-dotnet-runtime
code --install-extension ms-dotnettools.csdevkit
code --install-extension ms-vscode.vscode-node-azure-pack
code --install-extension ms-vscode-remote.remote-containers
code --install-extension davidanson.vscode-markdownlint
code --install-extension gruntfuggly.todo-tree

echo Global Git settings
git config --global init.defaultBranch main
git config --global user.email michael.meadows@insight.com
git config --global user.name "Michael Meadows"

echo SSH
mkdir ~/.ssh
cp /mnt/c/Users/micha/.ssh/* ~/.ssh
cd ~ && chmod 600 ~/.ssh/* && chmod 700 ~/.ssh && chmod 644 ~/.ssh/*.pub

echo The Code
mkdir ~/temp
cd ~/temp
git init
git remote add origin https://github.com/microsoft/WhatTheHack.git
git pull origin master --depth 1
cp ~/temp/015-Serverless/Student/Resources ~/src/wth -r
rm ~/temp -rfd

echo Oh my ZSH
sudo apt install fonts-powerline
sudo apt install zsh -y
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
omz theme set agnoster
