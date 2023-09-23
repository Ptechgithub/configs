#!/bin/bash

# Download ntfy release for Linux ARM64
wget https://github.com/binwiederhier/ntfy/releases/download/v2.7.0/ntfy_2.7.0_linux_arm64.tar.gz

# Extract the downloaded archive
tar zxvf ntfy_2.7.0_linux_arm64.tar.gz

# Copy ntfy executable to /usr/bin
sudo cp -a ntfy_2.7.0_linux_arm64/ntfy /usr/bin/ntfy

# Create a directory for ntfy configuration files
sudo mkdir -p /etc/ntfy

# Copy ntfy configuration files to /etc/ntfy
sudo cp ntfy_2.7.0_linux_arm64/{client,server}/*.yml /etc/ntfy

# Start the ntfy server
sudo ntfy serve