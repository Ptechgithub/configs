#!/bin/bash

# Function to check if MikroTik is installed and install it if not
install_or_check_mikrotik() {
    if docker ps -a --format '{{.Names}}' | grep -q "^livekadeh_com_mikrotik7_7$"; then
        echo "MikroTik is already installed."
    else
        sudo apt-get update -y

        # Check if Docker is installed
        if ! command -v docker &> /dev/null; then
            sudo apt-get install -y curl
            curl -fsSL https://get.docker.com -o get-docker.sh
            sudo sh get-docker.sh
        fi

        # Download the Docker image if it doesn't exist
        [ ! -f "Docker-image-Mikrotik-7.7-L6.7z" ] && wget https://github.com/Ptechgithub/MIKROTIK/releases/download/L6/Docker-image-Mikrotik-7.7-L6.7z

        read -p "Do you want to add additional ports to the MikroTik container? (y/n): " add_ports

        if [ "$add_ports" == "y" ]; then
            read -p "Enter a comma-separated list of additional ports (example: 443,2087,9543): " additional_ports
            sudo apt-get install -y p7zip-full
            7z e Docker-image-Mikrotik-7.7-L6.7z
            docker load --input mikrotik7.7_docker_livekadeh.com

            IFS=',' read -ra ports_array <<< "$additional_ports"
            port_mappings=""

            for port in "${ports_array[@]}"; do
                port_mappings+=" -p $port:$port"
            done

            docker run --cap-add=NET_ADMIN --device=/dev/net/tun -d --name livekadeh_com_mikrotik7_7 -p 8291:8291 -p 80:80 $port_mappings -ti livekadeh_com_mikrotik7_7
            docker attach livekadeh_com_mikrotik7_7
        else
            docker run --cap-add=NET_ADMIN --device=/dev/net/tun -d --name livekadeh_com_mikrotik7_7 -p 8291:8291 -p 80:80 -ti livekadeh_com_mikrotik7_7
            docker attach livekadeh_com_mikrotik7_7
        fi
    fi
}

# Function to uninstall MikroTik
uninstall_mikrotik() {
    if docker ps -a --format '{{.Names}}' | grep -q "^livekadeh_com_mikrotik7_7$"; then
        if docker ps | grep -q livekadeh_com_mikrotik7_7; then
            docker stop livekadeh_com_mikrotik7_7
        fi
        docker rm livekadeh_com_mikrotik7_7
        docker rmi livekadeh_com_mikrotik7_7
        rm Docker-image-Mikrotik-7.7-L6.7z
        echo "MikroTik has been uninstalled."
    else
        echo "MikroTik is not installed."
    fi
}

display_menu() {
    clear
    echo "Select an option:"
    echo "1) Install MikroTik"
    echo "2) Uninstall MikroTik"
    echo "0) Exit"
}


# Display the menu and read user choice
display_menu
read -p "Enter your choice: " choice

case $choice in
    1)
        install_mikrotik
        ;;
    2)
        uninstall_mikrotik
        ;;
    0)
        exit 0
        ;;
    *)
        echo "Invalid choice. Please select a valid option."
        ;;
esac