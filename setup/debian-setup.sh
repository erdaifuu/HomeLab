#!/bin/bash

### CONSTANTS ###
BLUE='\033[0;34m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Chapan Post-Install Setup Script v1.0"

echo -e "⚠️  ${RED}WARNING ⚠️
This script will overwrite several files in the home directory (such as .zshrc).
Make sure to read the script carefully before running!${NC}
Enter Y to proceed."
read -r
sudo echo ""
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo -e "${BLUE}Starting setup.${NC}"
    echo -e "${YELLOW}Installing apt packages...${NC}"
    sudo apt update

    ### TODO: Edit the line below to add/remove any packages you desire
    sudo apt install -y nfs-common qemu-guest-agent kitty fish ruby ruby-dev build-essential bat nodejs npm man vim neovim

    echo -e "${YELLOW}Installing CLI tools...${NC}"

    ### TODO: Uncomment to disable ipv6 if necessary
    # sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
    # sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1 
    # sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1

    echo -e "${YELLOW}Installing Docker Compose...${NC}"
    
    if docker compose; then
        echo -e "${GREEN}✅ Docker v2 already on system, skipping install.${NC}"
    else
        if docker-compose; then
            echo -e "${RED} Docker Compose v1 installed, removing v1...${NC}"
            sudo apt remove docker docker-compose
        fi
        
        echo "Docker Compose not configured. Configuring..."
        # Add Docker's official GPG key:
        sudo apt-get update
        sudo apt-get install ca-certificates curl
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc

        # Add the repository to Apt sources:
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
          $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
          sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update

        echo "Installing..."
        sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        
        echo -e "${GREEN}✅ Docker Compose configured${NC}"
    fi
    
    echo -e "${GREEN}✅ Packages installed${NC}"

    echo -e "${YELLOW}Joining ZeroTier...${NC}"
    if sudo zerotier-cli info; then
        echo -e "${GREEN}✅ Zerotier already running, skipping install.${NC}"
    else
        echo "ZeroTier not configured. Installing..."
        curl -s https://install.zerotier.com | sudo bash

        sudo zerotier-cli join 8056c2e21c1c47ce
        echo -e "${YELLOW} 🚩 Awaiting approval. Go to https://my.zerotier.com/network/8056c2e21c1c47ce and check the box next to this device.
Press enter when complete.${NC}"

        read -r
        sudo zerotier-cli info
        echo -e "${GREEN}✅ Zerotier configured${NC}"
    fi

    echo -e "${YELLOW}Configuring git...${NC}"

    git config --global erdaifuu@gmail.com "EMAIL"
    git config --global erdaifuu "NAME"

    # echo -e "${YELLOW}Configuring prometheus node-exporter:${NC}"
    # sudo docker network ls|grep monitoring > /dev/null || sudo docker network create --driver bridge monitoring
    # sudo docker-compose --project-directory ../monitoring/node-exporter up -d --force-recreate
    # echo -e "${GREEN}✅ node_exporter installed${NC}"

    echo -e "${YELLOW}Configuring fish...${NC}"

    # Setting the default file as fish by adding fish to the last line in bashrc
    echo "fish" >> ~/.bashrc


    echo -e "${YELLOW}Adding files...${NC}"
    # Setting the default file as fish by adding fish to the last line in bashrc
    mv docker-compose.yml ~/docker-compose.yml
   
    ### TODO: Review the included .zshrc and uncomment the lines below
    # echo -e "${YELLOW}Installing oh-my-zsh...${NC}"

    # cp .zshrc ~/.zshrc
    # if [ -d "$HOME/.oh-my-zsh" ]; then
    #     echo -e "${GREEN}✅ .oh-my-zsh/ already exists, skipping install. (Remove the folder to re-install)${NC}"
    # else
    #     sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    #     git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    #     git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    #     sudo cp .p10k.zsh ~/.p10k.zsh
    #     chsh -s $(which zsh)
    # fi

    echo -e "${GREEN}🎉 SETUP COMPLETE!! 🎉"
    fish
else
    echo -e "${RED}Cancelling setup.${NC}"
fi
