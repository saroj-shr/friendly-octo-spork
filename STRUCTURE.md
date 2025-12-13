# Project Structure

```
docker-wordpress/
├── config/                      # Configuration files
│   ├── nginx/
│   │   ├── nginx.conf          # Main Nginx configuration
│   │   └── conf.d/
│   │       └── wordpress.conf  # WordPress site configuration
│   ├── php/
│   │   └── php-uploads.ini     # PHP upload/execution settings
│   └── daemon.json             # Docker daemon IPv6 configuration
│
├── scripts/                     # Utility scripts
│   ├── generate-ssl.sh         # Generate self-signed SSL certificates
│   └── setup-ipv6-docker.sh    # Configure Docker for IPv6
│
├── ssl/                         # SSL certificates (gitignored)
│   ├── cert.pem                # SSL certificate
│   └── key.pem                 # SSL private key
│
├── docker-compose.yml          # Docker Compose configuration
├── .env.example                # Environment variables template
├── .gitignore                  # Git ignore rules
└── README.md                   # Documentation
```

## Directory Purposes

### `config/`
All configuration files for services:
- **nginx/**: Nginx web server and reverse proxy configuration
- **php/**: PHP runtime settings (upload limits, timeouts, memory)
- **daemon.json**: Docker daemon configuration for IPv6 support

### `scripts/`
Executable scripts for setup and maintenance:
- **generate-ssl.sh**: Creates self-signed SSL certificates for development
- **setup-ipv6-docker.sh**: Configures Docker daemon for IPv6-only VPS

### `ssl/`
SSL/TLS certificates (auto-generated, not committed to git):
- Development: Self-signed certificates
- Production: Should contain Let's Encrypt certificates

## Volume Mounts

Docker volumes persist data:
- **db_data**: MySQL database files
- **wordpress_data**: WordPress installation and uploads
