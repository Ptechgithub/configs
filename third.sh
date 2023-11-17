#!/bin/bash

check_dependencies() {
    local dependencies=("wget" "curl" "golang" "openssl")
    
    for dep in "${dependencies[@]}"; do
        if ! command -v "${dep}" &> /dev/null; then
            echo "${dep} is not installed. Installing..."
            pkg install "${dep}" -y
        fi
    done
}

install() {

    pkg update -y
    check_dependencies
    mkdir bale
    wget https://github.com/iSegaro/Bale/raw/main/bale.zip
    unzip bale.zip
    
    # Step 2: Move syscall and net folders to the Go source directory
    cd go_patches/src
    mv ./syscall/* /data/data/com.termux/files/usr/lib/go/src/syscall/
    mv ./net/* /data/data/com.termux/files/usr/lib/go/src/net/
    cd -

    # Step 3: Get user input for IP and port
    clear
    read -p "Please Enter Your IP : " new_ip
    read -p "Please Enter Your Config Port: " new_port

    # Step 4: Check if the inputs are not empty
    if [ -z "$new_ip" ] || [ -z "$new_port" ]; then
        echo "IP and port are required."
        exit 1
    fi

    # Step 5: Replace <ip>:<port> in main.go with user inputs
    sed -i "s/<ip>:<port>/$new_ip:$new_port/g" main.go

    echo "main.go has been updated with the new IP and port."
    echo "Set your config with: 127.0.0.1:8185"
    go run main.go
}

main_menu() {
    clear
    echo "By --> Peyman * Github.com/Ptechgithub * "
    echo "& https://github.com/iSegaro "
    echo ""
    echo "1) Install"
    echo "0) Exit"
    read -p "Please choose: " choice

    case $choice in
        1)
            install
            ;;
        0)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please enter a number between 0 and 1."
            ;;
    esac
}

main_menu