#!/bin/bash

# Function to check if wget is installed, and install it if not
check_dependencies() {
    if ! command -v wget &> /dev/null; then
        echo "wget is not installed. Installing..."
        sudo apt-get install wget
    fi
}

#Check installed service
check_installed() {
    if [ -f "/etc/systemd/system/tunnel.service" ]; then
        echo "The service is already installed."
        exit 1
    fi
}

update_services() {
    # Get the current installed version of RTT
    installed_version=$(./RTT -v 2>&1 | grep -o '"[0-9.]*"')

    # Fetch the latest version from GitHub releases
    latest_version=$(curl -s https://api.github.com/repos/radkesvat/ReverseTlsTunnel/releases/latest | grep -o '"tag_name": "[^"]*"' | cut -d":" -f2 | sed 's/["V ]//g' | sed 's/^/"/;s/$/"/')

    # Compare the installed version with the latest version
    if [[ "$latest_version" > "$installed_version" ]]; then
        echo "Updating to $latest_version (Installed: $installed_version)..."
        if sudo systemctl is-active --quiet tunnel.service; then
            echo "tunnel.service is active, stopping..."
            sudo systemctl stop tunnel.service > /dev/null 2>&1
        elif sudo systemctl is-active --quiet lbtunnel.service; then
            echo "lbtunnel.service is active, stopping..."
            sudo systemctl stop lbtunnel.service > /dev/null 2>&1
        fi

        # Download and run the installation script
        wget "https://raw.githubusercontent.com/radkesvat/ReverseTlsTunnel/master/install.sh" -O install.sh && chmod +x install.sh && bash install.sh

        # Start the previously active service
        if sudo systemctl is-active --quiet tunnel.service; then
            echo "Restarting tunnel.service..."
            sudo systemctl start tunnel.service > /dev/null 2>&1
        elif sudo systemctl is-active --quiet lbtunnel.service; then
            echo "Restarting lbtunnel.service..."
            sudo systemctl start lbtunnel.service > /dev/null 2>&1
        fi

        echo "Service updated and restarted successfully."
    else
        echo "You have the latest version ($installed_version)."
    fi
}

# Function to download and install RTT
install_rtt() {
    wget "https://raw.githubusercontent.com/radkesvat/ReverseTlsTunnel/master/install.sh" -O install.sh && chmod +x install.sh && bash install.sh
}

# Function to configure arguments based on user's choice
configure_arguments() {
    read -p "Which server do you want to use? (Enter '1' for Iran or '2' for Kharej) : " server_choice
    read -p "Please Enter SNI (default : splus.ir): " sni
    sni=${sni:-splus.ir}

    if [ "$server_choice" == "2" ]; then
        read -p "Please Enter (IRAN IP) : " server_ip
        read -p "Please Enter Password (Please choose the same password on both servers): " password
        arguments="--kharej --iran-ip:$server_ip --iran-port:443 --toip:127.0.0.1 --toport:multiport --password:$password --sni:$sni --terminate:24"
    elif [ "$server_choice" == "1" ]; then
        read -p "Please Enter Password (Please choose the same password on both servers): " password
        arguments="--iran --lport:23-65535 --sni:$sni --password:$password --terminate:24"
    else
        echo "Invalid choice. Please enter '1' or '2'."
        exit 1
    fi
}

# Function to handle installation
install() {
    check_dependencies
    check_installed
    install_rtt
    # Change directory to /etc/systemd/system
    cd /etc/systemd/system

    configure_arguments

    # Create a new service file named tunnel.service
    cat <<EOL > tunnel.service
[Unit]
Description=my tunnel service

[Service]
User=root
WorkingDirectory=/root
ExecStart=/root/RTT $arguments
Restart=always

[Install]
WantedBy=multi-user.target
EOL

    # Reload systemctl daemon and start the service
    sudo systemctl daemon-reload
    sudo systemctl start tunnel.service
    sudo systemctl enable tunnel.service
}

check_lbinstalled() {
    if [ -f "/etc/systemd/system/lbtunnel.service" ]; then
        echo "The Load-balancer is already installed."
        exit 1
    fi
}

# Function to configure arguments2 based on user's choice
configure_arguments2() {
    read -p "Which server do you want to use? (Enter '1' for Iran or '2' for Kharej) : " server_choice
    read -p "Please Enter SNI (default : splus.ir): " sni
    sni=${sni:-splus.ir}

    if [ "$server_choice" == "2" ]; then
        read -p "Is this your main server (VPN server)? (yes/no): " is_main_server
        read -p "Please Enter (IRAN IP) : " server_ip
        read -p "Please Enter Password (Please choose the same password on both servers): " password

        if [ "$is_main_server" == "yes" ]; then
            arguments="--kharej --iran-ip:$server_ip --iran-port:443 --toip:127.0.0.1 --toport:multiport --password:$password --sni:$sni --terminate:24"
        elif [ "$is_main_server" == "no" ]; then
            read -p "Enter your main IP (VPN Server):  " main_ip
            arguments="--kharej --iran-ip:$server_ip --iran-port:443 --toip:$main_ip --toport:multiport --password:$password --sni:$sni --terminate:24"
        else
            echo "Invalid choice for main server. Please enter 'yes' or 'no'."
            exit 1
        fi

    elif [ "$server_choice" == "1" ]; then
        read -p "Please Enter Password (Please choose the same password on both servers): " password
        arguments="--iran --lport:23-65535 --password:$password --sni:$sni --terminate:24"
        
        num_ips=0
        while true; do
            ((num_ips++))
            read -p "Please enter ip server $num_ips (or type 'done' to finish): " ip

            if [ "$ip" == "done" ]; then
                break
            else
                arguments="$arguments --peer:$ip"
            fi
        done
    else
        echo "Invalid choice. Please enter '1' or '2'."
        exit 1
    fi

    echo "Configured arguments: $arguments"
}

load-balancer() {
    check_dependencies
    check_lbinstalled
    install_rtt
    # Change directory to /etc/systemd/system
    cd /etc/systemd/system
    configure_arguments2
    # Create a new service file named tunnel.service
    cat <<EOL > lbtunnel.service
[Unit]
Description=my lbtunnel service

[Service]
User=root
WorkingDirectory=/root
ExecStart=/root/RTT $arguments
Restart=always

[Install]
WantedBy=multi-user.target
EOL

    # Reload systemctl daemon and start the service
    sudo systemctl daemon-reload
    sudo systemctl start lbtunnel.service
    sudo systemctl enable lbtunnel.service
}

lb_uninstall() {
    # Check if the service is installed
    if [ ! -f "/etc/systemd/system/lbtunnel.service" ]; then
        echo "The Load-balancer is not installed."
        return
    fi

    # Stop and disable the service
    sudo systemctl stop lbtunnel.service
    sudo systemctl disable lbtunnel.service

    # Remove service file
    sudo rm /etc/systemd/system/lbtunnel.service
    sudo systemctl reset-failed
    sudo rm RTT
    sudo rm install.sh

    echo "Uninstallation completed successfully."
}

# Function to handle uninstallation
uninstall() {
    # Check if the service is installed
    if [ ! -f "/etc/systemd/system/tunnel.service" ]; then
        echo "The service is not installed."
        return
    fi

    # Stop and disable the service
    sudo systemctl stop tunnel.service
    sudo systemctl disable tunnel.service

    # Remove service file
    sudo rm /etc/systemd/system/tunnel.service
    sudo systemctl reset-failed
    sudo rm RTT
    sudo rm install.sh

    echo "Uninstallation completed successfully."
}

check_update() {
    # Get the current installed version of RTT
    installed_version=$(./RTT -v 2>&1 | grep -o '"[0-9.]*"')
    

    # Fetch the latest version from GitHub releases
    latest_version=$(curl -s https://api.github.com/repos/radkesvat/ReverseTlsTunnel/releases/latest | grep -o '"tag_name": "[^"]*"' | cut -d":" -f2 | sed 's/["V ]//g' | sed 's/^/"/;s/$/"/')

    # Compare the installed version with the latest version
    if [[ "$latest_version" > "$installed_version" ]]; then
        echo "A new version is available, please reinstall: $latest_version (Installed: $installed_version)."
    else
        echo "You have the latest version ($installed_version)."
    fi
}


#ip & version
myip=$(hostname -I | awk '{print $1}')
version=$(./RTT -v 2>&1 | grep -o 'version="[0-9.]*"')

# Main menu
clear
echo "By --> Peyman * Github.com/Ptechgithub * "
echo "Your IP is: ($myip) "
echo ""
echo " --1------#- Reverse Tls Tunnel -#--------"
echo "1) Install (Multiport)"
echo "2) Uninstall (Multiport)"
echo " ----------------------------"
echo "3) Install Load-balancer"
echo "4) Uninstall Load-balancer"
echo " ----------------------------"
echo "5) Check Update"
echo "0) Exit"
echo " --------------$version--------------"
read -p "Please choose: " choice

case $choice in
    1)
        install
        ;;
    2)
        uninstall
        ;;
    3)
        load-balancer
        ;;
    4)
        lb_uninstall
       ;;
    5) 
        update_services
        ;;
    0)
        exit
        ;;
    *)
        echo "Invalid choice. Please try again."
        ;;
esac
