#!/bin/bash

# Check if Python is installed
if ! command -v python3 &>/dev/null; then
    echo "Python is not installed. Installing Python..."
    sudo apt-get update
    sudo apt-get install python3 -y
else
    echo "Python is already installed."
fi

# Download bot.py from the external link
echo "Downloading bot.py..."
curl -O https://raw.githubusercontent.com/Ptechgithub/configs/main/bot.py

# Run the bot.py script
python3 bot.py