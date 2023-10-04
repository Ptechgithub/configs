#!/bin/bash

detect_distribution() {
    # Detect the Linux distribution
    local supported_distributions=("ubuntu" "debian" "centos" "fedora")
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        if [[ "${ID}" = "ubuntu" || "${ID}" = "debian" || "${ID}" = "centos" || "${ID}" = "fedora" ]]; then
            PM="apt-get"
            [ "${ID}" = "centos" ] && PM="yum"
            [ "${ID}" = "fedora" ] && PM="dnf"
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
    detect_distribution
    local dependencies=("docker-compose" "curl")
    for dep in "${dependencies[@]}"; do
        if ! command -v "${dep}" &> /dev/null; then
            echo "${dep} is not installed. Installing..."
            sudo "$PM" update -y
            sudo "${PM}" install "${dep}" -y
        fi
    done
}

install_docker() {
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
        echo "Docker is not installed. Installing..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo systemctl start docker
        sudo systemctl enable docker
    else
        echo "Docker is installed."
    fi
}

install() {
    check_dependencies
    install_docker
    mkdir -p docker/wireguard
    cd docker/wireguard

    read -p "Enter server IP: " IP
    read -p "Enter Tcp Port (default is : 51821): " Tcp_Port
    Tcp_Port=${Tcp_Port:-51821}
    read -p "Enter Udp Port (default is : 51820): " Udp_Port
    Udp_Port=${Udp_Port:-51820}
    read -p "Enter Password: " PASSWORD
    read -p "Enter DNS (default is : 1.1.1.1) : " DNS
    DNS=${DNS:-1.1.1.1}
    cat <<EOL > docker-compose.yml
version: "3.8"
services:
 wg-easy:
   environment:
     - WG_HOST=$IP
     - PASSWORD=$PASSWORD
     - WG_PORT=$Udp_Port
     - WG_DEFAULT_ADDRESS=10.8.0.x
     - WG_DEFAULT_DNS=$DNS
     - WG_MTU=1420
     # - WG_ALLOWED_IPS=192.168.15.0/24, 10.0.1.0/24
     # - WG_PRE_UP=echo "Pre Up" > /etc/wireguard/pre-up.txt
     # - WG_POST_UP=echo "Post Up" > /etc/wireguard/post-up.txt
     # - WG_PRE_DOWN=echo "Pre Down" > /etc/wireguard/pre-down.txt
     # - WG_POST_DOWN=echo "Post Down" > /etc/wireguard/post-down.txt

   image: weejewel/wg-easy
   container_name: wg-easy
   volumes:
     - .:/etc/wireguard
   ports:
     - "$Udp_Port:51820/udp"
     - "$Tcp_Port:51821/tcp"
   restart: always
   cap_add:
     - NET_ADMIN
     - SYS_MODULE
   sysctls:
     - net.ipv4.ip_forward=1
     - net.ipv4.conf.all.src_valid_mark=1
EOL

docker-compose up -d
echo "The installation is finished"
}

uninstall() {
    echo "Uninstalling..."
    
    container_id=$(docker ps -qf "ancestor=weejewel/wg-easy")
    
    if [ -n "$container_id" ]; then
        echo "Stopping the container..."
        docker stop "$container_id"
        echo "Container stopped successfully."
        
        echo "Removing the container..."
        docker rm "$container_id"
        echo "Container removed successfully."
    else
        echo "No container found with image 'weejewel/wg-easy'."
    fi
    
    cd /docker/wireguard
    docker-compose down
    cd /docker
    rm -rf wireguard
    
    echo "Uninstall completed."
}

# Main menu
clear
echo "By --> Peyman * Github.com/Ptechgithub * "
echo ""
echo " --------#- Wireguard-#--------"
echo "1) Install"
echo "2) Uninstall"
echo "0) Exit"
read -p "Enter your choice: " choice

case $choice in
    1)
        install
        ;;
    2)
        uninstall
        ;;
    0)
        exit 0
        ;;
    *)
        echo "Invalid choice. Please select a valid option."
        ;;
esac