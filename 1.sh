#!/bin/bash

# Install Nginx
apk add nginx
bin/bash
# Create Nginx config file
cat > /etc/nginx/conf.d/cdn.conf <<'EOF'
server {
    listen 443;

    location / {
        if ($http_upgrade != "websocket") {
            return 404;
        }

        proxy_redirect off;
        proxy_pass http://127.0.0.1:443;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

# Restart Nginx
nginx -s reload

echo "Nginx configured successfully."