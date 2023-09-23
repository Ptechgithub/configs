#!/bin/bash
#########################################################
#
# LetsEncrypt certificate permissions for ntfy
# Replace DOMAIN with your domain name
#####################################################

# Ask the user for their domain
read -p "Enter your domain name: " DOMAIN

# Ask the user for the port (default is 80)
read -p "Enter the port for certificate validation (default is 80): " PORT
PORT="${PORT:-80}" # Set default to 80 if the user doesn't provide a port

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