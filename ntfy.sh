#!/bin/bash

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

  # Enable and start the ntfy service
  sudo systemctl enable ntfy
  sudo systemctl start ntfy

  echo "ntfy has been installed."
}

# Function to uninstall ntfy
uninstall_ntfy() {
  # Stop and disable the ntfy service
  sudo systemctl stop ntfy
  sudo systemctl disable ntfy

  # Remove ntfy package
  sudo apt remove ntfy --purge -y

  echo "ntfy has been uninstalled."
}

# Main menu
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