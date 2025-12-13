# WordPress Docker Setup

A Docker Compose configuration for running WordPress with MySQL, Nginx reverse proxy, SSL/TLS support, optimized for **IPv6-only VPS**.

## Prerequisites for IPv6-Only VPS

Before starting, configure Docker daemon for IPv6:

1. Set up Docker for IPv6:
   ```bash
   chmod +x scripts/setup-ipv6-docker.sh
   cd scripts && sudo ./setup-ipv6-docker.sh && cd ..
   ```

   Or manually copy `config/daemon.json` to `/etc/docker/daemon.json` and restart Docker:
   ```bash
   sudo cp config/daemon.json /etc/docker/daemon.json
   sudo systemctl restart docker
   ```

2. Verify IPv6 is enabled:
   ```bash
   docker network inspect bridge | grep IPv6
   ```

## Quick Start

1. Generate SSL certificates (development):
   ```bash
   chmod +x scripts/generate-ssl.sh
   ./scripts/generate-ssl.sh
   ```

2. Start the containers:
   ```bash
   docker-compose up -d
   ```

3. Access WordPress at:
   - HTTPS: https://[your-ipv6-address] or https://yourdomain.com
   - HTTP (redirects to HTTPS): http://[your-ipv6-address] or http://yourdomain.com

4. Stop the containers:
   ```bash
   docker-compose down
   ```

## Configuration

The setup includes:
- **WordPress** (latest version)
- **MySQL 8.0** database
- **Nginx** reverse proxy with SSL/TLS support
- **IPv6-only** network configuration (optimized for IPv6-only VPS)
- Persistent volumes for database and WordPress files
- HTTP to HTTPS automatic redirect
- Security headers and optimizations

### Network Configuration
- IPv6 subnet: fd00:172:20::/48
- Gateway: fd00:172:20::1
- All services communicate over IPv6
- No IPv4 mappings (pure IPv6 setup)

## Default Credentials

- **Database Name**: wordpress
- **Database User**: wordpress
- **Database Password**: wordpress
- **Root Password**: rootpassword

> **Note**: Change these credentials in production by editing the environment variables in `docker-compose.yml`

## Useful Commands

```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Remove volumes (data will be lost)
docker-compose down -v

# Restart services
docker-compose restart
```

## SSL Certificates

### Development (Self-Signed)
The included `scripts/generate-ssl.sh` script creates self-signed certificates for local development. Your browser will show a security warning - this is normal for self-signed certificates.

### Production (Let's Encrypt)
For production, use Let's Encrypt with Certbot:

1. Update `server_name` in `nginx/conf.d/wordpress.conf` with your domain
2. Add Certbot service to `docker-compose.yml`:
```yaml
certbot:
  image: certbot/certbot
  volumes:
    - ./ssl:/etc/letsencrypt
    - ./certbot-www:/var/www/certbot
  command: certonly --webroot -w /var/www/certbot --email your@email.com -d yourdomain.com --agree-tos
```

3. Update SSL paths in Nginx config to point to Let's Encrypt certificates

## IPv6-Only VPS Configuration

This setup is optimized for IPv6-only VPS:

1. **Docker Daemon**: Must be configured with IPv6 support (use `setup-ipv6-docker.sh`)
2. **Network**: Uses IPv6 subnet fd00:172:20::/48
3. **Port Bindings**: Only IPv6 (`[::]`) - no IPv4 bindings
4. **External Access**: Requires your VPS to have a public IPv6 address assigned

### Troubleshooting IPv6

Check if containers have IPv6 addresses:
```bash
docker inspect wordpress_nginx | grep IPv6Address
docker inspect wordpress_site | grep IPv6Address
docker inspect wordpress_db | grep IPv6Address
```

Test IPv6 connectivity from container:
```bash
docker exec wordpress_nginx ping6 -c 3 google.com
```

View container network details:
```bash
docker network inspect docker-wordpress_wordpress_network
```

## Customization

### Ports
To change exposed ports, edit the `nginx` service ports in `docker-compose.yml`:
```yaml
ports:
  - "YOUR_HTTP_PORT:80"
  - "[::]:YOUR_HTTP_PORT:80"
  - "YOUR_HTTPS_PORT:443"
  - "[::]:YOUR_HTTPS_PORT:443"
```

### Nginx Configuration
Modify `config/nginx/conf.d/wordpress.conf` for custom server settings.

### PHP Configuration
Modify `config/php/php-uploads.ini` to adjust upload limits and PHP settings.

## Large Backup Restoration (6GB+)

For backups larger than 6GB, web upload has limitations. Use one of these methods:

### Method 1: Direct Server Upload (Recommended)
```bash
# 1. Upload backup file to server via SCP/SFTP
scp your-backup.zip root@your-server:/opt/wordpress/

# 2. On the server, run the restore script
cd /opt/wordpress
chmod +x scripts/restore-backup.sh
./scripts/restore-backup.sh your-backup.zip
```

### Method 2: Cloud Storage Import
Use WordPress plugins to import from:
- Google Drive
- Dropbox
- FTP
- External URL

### Method 3: Split Backup
Split your backup into smaller chunks (< 6GB each) and import separately using your backup plugin.
