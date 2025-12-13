#!/bin/bash

# Create SSL directory if it doesn't exist
mkdir -p ssl

# Generate self-signed certificate for development
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ssl/key.pem \
    -out ssl/cert.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=11221122.xyz" \
    -addext "subjectAltName=DNS:11221122.xyz,DNS:*.11221122.xyz"

echo "Self-signed SSL certificate generated in ./ssl/"
echo "Note: This is for development only. Use Let's Encrypt for production."
