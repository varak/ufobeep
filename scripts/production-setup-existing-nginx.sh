#!/bin/bash

# UFOBeep Production Setup for Existing Nginx Server
# Domain: ufobeep.com and api.ufobeep.com
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

# Configuration
DOMAIN_NAME="ufobeep.com"
API_DOMAIN="api.ufobeep.com"
ADMIN_EMAIL="admin@ufobeep.com"
APP_USER="ufobeep"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run this script as root or with sudo"
    exit 1
fi

print_header "UFOBeep Setup for Existing Nginx Server"
echo "Domain: $DOMAIN_NAME"
echo "API Domain: $API_DOMAIN"
echo ""

# Confirm existing Nginx
if ! command -v nginx &> /dev/null; then
    print_error "Nginx not found. Please install Nginx first."
    exit 1
fi

print_success "Nginx found: $(nginx -v 2>&1)"

print_header "System Updates and Package Installation"

# Update system
print_success "Updating system packages..."
apt update && apt upgrade -y

# Install essential packages (skip nginx since it exists)
print_success "Installing additional packages..."
apt install -y curl wget git unzip htop nano certbot python3-certbot-nginx

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

# Configure firewall (add API port)
print_success "Adding API port to firewall..."
ufw allow 8000/tcp comment "UFOBeep API"

print_header "Application Directory Setup"

# Switch to application user for app setup
sudo -u $APP_USER bash << EOF
cd /home/$APP_USER

# Clone UFOBeep repository
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
    echo "✓ Created .env file"
fi

# Create Docker network
docker network create ufobeep-network 2>/dev/null || echo "Network already exists"
EOF

print_header "SSL Certificate Setup"

# Check if SSL certificates exist
if [ ! -f "/etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem" ]; then
    print_success "Obtaining SSL certificates for $DOMAIN_NAME and $API_DOMAIN..."
    certbot certonly --nginx -d $DOMAIN_NAME -d $API_DOMAIN -d www.$DOMAIN_NAME --email $ADMIN_EMAIL --agree-tos --non-interactive
else
    print_success "SSL certificates already exist"
fi

print_header "Nginx Configuration"

# Create UFOBeep Nginx configuration
print_success "Creating Nginx configuration for UFOBeep..."

cat > /etc/nginx/sites-available/ufobeep << EOF
# UFOBeep Configuration for api.ufobeep.com
# Rate limiting for API
limit_req_zone \$binary_remote_addr zone=ufobeep_api:10m rate=10r/s;
limit_req_zone \$binary_remote_addr zone=ufobeep_auth:10m rate=5r/s;

# API Server - api.ufobeep.com
server {
    listen 80;
    server_name $API_DOMAIN;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $API_DOMAIN;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # Security Headers
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self'; connect-src 'self' https:; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # CORS Headers for API
    add_header Access-Control-Allow-Origin "https://$DOMAIN_NAME" always;
    add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
    add_header Access-Control-Allow-Headers "Authorization, Content-Type, Accept, Origin, User-Agent, DNT, Cache-Control, X-Mx-ReqToken, Keep-Alive, X-Requested-With, If-Modified-Since" always;
    add_header Access-Control-Allow-Credentials true always;

    # Handle preflight requests
    location ~* ^/api/.*$ {
        if (\$request_method = 'OPTIONS') {
            add_header Access-Control-Allow-Origin "https://$DOMAIN_NAME";
            add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS";
            add_header Access-Control-Allow-Headers "Authorization, Content-Type, Accept, Origin, User-Agent, DNT, Cache-Control, X-Mx-ReqToken, Keep-Alive, X-Requested-With, If-Modified-Since";
            add_header Access-Control-Allow-Credentials true;
            add_header Access-Control-Max-Age 1728000;
            add_header Content-Type "text/plain; charset=utf-8";
            add_header Content-Length 0;
            return 204;
        }

        # Rate limiting for general API
        limit_req zone=ufobeep_api burst=20 nodelay;

        # Proxy to API container
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }

    # Auth routes with stricter rate limiting
    location ~* ^/api/(auth|register|login)/ {
        limit_req zone=ufobeep_auth burst=10 nodelay;
        
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # Health check (no rate limiting)
    location = /health {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        access_log off;
    }

    # File uploads with larger body size
    location ~* ^/api/(media|upload)/ {
        client_max_body_size 50M;
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
    }

    # Default API route
    location / {
        limit_req zone=ufobeep_api burst=20 nodelay;
        
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }

    # Logging
    access_log /var/log/nginx/ufobeep-api.access.log;
    error_log /var/log/nginx/ufobeep-api.error.log;
}
EOF

# Enable the site
print_success "Enabling UFOBeep Nginx configuration..."
ln -sf /etc/nginx/sites-available/ufobeep /etc/nginx/sites-enabled/

# Test Nginx configuration
print_success "Testing Nginx configuration..."
if nginx -t; then
    systemctl reload nginx
    print_success "Nginx configuration reloaded successfully"
else
    print_error "Nginx configuration test failed"
    exit 1
fi

print_header "UFOBeep Environment Configuration"

# Update .env file with production values
sudo -u $APP_USER bash << EOF
cd /home/$APP_USER/ufobeep

# Update .env file
cat > .env << 'ENV_EOF'
# Production Environment Configuration
ENVIRONMENT=production

# Database Configuration
DATABASE_URL=postgresql://ufobeep_user:CHANGE_THIS_PASSWORD@db:5432/ufobeep_prod
POSTGRES_DB=ufobeep_prod
POSTGRES_USER=ufobeep_user
POSTGRES_PASSWORD=CHANGE_THIS_PASSWORD

# Redis Configuration
REDIS_URL=redis://redis:6379

# Application Configuration
SECRET_KEY=GENERATE_A_SECURE_SECRET_KEY_HERE_32_CHARS_MIN
API_URL=https://$API_DOMAIN
WEB_URL=https://$DOMAIN_NAME

# External Services (YOU MUST UPDATE THESE)
OPENWEATHER_API_KEY=your_openweather_api_key_here
HUGGINGFACE_API_TOKEN=your_huggingface_token_here
OPENSKY_API_USER=your_opensky_username
OPENSKY_API_PASSWORD=your_opensky_password

# Matrix Configuration (OPTIONAL)
MATRIX_HOMESERVER_URL=https://matrix.org
MATRIX_ACCESS_TOKEN=your_matrix_access_token

# Email Configuration (SENDGRID)
SENDGRID_API_KEY=your_sendgrid_api_key_here
FROM_EMAIL=noreply@$DOMAIN_NAME

# Security and CORS
ALLOWED_HOSTS=$DOMAIN_NAME,$API_DOMAIN,www.$DOMAIN_NAME
CORS_ALLOWED_ORIGINS=https://$DOMAIN_NAME,https://www.$DOMAIN_NAME

# SSL/TLS
SSL_REDIRECT=true
SECURE_COOKIES=true
ENV_EOF

echo "✓ Updated .env file with production configuration"
EOF

print_header "Docker Compose Configuration"

# Create production docker-compose.yml
sudo -u $APP_USER bash << 'EOF'
cd /home/ufobeep/ufobeep

cat > docker-compose.yml << 'COMPOSE_EOF'
version: '3.8'

services:
  api:
    build: ./api
    container_name: ufobeep-api
    restart: unless-stopped
    ports:
      - "127.0.0.1:8000:8000"  # Only bind to localhost
    environment:
      - ENVIRONMENT=production
    env_file:
      - .env
    depends_on:
      - db
      - redis
    networks:
      - ufobeep-network
    volumes:
      - ./logs:/app/logs
      - ./uploads:/app/uploads
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  db:
    image: postgres:15-alpine
    container_name: ufobeep-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_INITDB_ARGS: "--encoding=UTF8 --lc-collate=C --lc-ctype=C"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./backups:/backups
    networks:
      - ufobeep-network
    ports:
      - "127.0.0.1:5432:5432"  # Only accessible from localhost
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    container_name: ufobeep-redis
    restart: unless-stopped
    volumes:
      - redis_data:/data
    networks:
      - ufobeep-network
    command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD:-}
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 3

volumes:
  postgres_data:
    driver: local
  redis_data:
    driver: local

networks:
  ufobeep-network:
    driver: bridge
COMPOSE_EOF

echo "✓ Created production docker-compose.yml"
EOF

print_header "Database Backup Script"

# Create backup script
sudo -u $APP_USER bash << 'EOF'
mkdir -p /home/ufobeep/scripts

cat > /home/ufobeep/scripts/backup-db.sh << 'BACKUP_EOF'
#!/bin/bash
# UFOBeep Database Backup Script

BACKUP_DIR="/home/ufobeep/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=30
LOG_FILE="/var/log/ufobeep-backup.log"

mkdir -p $BACKUP_DIR
cd /home/ufobeep/ufobeep

echo "$(date): Starting backup..." >> $LOG_FILE

# Backup PostgreSQL
if docker-compose exec -T db pg_dump -U ufobeep_user ufobeep_prod | gzip > $BACKUP_DIR/ufobeep_backup_$TIMESTAMP.sql.gz; then
    echo "$(date): Backup completed: ufobeep_backup_$TIMESTAMP.sql.gz" >> $LOG_FILE
else
    echo "$(date): Backup failed!" >> $LOG_FILE
    exit 1
fi

# Cleanup old backups
find $BACKUP_DIR -name "ufobeep_backup_*.sql.gz" -mtime +$RETENTION_DAYS -delete
echo "$(date): Cleaned up old backups" >> $LOG_FILE

echo "Backup completed: ufobeep_backup_$TIMESTAMP.sql.gz"
BACKUP_EOF

chmod +x /home/ufobeep/scripts/backup-db.sh
EOF

# Set up daily backup cron job
print_success "Setting up daily database backup..."
(crontab -u $APP_USER -l 2>/dev/null; echo "0 2 * * * /home/$APP_USER/scripts/backup-db.sh") | crontab -u $APP_USER -

print_header "System Service"

# Create systemd service for UFOBeep
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
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable ufobeep.service

print_header "Setup Complete"

print_success "UFOBeep production setup completed!"
echo ""
echo -e "${YELLOW}CRITICAL NEXT STEPS:${NC}"
echo ""
echo "1. Update your environment file with real values:"
echo -e "   ${BLUE}sudo -u $APP_USER nano /home/$APP_USER/ufobeep/.env${NC}"
echo ""
echo "   Required changes:"
echo "   - POSTGRES_PASSWORD=your_secure_password"
echo "   - SECRET_KEY=generate_32_char_secret"
echo "   - OPENWEATHER_API_KEY=your_api_key"
echo "   - HUGGINGFACE_API_TOKEN=your_token"
echo "   - SENDGRID_API_KEY=your_sendgrid_key"
echo ""
echo "2. Start UFOBeep services:"
echo -e "   ${BLUE}sudo -u $APP_USER bash${NC}"
echo -e "   ${BLUE}cd /home/$APP_USER/ufobeep${NC}"
echo -e "   ${BLUE}docker-compose up -d${NC}"
echo ""
echo "3. Run database migrations:"
echo -e "   ${BLUE}sleep 30  # Wait for DB to be ready${NC}"
echo -e "   ${BLUE}docker-compose exec api python -m alembic upgrade head${NC}"
echo ""
echo "4. Test your API:"
echo -e "   ${BLUE}curl https://$API_DOMAIN/health${NC}"
echo ""
echo "5. Deploy your frontend to Vercel pointing to: $DOMAIN_NAME"
echo ""
echo -e "${GREEN}Your UFOBeep API will be available at: https://$API_DOMAIN${NC}"
echo -e "${GREEN}Setup complete! 🚀${NC}"
echo ""
echo "Log locations:"
echo "- Application logs: /home/$APP_USER/ufobeep/logs/"
echo "- Nginx logs: /var/log/nginx/ufobeep-api.*"
echo "- Backup logs: /var/log/ufobeep-backup.log"