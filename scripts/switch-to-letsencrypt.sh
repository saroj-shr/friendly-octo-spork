#!/bin/bash

DOMAIN="11221122.xyz"

echo "Switching to Let's Encrypt certificates..."

# Check if certificates exist
if [ ! -f "certbot/conf/live/$DOMAIN/fullchain.pem" ]; then
    echo "Error: Let's Encrypt certificates not found!"
    echo "Run ./scripts/setup-letsencrypt.sh first"
    exit 1
fi

# Backup current nginx config
cp config/nginx/conf.d/wordpress.conf config/nginx/conf.d/wordpress.conf.backup

# Update nginx config to use Let's Encrypt certificates
cat > config/nginx/conf.d/wordpress.conf << 'EOF'
# HTTP server - redirect to HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name 11221122.xyz;

    # Let's Encrypt ACME challenge
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

# HTTPS server
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    http2 on;
    server_name 11221122.xyz;

    # Let's Encrypt SSL certificates
    ssl_certificate /etc/letsencrypt/live/11221122.xyz/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/11221122.xyz/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/11221122.xyz/chain.pem;

    # SSL configuration
    ssl_session_cache shared:le_nginx_SSL:10m;
    ssl_session_timeout 1440m;
    ssl_session_tickets off;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers off;
    ssl_ciphers "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";

    # Logging
    access_log /var/log/nginx/wordpress-access.log;
    error_log /var/log/nginx/wordpress-error.log;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # Proxy to WordPress Apache container
    location / {
        proxy_pass http://wordpress:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port 443;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        
        # Timeouts for large uploads (6GB backups)
        proxy_connect_timeout 600s;
        proxy_send_timeout 600s;
        proxy_read_timeout 600s;
        
        # Buffer settings for large files
        proxy_request_buffering off;
        proxy_buffering off;
    }

    # Deny access to sensitive files
    location ~ /\.ht {
        deny all;
    }

    location ~ /\.git {
        deny all;
    }

    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }

    location = /robots.txt {
        log_not_found off;
        access_log off;
        allow all;
    }
}
EOF

echo "✓ Nginx configuration updated to use Let's Encrypt certificates"
echo ""
echo "Reloading nginx..."
docker compose restart nginx

echo ""
echo "✓ Done! Your site is now using Let's Encrypt certificates"
echo "  Visit: https://11221122.xyz"
