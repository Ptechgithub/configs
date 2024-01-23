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
install() {
    if [ ! -f "$PREFIX/bin/warp" ] && [ ! -f "$PREFIX/bin/usef" ]; then
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
        exit
        ;;
    *)
        echo "Invalid choice. Please select a valid option."
        ;;
esac
