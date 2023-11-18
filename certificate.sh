#!/bin/bash

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
PLAIN="\033[0m"

red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}

green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}

yellow(){
    echo -e "\033[33m\033[01m$1\033[0m"
}

detect_distribution() {
    local supported_distributions=("ubuntu" "debian" "centos" "fedora")

    if [ -f /etc/os-release ]; then
        source /etc/os-release
        if [[ "${ID}" == "ubuntu" || "${ID}" == "debian" || "${ID}" == "centos" || "${ID}" == "fedora" ]]; then
            pm="apt"
            [ "${ID}" == "centos" ] && pm="yum"
            [ "${ID}" == "fedora" ] && pm="dnf"
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

    local dependencies=("curl" "wget" "openssl" "socat")
    
    for dep in "${dependencies[@]}"; do
        if ! command -v "${dep}" &> /dev/null; then
            echo "${dep} is not installed. Installing..."
            sudo "${pm}" install "${dep}" -y
        fi
    done
}

ip=$(hostname -I | awk '{print $1}')

inst_cert(){
    check_dependencies

    green "Methods of applying certificate ："
    echo ""
    echo -e " ${GREEN}1.${PLAIN} Bing self-signed certificate ${YELLOW} (default) ${PLAIN}"
    echo -e " ${GREEN}2.${PLAIN} Acme script auto-apply"
    echo ""
    read -rp "please enter options [1-2]: " certInput
    if [[ $certInput == 2 ]]; then
        mkdir -p /root/peyman
        cert_path="/root/peyman/cert.crt"
        key_path="/root/peyman/private.key"
        
        if [[ -f /root/peyman/cert.crt && -f /root/peyman/private.key ]] && [[ -s /root/peyman/cert.crt && -s /root/peyman/private.key ]] && [[ -f /root/ca.log ]]; then
            domain=$(cat /root/ca.log)
            green "Legacy domain name detected: certificate for $domain, applying"
            hy_domain=$domain
        else
            read -p "Please enter the domain name：" domain
            [[ -z $domain ]] && red "No domain name entered, unable to perform operation！" && exit 1
            green "Domain name entered: $domain" && sleep 1
            domainIP=$(dig +short "${domain}")
            if [[ $domainIP == $ip ]]; then
                $pm install socat
                if [[ $pm == "apt-get" ]]; then
                    sudo $pm install cron
                elif [[ $pm == "yum" || $pm == "dnf" ]]; then
                    sudo $pm install cronie
                    systemctl start crond
                    systemctl enable crond
                fi

                curl https://get.acme.sh | sh -s email=$(date +%s%N | md5sum | cut -c 1-16)@gmail.com
                source ~/.bashrc
                bash ~/.acme.sh/acme.sh --upgrade --auto-upgrade
                bash ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
                if [[ -n $(echo $ip | grep ":") ]]; then
                    bash ~/.acme.sh/acme.sh --issue -d ${domain} --standalone -k ec-256 --listen-v6 --insecure
                else
                    bash ~/.acme.sh/acme.sh --issue -d ${domain} --standalone -k ec-256 --insecure
                fi
                bash ~/.acme.sh/acme.sh --install-cert -d ${domain} --key-file /root/peyman/private.key --fullchain-file /root/peyman/cert.crt --ecc
                if [[ -f /root/peyman/cert.crt && -f /root/peyman/private.key ]] && [[ -s /root/peyman/cert.crt && -s /root/peyman/private.key ]]; then
                    echo $domain > /root/ca.log
                    sed -i '/--cron/d' /etc/crontab >/dev/null 2>&1
                    echo "0 0 * * * root bash /root/.acme.sh/acme.sh --cron -f >/dev/null 2>&1" | sudo tee -a /etc/crontab >/dev/null 2>&1
                    green "Successful! The certificate (cer.crt) and private key (private.key) files applied by the script have been saved to the /root folder"
                    yellow "The certificate crt file path is as follows: /root/peyman/cert.crt"
                    yellow "The private key file path is as follows: /root/peyman/private.key"
                    hy_domain=$domain
                fi
            else
                red "The IP resolved by the current domain name does not match the real IP used by the current VPS"
                green "suggestions below:"
                yellow "1. Please make sure CloudFlare is turned off (DNS only), other domain name resolution or CDN website settings are the same"
                yellow "2. Please check whether the IP set by the DNS resolution is the real IP of the VPS"
                yellow "3. The script may not keep up with the times, it is recommended to post screenshots to GitHub Issues, or TG groups for inquiries"
                exit 1
            fi
        fi
    else
        mkdir -p /root/peyman
        cert_path="/root/peyman/cert.crt"
        key_path="/root/peyman/private.key"
        openssl ecparam -genkey -name prime256v1 -out /root/peyman/private.key
        openssl req -new -x509 -days 36500 -key /root/peyman/private.key -out /root/peyman/cert.crt -subj "/CN=www.bing.com"
        chmod 777 /root/peyman/cert.crt
        sudo chmod 777 /root/peyman/private.key
        hy_domain="www.bing.com"
        domain="www.bing.com"
        green "Generated Successfully! You can now use them ."
    fi
}

renew() {
    read -p "Enter your domain: " renew_domain

    if [ -z "$renew_domain" ]; then
        echo "Domain is required."
        exit 1
    fi

    /root/.acme.sh/acme.sh --renew -d $renew_domain --force

    echo "SSL certificate renewed successfully!"
}

clear
echo "By --> Peyman * Github.com/Ptechgithub * "
echo ""
echo "1) Get SSL certificate"
echo "2) Renew scme certificates"
echo "0) Exit"
read -p "Please choose: " choice

case $choice in
    1)
        inst_cert
        ;;
    2)
        renew
        ;;
    0)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid choice. Please enter a number between 0 and 2."
        ;;
esac