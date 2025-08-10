#!/bin/bash

# UFOBeep Deployment Setup Script
# This script helps configure the deployment environment

set -e

echo "🚀 UFOBeep Deployment Setup"
echo "==========================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check prerequisites
echo "Checking prerequisites..."

# Check Docker
if command -v docker &> /dev/null; then
    print_status "Docker is installed ($(docker --version))"
else
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check Docker Compose
if command -v docker-compose &> /dev/null; then
    print_status "Docker Compose is installed ($(docker-compose --version))"
else
    print_warning "Docker Compose is not installed. Installing..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Check Git
if command -v git &> /dev/null; then
    print_status "Git is installed ($(git --version))"
else
    print_error "Git is not installed. Please install Git first."
    exit 1
fi

# Check Node.js (for Vercel CLI)
if command -v node &> /dev/null; then
    print_status "Node.js is installed ($(node --version))"
else
    print_warning "Node.js is not installed. It's needed for Vercel deployment."
fi

echo ""
echo "Setting up deployment environment..."

# Create necessary directories
mkdir -p .github/workflows
mkdir -p scripts
mkdir -p deployments

# Check for .env file
if [ ! -f .env ]; then
    print_warning ".env file not found. Creating from template..."
    if [ -f .env.example ]; then
        cp .env.example .env
        print_status "Created .env file from template"
        echo ""
        echo "Please edit .env file with your configuration:"
        echo "  - Database credentials"
        echo "  - API keys"
        echo "  - Service URLs"
    else
        print_error ".env.example not found. Please create .env manually."
    fi
else
    print_status ".env file exists"
fi

echo ""
echo "Docker Setup"
echo "------------"

# Build Docker images
read -p "Do you want to build Docker images now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Building Docker images..."
    docker-compose build
    print_status "Docker images built successfully"
fi

echo ""
echo "GitHub Actions Setup"
echo "-------------------"

# Check if running in GitHub Actions
if [ -n "$GITHUB_ACTIONS" ]; then
    print_status "Running in GitHub Actions environment"
else
    print_warning "Not running in GitHub Actions"
    echo ""
    echo "To set up GitHub secrets, run:"
    echo "  gh secret set SECRET_NAME"
    echo ""
    echo "Required secrets:"
    echo "  - VPS_HOST, VPS_USER, VPS_SSH_KEY, VPS_PORT"
    echo "  - VERCEL_TOKEN, VERCEL_ORG_ID, VERCEL_PROJECT_ID"
    echo "  - Android: ANDROID_KEYSTORE, KEYSTORE_PASSWORD, KEY_ALIAS, KEY_PASSWORD"
    echo "  - iOS: BUILD_CERTIFICATE_BASE64, P12_PASSWORD, BUILD_PROVISION_PROFILE_BASE64"
fi

echo ""
echo "Vercel Setup"
echo "------------"

if command -v vercel &> /dev/null; then
    print_status "Vercel CLI is installed"
    
    read -p "Do you want to link this project to Vercel? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd web
        vercel link
        cd ..
        print_status "Vercel project linked"
    fi
else
    print_warning "Vercel CLI is not installed"
    echo "Install with: npm install -g vercel"
fi

echo ""
echo "Production Server Setup"
echo "----------------------"

read -p "Do you want to set up the production server? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter VPS hostname or IP: " VPS_HOST
    read -p "Enter SSH username: " VPS_USER
    read -p "Enter SSH port (default 22): " VPS_PORT
    VPS_PORT=${VPS_PORT:-22}
    
    echo ""
    echo "Testing SSH connection..."
    if ssh -o ConnectTimeout=5 -p $VPS_PORT $VPS_USER@$VPS_HOST "echo 'SSH connection successful'" 2>/dev/null; then
        print_status "SSH connection successful"
        
        echo "Setting up production server..."
        ssh -p $VPS_PORT $VPS_USER@$VPS_HOST << 'ENDSSH'
            # Install Docker if not present
            if ! command -v docker &> /dev/null; then
                curl -fsSL https://get.docker.com | sh
                sudo usermod -aG docker $USER
            fi
            
            # Create app directory
            mkdir -p ~/ufobeep
            
            # Create Docker network
            docker network create ufobeep-network 2>/dev/null || true
            
            echo "Production server setup complete"
ENDSSH
        print_status "Production server configured"
    else
        print_error "Failed to connect to VPS. Please check your credentials."
    fi
fi

echo ""
echo "SSL/TLS Setup"
echo "-------------"

echo "For production SSL/TLS, you'll need:"
echo "  1. Domain names pointing to your servers"
echo "  2. SSL certificates (Let's Encrypt recommended)"
echo "  3. Nginx or Traefik as reverse proxy"
echo ""
echo "Recommended setup:"
echo "  - api.yourdomain.com -> FastAPI backend"
echo "  - yourdomain.com -> Next.js frontend (Vercel)"
echo "  - app.yourdomain.com -> Flutter web build"

echo ""
echo "Database Backup"
echo "--------------"

cat > scripts/backup-db.sh << 'EOF'
#!/bin/bash
# Database backup script
BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR

# Backup PostgreSQL
docker exec ufobeep-db pg_dump -U postgres ufobeep | gzip > $BACKUP_DIR/db_backup_$TIMESTAMP.sql.gz
echo "Database backed up to $BACKUP_DIR/db_backup_$TIMESTAMP.sql.gz"

# Keep only last 7 backups
ls -t $BACKUP_DIR/db_backup_*.sql.gz | tail -n +8 | xargs -r rm
EOF

chmod +x scripts/backup-db.sh
print_status "Created database backup script"

echo ""
echo "Monitoring Setup"
echo "---------------"

cat > docker-compose.monitoring.yml << 'EOF'
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"
    networks:
      - ufobeep-network

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
    networks:
      - ufobeep-network

volumes:
  prometheus_data:
  grafana_data:

networks:
  ufobeep-network:
    external: true
EOF

print_status "Created monitoring configuration"

echo ""
echo "==========================="
echo "✅ Deployment setup complete!"
echo ""
echo "Next steps:"
echo "  1. Configure your .env file with production values"
echo "  2. Set up GitHub secrets (see .github/secrets.example.md)"
echo "  3. Configure your domain DNS"
echo "  4. Run 'docker-compose up -d' to start services"
echo "  5. Deploy to production with 'git push origin main'"
echo ""
echo "Useful commands:"
echo "  - Start services: docker-compose up -d"
echo "  - View logs: docker-compose logs -f"
echo "  - Stop services: docker-compose down"
echo "  - Backup database: ./scripts/backup-db.sh"
echo "  - Deploy to Vercel: vercel --prod"
echo ""
echo "Happy deploying! 🚀"