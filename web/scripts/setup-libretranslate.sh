#!/bin/bash

# Setup LibreTranslate on production server
# Run this on the production server: ssh -p 322 ufobeep@ufobeep.com

echo "🌐 Setting up LibreTranslate on production server..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    echo "⚠️  Please log out and back in for Docker group changes to take effect"
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Create LibreTranslate directory
mkdir -p /home/ufobeep/libretranslate
cd /home/ufobeep/libretranslate

# Create docker-compose.yml for LibreTranslate
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  libretranslate:
    image: libretranslate/libretranslate:latest
    restart: unless-stopped
    ports:
      - "5000:5000"
    environment:
      - LT_HOST=0.0.0.0
      - LT_PORT=5000
      - LT_API_KEYS=true
      - LT_API_KEYS_DB_PATH=/app/api_keys.db
      - LT_DISABLE_WEB_UI=false
      - LT_UPDATE_MODELS=false
    volumes:
      - lt-data:/home/libretranslate/.local
      - ./api_keys.db:/app/api_keys.db
    command: --api-keys --api-keys-db-path /app/api_keys.db
    
volumes:
  lt-data:
EOF

# Create systemd service file
sudo tee /etc/systemd/system/libretranslate.service > /dev/null << 'EOF'
[Unit]
Description=LibreTranslate Service
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/ufobeep/libretranslate
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
User=ufobeep
Group=ufobeep

[Install]
WantedBy=multi-user.target
EOF

# Create API key for UFOBeep
echo "Creating API keys database..."
touch api_keys.db

# Start LibreTranslate
echo "Starting LibreTranslate..."
sudo systemctl daemon-reload
sudo systemctl enable libretranslate
sudo systemctl start libretranslate

# Wait for service to start
echo "Waiting for LibreTranslate to start..."
sleep 30

# Add API key for UFOBeep
UFOBEEP_API_KEY="ufobeep_$(openssl rand -hex 16)"
curl -X POST "http://localhost:5000/create_api_key" \
     -H "Content-Type: application/json" \
     -d '{"req_limit":1000, "key":"'$UFOBEEP_API_KEY'"}'

echo "✅ LibreTranslate setup complete!"
echo "📝 API Key: $UFOBEEP_API_KEY"
echo "🌐 Service running on: http://localhost:5000"
echo ""
echo "Add this to your environment variables:"
echo "export LIBRETRANSLATE_API_KEY=$UFOBEEP_API_KEY"
echo "export LIBRETRANSLATE_URL=http://localhost:5000"

# Update nginx to proxy LibreTranslate (optional)
echo ""
echo "To add nginx proxy for external access, add to your nginx config:"
echo ""
echo "    location /translate/ {"
echo "        proxy_pass http://localhost:5000/;"
echo "        proxy_set_header Host \$host;"
echo "        proxy_set_header X-Real-IP \$remote_addr;"
echo "        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;"
echo "        proxy_set_header X-Forwarded-Proto \$scheme;"
echo "    }"