#!/bin/sh

echo Prerequisites
# sudo apt-get upgrade
# curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
# sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
# sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-$(lsb_release -cs)-prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/dotnetdev.list'
# sudo apt-get update

echo .Net 6
# sudo apt-get install -y dotnet-sdk-6.0

echo Functions
# sudo apt-get install azure-functions-core-tools-4

echo Node.js
# wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
# source ~/.bashrc
# nvm install --lts

echo VSCode
# code --install-extension ms-dotnettools.vscode-dotnet-runtime
# code --install-extension ms-dotnettools.csdevkit
# code --install-extension ms-vscode.vscode-node-azure-pack
# code --install-extension ms-vscode-remote.remote-containers
# code --install-extension davidanson.vscode-markdownlint
# code --install-extension gruntfuggly.todo-tree

echo The Code
mkdir ~/temp
cd ~/temp
git init
git remote add origin https://github.com/microsoft/WhatTheHack.git
git pull origin master
cp ~/temp/015-Serverless/Student/Resources ~/src/wth