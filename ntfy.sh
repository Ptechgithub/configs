#!/bin/bash

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
sudo apt update

# Install ntfy
sudo apt install ntfy

# Enable and start the ntfy service
sudo systemctl enable ntfy
sudo systemctl start ntfy