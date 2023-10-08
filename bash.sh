#!/bin/bash

#colors
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
rest='\033[0m'

#-------------------------------------------------------#

# root check
root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${red}Please run as root. Use [sudo -i]${rest}"
        exit 1
    fi
}

#-------------------------------------------------------#
#progress
display_progress() {
    local duration=$1
    local sleep_interval=0.1
    local progress=0
    local bar_length=40
    local colors=("[41m" "[42m" "[43m" "[44m" "[45m" "[46m" "[47m")

    while [ $progress -lt $duration ]; do
        echo -ne "\r${colors[$((progress % 7))]}"
        for ((i = 0; i < bar_length; i++)); do
            if [ $i -lt $((progress * bar_length / duration)) ]; then
                echo -ne "█"
            else
                echo -ne "░"
            fi
        done
        echo -ne "[0m ${progress}%"
        progress=$((progress + 1))
        sleep $sleep_interval
    done
    echo -ne "\r${colors[0]}"
    for ((i = 0; i < bar_length; i++)); do
        echo -ne " "
    done
    echo -ne "[0m 100%"
    echo
}

#apt upgrade -y > /dev/null 2>&1 &
#pid=$!
#display_progress 10
#wait "$pid"

#-------------------------------------------------------#

#logo
logo_animated() {
  colors=("\e[92m" "\e[91m" "\e[93m" "\e[94m" "\e[95m" "\e[96m" "\e[93m" "\e[96m")
  NC="\e[0m"
  for color in "${colors[@]}"; do
    clear
    echo -e "\n${color}
        ___         ___      ___         ___         ___         ___              
       /\  \       /\  \    |\__\       /\__\       /\  \       /\__\             
      /::\  \     /::\  \   |:|  |     /::|  |     /::\  \     /::|  |            
     /:/\:\  \   /:/\:\  \  |:|  |    /:|:|  |    /:/\:\  \   /:|:|  |            
    /::\~\:\  \ /::\~\:\  \ |:|__|__ /:/|:|__|__ /::\~\:\  \ /:/|:|  |__          
   /:/\:\ \:\__/:/\:\ \:\__\/::::\__/:/ |::::\__/:/\:\ \:\__/:/ |:| /\__\         
   \/__\:\/:/  \:\~\:\ \/__/:/~~/~  \/__/~~/:/  \/__\:\/:/  \/__|:|/:/  /         
        \::/  / \:\ \:\__\/:/  /          /:/  /     \::/  /    |:/:/  /          
         \/__/   \:\ \/__/\/__/          /:/  /      /:/  /     |::/  /           
                  \:\__\                /:/  /      /:/  /      /:/  /            
                   \/__/                \/__/       \/__/       \/__/             
                                                                                
   ${R}\n"
    sleep 0.2
  done
}

#-------------------------------------------------------#

#dependencies
dependencies() {
  if command -v apt-get &> /dev/null; then
    package_manager="apt"
  elif command -v yum &> /dev/null; then
    package_manager="yum"
  elif command -v dnf &> /dev/null; then
    package_manager="dnf"
  else
    echo "Unsupported package manager. Exiting..."
    exit 1
  fi

  programs=("wget" "curl" "nano")

  for program in "${programs[@]}"; do
    if ! command -v "$program" &> /dev/null; then
      echo "$program is not installed. Installing..."
      sudo "$package_manager" install -y "$program"
    else
      echo "$program installed."
    fi
  done
}

update() {
    dependencies
    "$package_manager" update -y
}