#!/bin/sh

# Download SmartDNS installation package
mkdir smartDNS
wget --no-check-certificate -qO smartDNS/smartdns https://github.com/pymumu/smartdns/releases/download/Release45/smartdns-x86_64
chmod +x smartDNS/smartdns

cat <<EOL > smartDNS/smartdns.conf
# set listen port
bind []:53
# set upstream servers
server 1.1.1.1
server-tls 8.8.8.8
# set domain rules
address /intel.com/13.91.95.74
address /kmplayer.com/35.244.212.143
EOL

# Stop and disable existing DNS resolver
rc-service dnsmasq stop
#rc-update del dnsmasq

# Start SmartDNS service
/smartDNS/smartdns -c smartdns.conf