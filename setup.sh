#!/bin/sh

# mkdir ~/.ssh;cp /mnt/c/Users/micha/.ssh/* ~/.ssh;cd ~ && chmod 600 ~/.ssh/* && chmod 700 ~/.ssh && chmod 644 ~/.ssh/*.pub;mkdir src; cd src; git clone git@github.com:WalkingDisaster/wth.git;cd wth;. setup.sh;

GREEN='\033[0;32m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

printf "${GREEN}Prerequisites${NC}\n"

printf "${GRAY}Required Packages${NC}"
sudo apt install unzip

printf "${GRAY}Adding Repository for Functions Core Tools${NC}"
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-$(lsb_release -cs)-prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/dotnetdev.list'

printf "${GRAY}Adding Repository for .Net SDK${NC}"
declare repo_version=$(if command -v lsb_release &> /dev/null; then lsb_release -r -s; else grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"'; fi)
wget https://packages.microsoft.com/config/ubuntu/$repo_version/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo touch /etc/apt/preferences
sudo bash -c 'cat > /etc/apt/preferences << EOL
Package: *
Pin: origin "packages.microsoft.com"
Pin-Priority: 1001
EOL'

printf "${GRAY}Adding Repository for Terraform${NC}\n"
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

printf "${GRAY}Getting Everything Current${NC}"
sudo apt update
sudo apt upgrade -y

printf "${GREEN}.Net 6${NC}\n"
sudo apt install -y dotnet-sdk-6.0

printf "${GREEN}Functions${NC}\n"
sudo apt install azure-functions-core-tools-4

printf "${GREEN}Node.js${NC}\n"
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc
nvm install --lts

# Terraform
sudo apt install terraform

printf "${GREEN}VSCode${NC}\n"
code --install-extension ms-dotnettools.vscode-dotnet-runtime
code --install-extension ms-dotnettools.csdevkit
code --install-extension ms-vscode.vscode-node-azure-pack
code --install-extension ms-vscode-remote.remote-containers
code --install-extension davidanson.vscode-markdownlint
code --install-extension gruntfuggly.todo-tree
code --install-extension HashiCorp.terraform

printf "${GREEN}Global Git settings${NC}\n"
git config --global init.defaultBranch main
git config --global user.email michael.meadows@insight.com
git config --global user.name "Michael Meadows"

printf "${GREEN}The Code${NC}\n"
mkdir ~/temp
cd ~/temp
git init
git remote add origin https://github.com/microsoft/WhatTheHack.git
git pull origin master --depth 1
cp ~/temp/015-Serverless/Student/Resources/* ~/src/wth -r
cd ~/src/wth
rm ~/temp -rfd

printf "${GREEN}Oh my ZSH${NC}\n"
sudo apt install fonts-powerline -y
sudo apt install -qq zsh -y
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
sed -i 's/robbyrussell/agnoster/g' ~/.zshrc | bash
chsh -s $(which zsh)
env zsh -l

