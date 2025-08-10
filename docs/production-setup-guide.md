# UFOBeep Production Machine Setup Guide

## 🚀 Production Server Requirements

### Minimum Hardware Specs
- **CPU**: 4 vCPUs (8 vCPUs recommended)
- **RAM**: 8GB (16GB recommended)
- **Storage**: 100GB SSD (200GB+ for production data)
- **Network**: 1Gbps connection
- **OS**: Ubuntu 22.04 LTS or CentOS 8+

### Recommended VPS Providers
- **DigitalOcean**: Droplet with 4GB+ RAM
- **AWS**: EC2 t3.large or t3.xlarge
- **Google Cloud**: e2-standard-4
- **Linode**: Linode 8GB plan
- **Vultr**: High Performance 8GB

## 📋 Step-by-Step Production Setup

### 1. Server Initial Configuration

**Connect to your server:**
```bash
ssh root@your-server-ip
```

**Update system packages:**
```bash
apt update && apt upgrade -y
```

**Create application user:**
```bash
adduser ufobeep
usermod -aG sudo ufobeep
```

**Set up SSH key authentication:**
```bash
# On your local machine
ssh-copy-id ufobeep@your-server-ip

# Test connection
ssh ufobeep@your-server-ip
```

### 2. Install Required Software

**Install Docker:**
```bash
# Add Docker repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

# Add user to docker group
sudo usermod -aG docker ufobeep

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Test Docker installation
docker run hello-world
```

**Install Docker Compose:**
```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

**Install additional tools:**
```bash
sudo apt install -y git nginx certbot python3-certbot-nginx htop unzip curl wget
```

### 3. Clone and Setup UFOBeep

**Clone the repository:**
```bash
cd /home/ufobeep
git clone https://github.com/varak/ufobeep.git
cd ufobeep
```

**Set up environment variables:**
```bash
cp .env.example .env
nano .env
```

**Configure your .env file:**
```env
# Database Configuration
DATABASE_URL=postgresql://ufobeep_user:secure_password@db:5432/ufobeep_prod
POSTGRES_DB=ufobeep_prod
POSTGRES_USER=ufobeep_user
POSTGRES_PASSWORD=your_secure_database_password

# Redis Configuration
REDIS_URL=redis://redis:6379

# Application Configuration
ENVIRONMENT=production
SECRET_KEY=your_super_secret_key_here_32_chars_min
API_URL=https://api.yourdomain.com
WEB_URL=https://yourdomain.com

# External Services
OPENWEATHER_API_KEY=your_openweather_api_key
HUGGINGFACE_API_TOKEN=your_huggingface_token
OPENSKY_API_USER=your_opensky_username
OPENSKY_API_PASSWORD=your_opensky_password

# Matrix Configuration
MATRIX_HOMESERVER_URL=https://matrix.yourdomain.com
MATRIX_ACCESS_TOKEN=your_matrix_access_token

# Email Configuration (SendGrid)
SENDGRID_API_KEY=your_sendgrid_api_key
FROM_EMAIL=noreply@yourdomain.com

# Security
ALLOWED_HOSTS=yourdomain.com,api.yourdomain.com,www.yourdomain.com
CORS_ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com

# SSL/TLS
SSL_REDIRECT=true
```

### 4. Configure Firewall

**Set up UFW (Uncomplicated Firewall):**
```bash
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 8000/tcp  # API server
sudo ufw status
```

### 5. Set Up SSL Certificates

**Configure Nginx for domain:**
```bash
sudo nano /etc/nginx/sites-available/ufobeep-api
```

**Nginx configuration:**
```nginx
server {
    listen 80;
    server_name api.yourdomain.com;
    
    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

**Enable site and get SSL certificates:**
```bash
sudo ln -s /etc/nginx/sites-available/ufobeep-api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Get SSL certificate with Certbot
sudo certbot --nginx -d api.yourdomain.com
```

### 6. Deploy UFOBeep Services

**Create Docker network:**
```bash
docker network create ufobeep-network
```

**Start the services:**
```bash
docker-compose up -d
```

**Check service status:**
```bash
docker-compose ps
docker-compose logs -f
```

### 7. Database Setup

**Run database migrations:**
```bash
# Wait for database to be ready
sleep 30

# Run migrations
docker-compose exec api python -m alembic upgrade head

# Verify database
docker-compose exec db psql -U ufobeep_user -d ufobeep_prod -c "\dt"
```

### 8. Verify Deployment

**Check API health:**
```bash
curl -I https://api.yourdomain.com/health
```

**Check service logs:**
```bash
docker-compose logs api
docker-compose logs db
docker-compose logs redis
```

**Test API endpoints:**
```bash
# Test sightings endpoint
curl https://api.yourdomain.com/api/sightings

# Test health check
curl https://api.yourdomain.com/health
```

## 🔧 Production Configuration Files

### Docker Compose for Production

**Create `docker-compose.prod.yml`:**
```yaml
version: '3.8'

services:
  api:
    build: ./api
    container_name: ufobeep-api
    restart: unless-stopped
    ports:
      - "8000:8000"
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

  db:
    image: postgres:15-alpine
    container_name: ufobeep-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./backups:/backups
    networks:
      - ufobeep-network
    ports:
      - "127.0.0.1:5432:5432"

  redis:
    image: redis:7-alpine
    container_name: ufobeep-redis
    restart: unless-stopped
    volumes:
      - redis_data:/data
    networks:
      - ufobeep-network

  nginx:
    image: nginx:alpine
    container_name: ufobeep-nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/conf.d:/etc/nginx/conf.d
      - /etc/letsencrypt:/etc/letsencrypt
    depends_on:
      - api
    networks:
      - ufobeep-network

volumes:
  postgres_data:
  redis_data:

networks:
  ufobeep-network:
    external: true
```

### Production Nginx Configuration

**Create `nginx/conf.d/ufobeep.conf`:**
```nginx
# Rate limiting
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
limit_req_zone $binary_remote_addr zone=auth:10m rate=5r/s;

# Upstream servers
upstream api_backend {
    server api:8000;
}

# API Server
server {
    listen 80;
    server_name api.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.yourdomain.com;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/api.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.yourdomain.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    ssl_prefer_server_ciphers off;

    # Security Headers
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # Rate limiting
    limit_req zone=api burst=20 nodelay;
    
    # API routes
    location /api/ {
        proxy_pass http://api_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }

    # Auth routes with stricter rate limiting
    location /api/auth/ {
        limit_req zone=auth burst=10 nodelay;
        proxy_pass http://api_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Health check
    location /health {
        proxy_pass http://api_backend;
        access_log off;
    }

    # File uploads
    location /api/media/ {
        client_max_body_size 50M;
        proxy_pass http://api_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 300s;
    }
}
```

## 📊 Monitoring Setup

### Create monitoring docker-compose

**Create `docker-compose.monitoring.yml`:**
```yaml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: unless-stopped
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'
    networks:
      - ufobeep-network

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    restart: unless-stopped
    ports:
      - "3001:3000"
    volumes:
      - grafana_data:/var/lib/grafana
      - ./monitoring/grafana/provisioning/:/etc/grafana/provisioning/
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=your_grafana_password
    networks:
      - ufobeep-network

volumes:
  prometheus_data:
  grafana_data:

networks:
  ufobeep-network:
    external: true
```

### Start monitoring services:
```bash
docker-compose -f docker-compose.monitoring.yml up -d
```

## 🗄️ Database Backup Strategy

**Create backup script:**
```bash
#!/bin/bash
# /home/ufobeep/scripts/backup-db.sh

BACKUP_DIR="/home/ufobeep/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=30

mkdir -p $BACKUP_DIR

# Backup PostgreSQL
docker exec ufobeep-db pg_dump -U ufobeep_user ufobeep_prod | gzip > $BACKUP_DIR/ufobeep_backup_$TIMESTAMP.sql.gz

# Upload to cloud storage (optional)
# aws s3 cp $BACKUP_DIR/ufobeep_backup_$TIMESTAMP.sql.gz s3://your-backup-bucket/

# Cleanup old backups
find $BACKUP_DIR -name "ufobeep_backup_*.sql.gz" -mtime +$RETENTION_DAYS -delete

echo "Backup completed: ufobeep_backup_$TIMESTAMP.sql.gz"
```

**Set up daily backup cron job:**
```bash
chmod +x /home/ufobeep/scripts/backup-db.sh
crontab -e

# Add this line for daily backups at 2 AM
0 2 * * * /home/ufobeep/scripts/backup-db.sh >> /var/log/ufobeep-backup.log 2>&1
```

## 🔄 Deployment Automation

**Create deployment script:**
```bash
#!/bin/bash
# /home/ufobeep/scripts/deploy.sh

cd /home/ufobeep/ufobeep

# Pull latest code
git pull origin main

# Backup database before deployment
./scripts/backup-db.sh

# Build and restart services
docker-compose -f docker-compose.prod.yml build
docker-compose -f docker-compose.prod.yml up -d

# Run migrations
sleep 30
docker-compose -f docker-compose.prod.yml exec -T api python -m alembic upgrade head

# Verify deployment
curl -f https://api.yourdomain.com/health || exit 1

echo "Deployment completed successfully"
```

## 📱 Domain and DNS Configuration

### Required DNS Records:
```
A     @              -> your-server-ip
A     api            -> your-server-ip  
A     www            -> your-server-ip (or CNAME to Vercel)
CNAME matrix         -> matrix-server (if using external Matrix)
CNAME status         -> status-page-provider
```

### Frontend Deployment (Vercel):
```bash
# In the web directory
cd web
vercel --prod
```

## 🚨 Security Checklist

- [ ] **Firewall configured** (UFW or iptables)
- [ ] **SSH key authentication** (disable password auth)
- [ ] **SSL certificates** installed and auto-renewing
- [ ] **Database access** restricted to localhost
- [ ] **Environment variables** secured
- [ ] **Regular security updates** scheduled
- [ ] **Backup strategy** implemented
- [ ] **Monitoring and alerting** configured
- [ ] **Log rotation** set up
- [ ] **Intrusion detection** (optional: fail2ban)

## 📞 Support and Troubleshooting

### Common Issues:

**Service won't start:**
```bash
docker-compose logs service-name
docker-compose restart service-name
```

**Database connection issues:**
```bash
docker-compose exec db psql -U ufobeep_user -d ufobeep_prod
```

**SSL certificate issues:**
```bash
sudo certbot renew --dry-run
sudo nginx -t
```

**High memory usage:**
```bash
htop
docker stats
```

### Log Locations:
- **Application logs**: `/home/ufobeep/ufobeep/logs/`
- **Nginx logs**: `/var/log/nginx/`
- **System logs**: `/var/log/syslog`
- **Docker logs**: `docker-compose logs`

### Health Checks:
```bash
# API health
curl https://api.yourdomain.com/health

# Database connectivity
docker-compose exec api python -c "import psycopg2; print('DB OK')"

# Redis connectivity  
docker-compose exec api python -c "import redis; r=redis.Redis(host='redis'); print(r.ping())"
```

---

**Need help?** Contact: support@ufobeep.com

This setup provides a production-ready UFOBeep deployment with security, monitoring, and backup strategies.