#!/bin/bash

# UFOBeep Production Machine Setup Script
# Run this script on your production server as root or with sudo privileges

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_header() {
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE} $1 ${NC}"
    echo -e "${BLUE}============================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run this script as root or with sudo"
    exit 1
fi

print_header "UFOBeep Production Server Setup"

# Get server information
echo -e "${YELLOW}Please provide the following information:${NC}"
read -p "Domain name (e.g., yourdomain.com): " DOMAIN_NAME
read -p "Admin email for SSL certificates: " ADMIN_EMAIL
read -p "Application user (default: ufobeep): " APP_USER
APP_USER=${APP_USER:-ufobeep}

print_header "System Updates and Package Installation"

# Update system
print_success "Updating system packages..."
apt update && apt upgrade -y

# Install essential packages
print_success "Installing essential packages..."
apt install -y curl wget git unzip htop nano ufw nginx certbot python3-certbot-nginx

print_header "User Setup"

# Create application user if not exists
if ! id "$APP_USER" &>/dev/null; then
    print_success "Creating application user: $APP_USER"
    adduser --disabled-password --gecos "" $APP_USER
    usermod -aG sudo $APP_USER
else
    print_success "User $APP_USER already exists"
fi

print_header "Docker Installation"

# Install Docker
if ! command -v docker &> /dev/null; then
    print_success "Installing Docker..."
    curl -fsSL https://get.docker.com | sh
    usermod -aG docker $APP_USER
    systemctl start docker
    systemctl enable docker
else
    print_success "Docker already installed"
fi

# Install Docker Compose
if ! command -v docker-compose &> /dev/null; then
    print_success "Installing Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
else
    print_success "Docker Compose already installed"
fi

print_header "Firewall Configuration"

# Configure UFW
print_success "Configuring firewall..."
ufw --force enable
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp

print_header "Application Directory Setup"

# Switch to application user for app setup
sudo -u $APP_USER bash << EOF
cd /home/$APP_USER

# Clone UFOBeep repository (you'll need to replace with actual repo URL)
if [ ! -d "ufobeep" ]; then
    echo "Cloning UFOBeep repository..."
    git clone https://github.com/varak/ufobeep.git
    cd ufobeep
else
    echo "UFOBeep directory already exists"
    cd ufobeep
    git pull origin main
fi

# Create necessary directories
mkdir -p logs backups uploads scripts

# Copy environment file
if [ ! -f .env ]; then
    cp .env.example .env
    echo "✓ Created .env file - PLEASE EDIT THIS FILE WITH YOUR PRODUCTION VALUES"
fi

# Create Docker network
docker network create ufobeep-network 2>/dev/null || echo "Network already exists"
EOF

print_header "SSL Certificate Setup"

# Set up basic Nginx configuration for Let's Encrypt
cat > /etc/nginx/sites-available/ufobeep-temp << EOF
server {
    listen 80;
    server_name $DOMAIN_NAME api.$DOMAIN_NAME www.$DOMAIN_NAME;
    
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
    
    location / {
        return 301 https://\$server_name\$request_uri;
    }
}
EOF

# Enable site
ln -sf /etc/nginx/sites-available/ufobeep-temp /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx

# Get SSL certificates
print_success "Obtaining SSL certificates..."
certbot --nginx -d $DOMAIN_NAME -d api.$DOMAIN_NAME -d www.$DOMAIN_NAME --email $ADMIN_EMAIL --agree-tos --non-interactive

print_header "Production Nginx Configuration"

# Create production Nginx config
cat > /etc/nginx/sites-available/ufobeep << 'EOF'
# Rate limiting
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;

# Main site redirect to www
server {
    listen 80;
    listen 443 ssl http2;
    server_name DOMAIN_NAME;
    
    ssl_certificate /etc/letsencrypt/live/DOMAIN_NAME/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/DOMAIN_NAME/privkey.pem;
    
    return 301 https://www.DOMAIN_NAME$request_uri;
}

# API Server
server {
    listen 80;
    server_name api.DOMAIN_NAME;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.DOMAIN_NAME;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/DOMAIN_NAME/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/DOMAIN_NAME/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers off;

    # Security Headers
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;

    # Rate limiting
    limit_req zone=api burst=20 nodelay;
    
    # Proxy to API container
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }

    # File uploads
    location /api/media/ {
        client_max_body_size 50M;
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 300s;
    }
}
EOF

# Replace domain placeholder
sed -i "s/DOMAIN_NAME/$DOMAIN_NAME/g" /etc/nginx/sites-available/ufobeep

# Enable new configuration
ln -sf /etc/nginx/sites-available/ufobeep /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/ufobeep-temp
nginx -t && systemctl reload nginx

print_header "Database Backup Script"

# Create backup script
sudo -u $APP_USER bash << 'EOF'
cat > /home/ufobeep/scripts/backup-db.sh << 'BACKUP_EOF'
#!/bin/bash
# Database backup script

BACKUP_DIR="/home/ufobeep/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=30

mkdir -p $BACKUP_DIR
cd /home/ufobeep/ufobeep

# Backup PostgreSQL
docker-compose exec -T db pg_dump -U postgres ufobeep_prod | gzip > $BACKUP_DIR/ufobeep_backup_$TIMESTAMP.sql.gz

# Cleanup old backups
find $BACKUP_DIR -name "ufobeep_backup_*.sql.gz" -mtime +$RETENTION_DAYS -delete

echo "Backup completed: ufobeep_backup_$TIMESTAMP.sql.gz"
BACKUP_EOF

chmod +x /home/ufobeep/scripts/backup-db.sh
EOF

# Set up daily backup cron job
(crontab -u $APP_USER -l 2>/dev/null; echo "0 2 * * * /home/$APP_USER/scripts/backup-db.sh >> /var/log/ufobeep-backup.log 2>&1") | crontab -u $APP_USER -

print_header "System Services"

# Create systemd service for auto-start
cat > /etc/systemd/system/ufobeep.service << EOF
[Unit]
Description=UFOBeep Application
Requires=docker.service
After=docker.service

[Service]
Type=forking
RemainAfterExit=yes
User=$APP_USER
WorkingDirectory=/home/$APP_USER/ufobeep
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

systemctl enable ufobeep.service

print_header "Final Setup Steps"

print_success "Production server setup completed!"
echo ""
echo -e "${YELLOW}IMPORTANT: Complete these final steps:${NC}"
echo ""
echo "1. Edit the environment file:"
echo -e "   ${BLUE}sudo -u $APP_USER nano /home/$APP_USER/ufobeep/.env${NC}"
echo ""
echo "2. Configure your environment variables:"
echo "   - Database credentials"
echo "   - API keys (OpenWeather, Hugging Face, etc.)"
echo "   - Matrix server configuration"
echo "   - Email service settings"
echo ""
echo "3. Start the application:"
echo -e "   ${BLUE}sudo -u $APP_USER bash${NC}"
echo -e "   ${BLUE}cd /home/$APP_USER/ufobeep${NC}"
echo -e "   ${BLUE}docker-compose up -d${NC}"
echo ""
echo "4. Run database migrations:"
echo -e "   ${BLUE}docker-compose exec api python -m alembic upgrade head${NC}"
echo ""
echo "5. Test your deployment:"
echo -e "   ${BLUE}curl https://api.$DOMAIN_NAME/health${NC}"
echo ""
echo -e "${YELLOW}Your UFOBeep API will be available at:${NC} https://api.$DOMAIN_NAME"
echo -e "${YELLOW}Deploy your frontend to Vercel pointing to:${NC} $DOMAIN_NAME"
echo ""
echo -e "${GREEN}Setup complete! 🚀${NC}"