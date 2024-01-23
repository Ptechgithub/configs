#!/bin/bash

#colors
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
rest='\033[0m'

#check_dependencies
check_dependencies() {
    local dependencies=("curl" "git" "golang")

    for dep in "${dependencies[@]}"; do
        if ! dpkg -s "${dep}" &> /dev/null; then
            echo -e "${yellow}${dep} is not installed. Installing...${rest}"
            pkg install "${dep}" -y
        fi
    done
}

# Install Function
install() {
    if ! command -v warp &> /dev/null && ! command -v usef &> /dev/null; then
        echo -e "${green}Installing WireGuard VPN (warp)...${rest}"
        pkg update -y && pkg upgrade -y
        check_dependencies

        if git clone https://github.com/uoosef/wireguard-go.git; then
            cd wireguard-go || exit
            if go build main.go; then
                chmod +x main
                cp main "$PREFIX/bin/usef"
                cp main "$PREFIX/bin/warp"
                echo -e "${green}Warp installed successfully.${rest}"
            else
                echo -e "${red}Error building main.go.${rest}"
            fi
        else
            echo -e "${red}Error cloning WireGuard repository.${rest}"
        fi
    else
        echo -e "${green}Warp is already installed.${rest}"
    fi
}

# Get socks config
socks() {
   echo ""
   echo -e "${green} ====Copy this Config to ${purple}V2ray${green} Or ${purple}Nekobox ${rest}==="
   echo -e "${green}socks://Og==@127.0.0.1:8086#Free Warp %28usef%29 ${rest}"
   echo ""
}

#Uninstall
uninstall() {
    directory="/data/data/com.termux/files/home/wireguard-go"
    if [ -d "$directory" ]; then
        rm -rf "$directory"
        rm "$PREFIX/bin/usef" "$PREFIX/bin/warp" 
        echo -e "${red}Uninstallation completed.${rest}"
    else
        echo -e "${yellow}______________________${rest}"
        echo -e "${red}Not installed.Please Install First.${rest}"
        echo -e "${yellow}______________________${rest}"
    fi
}

#menu
clear
echo -e "${green}By --> Peyman * Github.com/Ptechgithub * ${rest}"
echo -e "${yellow}[* https://github.com/${cyan}uoosef${yellow}/wireguard-go *]${rest}"
echo ""
echo -e "${cyan}### Warp in Termux ###${rest}"
echo ""
echo -e "${purple}1)${rest} ${green}Install WireGuard VPN (warp)${rest}"
echo ""
echo -e "${purple}2)${rest} ${green}Uninstall${rest}"
echo ""
echo -e "${red}0)${rest} ${green}Exit${rest}"
read -p "Please enter your selection [1-2] :" choice

case "$choice" in
   1)
        install
        socks
        warp
        ;;
    2)
        uninstall
        ;;
    0)
        echo -e "${cyan}Exiting...${rest}"
        exit
        ;;
    *)
        echo "Invalid choice. Please select a valid option."
        ;;
esac
