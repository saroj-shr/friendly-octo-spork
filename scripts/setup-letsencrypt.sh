#!/bin/bash

# Let's Encrypt Certificate Setup Script
# Use --staging flag for testing to avoid rate limits

DOMAIN="11221122.xyz"
EMAIL="your@email.com"  # Change this to your email
STAGING=""

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --staging) STAGING="--staging"; echo "Using Let's Encrypt STAGING environment (test certificates)"; ;;
        --email) EMAIL="$2"; shift ;;
        --domain) DOMAIN="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

echo "Let's Encrypt Certificate Setup"
echo "================================"
echo "Domain: $DOMAIN"
echo "Email: $EMAIL"
echo ""

if [[ "$EMAIL" == "your@email.com" ]]; then
    echo "Error: Please set your email address"
    echo "Usage: $0 --email your@email.com [--staging]"
    exit 1
fi

# Create directories
mkdir -p certbot/www
mkdir -p certbot/conf

# Start nginx and certbot services if not running
echo "Starting services..."
docker compose up -d nginx certbot

# Wait for nginx to be ready
sleep 3

# Request certificate
echo ""
echo "Requesting certificate..."
if [ -n "$STAGING" ]; then
    echo "⚠️  STAGING MODE - Certificate will NOT be trusted by browsers"
    echo "   Use this for testing only!"
fi

docker compose run --rm certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email "$EMAIL" \
    --agree-tos \
    --no-eff-email \
    $STAGING \
    -d "$DOMAIN"

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Certificate obtained successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Update nginx config to use Let's Encrypt certificates"
    echo "2. Run: ./scripts/switch-to-letsencrypt.sh"
    echo "3. Restart nginx: docker compose restart nginx"
else
    echo ""
    echo "✗ Certificate request failed"
    echo ""
    echo "Common issues:"
    echo "- Domain doesn't point to this server"
    echo "- Port 80 is not accessible"
    echo "- Rate limit reached (use --staging for testing)"
fi
