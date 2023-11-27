#!/bin/bash

check_dependencies() {
    local dependencies=("curl" "wget" "unzip")

    for dep in "${dependencies[@]}"; do
        if ! dpkg -s "${dep}" &> /dev/null; then
            echo "${dep} is not installed. Installing..."
            apt install "${dep}" -y
        fi
    done
}

download-xray() {
    pkg update -y
    check_dependencies
    mkdir xy-fragment && cd xy-fragment
    wget https://github.com/XTLS/Xray-core/releases/download/v1.8.4/Xray-android-arm64-v8a.zip
    unzip Xray-android-arm64-v8a.zip
    find /data/data/com.termux/files/home/xy-fragment -type f ! -name 'xray' -delete
    chmod +x xray
}

config() {
    cat << EOL > config.json
{
    "log": {
        "loglevel": "warning"
    },
    "routing": {
        "domainStrategy": "AsIs",
        "rules": [
            {
                "type": "field",
                "ip": [
                    "geoip:private"
                ],
                "outboundTag": "block"
            }
        ]
    },
    "inbounds": [
        {
            "listen": "0.0.0.0",
            "port": $port,
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "$uuid"
                    }
                ]
            },
            "streamSettings": {
                "network": "ws",
                "security": "none"
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "tag": "direct",
            "settings": {
                "domainStrategy": "AsIs",
                "fragment": {
                    "packets": "tlshello",
                    "length": "100-200",
                    "interval": "10-20"
                }
            }
        },
        {
            "protocol": "blackhole",
            "tag": "block"
        }
    ]
}
EOL
}

install() {
    download-xray
    config
    uuid=$(./xy-fragment/xray uuid)
    read -p "Enter a Port between [1024 - 65535]: " port
    vmess='{"add":"127.0.0.1","aid":"0","alpn":"","fp":"","host":"","id":"$uuid","net":"ws","path":"","port":"$port","ps":"Peyman YouTube X","scy":"auto","sni":"","tls":"","type":"","v":"2"}'
    encoded_vmess=$(echo -n "$vmess" | base64 -w 0)
    echo "--------------------------------------"
    echo "vmess://$encoded_vmess"
    echo "--------------------------------------"
    echo "vmess://$encoded_vmess" > "/xray/vmess.txt"
}

uninstall() {
    directory="/data/data/com.termux/files/home/xy-fragment"
    if [ -d "$directory" ]; then
        rm -r "$directory"
        echo "Uninstallation completed."
    else
        echo "Please Install First."
    fi
}

run() {
    cd ~ && cd xy-fragment
    ./xray run config.json
}


#menu
clear
echo "By --> Peyman * Github.com/Ptechgithub * "
echo ""
echo "  Bypass Filtering -- Xray Fragment  "
echo " Select an option:"
echo ""
echo "1) Get Your Config"
echo "2) Run VPN"
echo "3) Uninstall"
echo "0) Exit"
read -p "Enter your choice: " choice

case "$choice" in
   1)
        install
        ;;
    2)
        run
        ;;
    3)
        uninstall
        ;;
    0)   
        exit
        ;;
    *)
        echo "Invalid choice. Please select a valid option."
        ;;
esac
