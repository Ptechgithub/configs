#!/bin/bash

root_access() {
    # Check if the script is running as root
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root."
        exit 1
    fi
}

detect_distribution() {
    # Detect the Linux distribution
    local supported_distributions=("ubuntu" "debian" "centos" "fedora")
    
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        if [[ "${ID}" = "ubuntu" || "${ID}" = "debian" || "${ID}" = "centos" || "${ID}" = "fedora" ]]; then
            package_manager="apt-get"
            [ "${ID}" = "centos" ] && package_manager="yum"
            [ "${ID}" = "fedora" ] && package_manager="dnf"
        else
            echo "Unsupported distribution!"
            exit 1
        fi
    else
        echo "Unsupported distribution!"
        exit 1
    fi
}

check_dependencies() {
    root_access
    detect_distribution
    local dependencies=("wget" "nano" "gunzip")
    
    for dep in "${dependencies[@]}"; do
        if ! command -v "${dep}" &> /dev/null; then
            echo "${dep} is not installed. Installing..."
            sudo "${package_manager}" install "${dep}" -y
        fi
    done
}

#Check installed service
check_installed() {
    if [ -f "/etc/systemd/system/gost.service" ]; then
        echo "The service is already installed."
        exit 1
    fi
}

install() {
    check_dependencies
    wget https://github.com/ginuerzh/gost/releases/download/v2.11.5/gost-linux-amd64-2.11.5.gz
    gunzip gost-linux-amd64-2.11.5.gz
    sudo mv gost-linux-amd64-2.11.5 /usr/local/bin/gost
    sudo chmod +x /usr/local/bin/gost
    read -p "Enter foreign IP[External-ip] : " foreign
    read -p "Enter Port :" port
    cd /etc/systemd/system
    
    cat <<EOL>> gost.service
[Unit]
Description=GO Simple Tunnel
After=network.target
Wants=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/gost -L=tcp://:$port/$foreign:$port

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload
sudo systemctl enable gost.service
sudo systemctl start gost.service

}


uninstall() {
    if ! command -v gost &> /dev/null
    then
        echo "Gost is not installed."
        return
    fi
    
    sudo systemctl stop gost.service
    sudo systemctl disable gost.service
    sudo rm /etc/systemd/system/gost.service
    sudo systemctl daemon-reload
    sudo rm /usr/local/bin/gost
    echo "GO Simple Tunnel (gost) has been uninstalled."
}



# Main menu
clear
echo "By --> Peyman * Github.com/Ptechgithub * "
echo ""
echo " --------#- Go simple Tunnel-#--------"
echo "1) Install Gost"
echo "2) Uninstall Gost"
echo " ----------------------------"
echo "0) exit"
read -p "Please choose: " choice

case $choice in

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
        echo "Invalid choice. Please try again."
        ;;
esac