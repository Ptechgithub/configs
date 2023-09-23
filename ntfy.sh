#!/bin/bash

setup_certificate() {
    # Ask the user if they want to use a domain
    read -p "Do you want to use a (domain/https)? (yes/no): " ANSWER

    if [ "$ANSWER" = "yes" ]; then
        # Ask for domain and port
        read -p "Enter your domain name: " DOMAIN
        read -p "Enter the port for certificate validation (default is 80): " PORT
        PORT="${PORT:-80}"

        apt install certbot -y
        echo "GET certificates for $DOMAIN on port $PORT"

        sudo certbot certonly --standalone --agree-tos --register-unsafely-without-email -d $DOMAIN --preferred-challenges http-01 --http-01-port $PORT

        echo "Setting up permissions for $DOMAIN"

        chmod 0755 /etc/letsencrypt/
        chmod 0711 /etc/letsencrypt/live/
        chmod 0750 "/etc/letsencrypt/live/$DOMAIN/"
        chmod 0711 /etc/letsencrypt/archive/
        chmod 0750 "/etc/letsencrypt/archive/$DOMAIN/"
        chmod 0640 "/etc/letsencrypt/archive/$DOMAIN/"*.pem
        chmod 0640 "/etc/letsencrypt/archive/$DOMAIN/privkey"*.pem

        chown root:root /etc/letsencrypt/
        chown root:root /etc/letsencrypt/live/
        chown root:ntfy "/etc/letsencrypt/live/$DOMAIN/"
        chown root:root /etc/letsencrypt/archive/
        chown root:ntfy "/etc/letsencrypt/archive/$DOMAIN/"
        chown root:ntfy "/etc/letsencrypt/archive/$DOMAIN/"*.pem
        chown root:ntfy "/etc/letsencrypt/archive/$DOMAIN/privkey"*.pem

        echo "Permissions successfully set for $DOMAIN. Enjoy!"
    else
        echo "Domain usage canceled. Exiting..."
    fi
}

# Function to install ntfy
install_ntfy() {
  # Create a directory for apt keyrings
  sudo mkdir -p /etc/apt/keyrings

  # Download and add the GPG key for the Heckel repository
  curl -fsSL https://archive.heckel.io/apt/pubkey.txt | sudo gpg --dearmor -o /etc/apt/keyrings/archive.heckel.io.gpg

  # Install the apt-transport-https package
  sudo apt install apt-transport-https

  # Add the Heckel repository to sources.list.d
  sudo sh -c "echo 'deb [arch=amd64 signed-by=/etc/apt/keyrings/archive.heckel.io.gpg] https://archive.heckel.io/apt debian main' \
  > /etc/apt/sources.list.d/archive.heckel.io.list"

  # Update the package list
  sudo apt update -y

  # Install ntfy
  sudo apt install ntfy
  sudo mv /etc/ntfy/server.yml /etc/ntfy/server.yml.bak
  # Download the new server.yml from the given URL and save it in /etc/ntfy/
  sudo curl -fsSL -o /etc/ntfy/server.yml https://raw.githubusercontent.com/Ptechgithub/configs/main/server.yml
  setup_certificate
  # Enable and start the ntfy service
  sudo systemctl daemon-reload
  sudo systemctl enable ntfy
  sudo systemctl start ntfy
  echo "ntfy has been installed."
}

# Function to uninstall ntfy
uninstall_ntfy() {
  # Stop and disable the ntfy service
  sudo systemctl daemon-reload
  sudo systemctl stop ntfy
  sudo systemctl disable ntfy

  # Remove ntfy package
  sudo apt remove ntfy --purge -y
  sudo rm -rf /etc/ntfy
  sudo rm -rf /etc/apt/keyrings
  # Remove the Heckel repository file
  sudo rm -f /etc/apt/sources.list.d/archive.heckel.io.list

  echo "ntfy has been uninstalled."
}

# Main menu
clear
echo "Select an option:"
echo "1) Install ntfy"
echo "2) Uninstall ntfy"
read -p "Enter your choice: " choice

case $choice in
  1)
    install_ntfy
    ;;
  2)
    uninstall_ntfy
    ;;
  *)
    echo "Invalid choice"
    ;;
esac