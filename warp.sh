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
            echo "${dep} is not installed. Installing..."
            pkg install "${dep}" -y
        fi
    done
}

#Download warp Core
download-warp() {
    if [ ! -f "$PREFIX/bin/usef" ] && [ ! -f "$PREFIX/bin/warp" ]; then
        pkg update -y && pkg upgrade -y
        check_dependencies
        git clone https://github.com/uoosef/warp-go.git
        cd warp-go
        go build main.go
        chmod +x main
        cp main "$PREFIX/bin/usef"
        cp main "$PREFIX/bin/warp"
        echo "warp installed successfully."
    else
        echo "warp is already installed."
    fi
}

#Uninstall
uninstall() {
    directory="/data/data/com.termux/files/home/wireguard-go"
    if [ -d "$directory" ]; then
        rm -rf "$directory"
        rm "$PREFIX/bin/usef" "$PREFIX/bin/warp" 
        echo -e "${red}Uninstallation completed.${rest}"
    else
        echo -e "${red}Not installed.Please Install First.${rest}"
    fi
}

#menu
clear
echo -e "${green}By --> Peyman * Github.com/Ptechgithub * ${rest}"
echo -e "${yellow}[https://github.com/uoosef/wireguard-go]${rest}"
echo ""
echo -e "${cyan}-- Warp in Termux--${rest}"
echo ""
echo -e "${yellow}Select an option:${rest}"
echo -e "${purple}1)${rest} ${green}Install WireGuard VPN (warp)${rest}"
echo ""
echo -e "${purple}2)${rest} ${green}Uninstall${rest}"
echo ""
echo -e "${red}0)${rest} ${green}Exit${rest}"
read -p "Please enter your selection [1-2]: :" choice

case "$choice" in
   1)
        install
        ;;
    2)
        uninstall
        ;;
    0)   
        exit
        ;;
    *)
        echo "Invalid choice. Please select a valid option."
        ;;
esac
