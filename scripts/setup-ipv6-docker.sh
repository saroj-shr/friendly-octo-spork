#!/bin/bash

echo "Setting up Docker for IPv6-only VPS..."

# Backup existing daemon.json if it exists
if [ -f /etc/docker/daemon.json ]; then
    echo "Backing up existing /etc/docker/daemon.json..."
    sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.backup
fi

# Copy daemon.json to Docker config directory
echo "Configuring Docker daemon for IPv6..."
sudo cp ../config/daemon.json /etc/docker/daemon.json

# Restart Docker daemon
echo "Restarting Docker daemon..."
sudo systemctl restart docker

# Verify Docker is running
if sudo systemctl is-active --quiet docker; then
    echo "✓ Docker daemon restarted successfully"
    echo "✓ IPv6 support enabled"
else
    echo "✗ Failed to restart Docker daemon"
    echo "Check logs with: sudo journalctl -u docker.service"
    exit 1
fi

# Show Docker network info
echo ""
echo "Docker IPv6 configuration:"
docker network inspect bridge | grep -A 10 "IPv6"

echo ""
echo "Setup complete! You can now run: docker-compose up -d"
