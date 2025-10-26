#!/bin/bash
# Setup script for NUFORC Stealth Scraper
# Run this once to install all dependencies

echo "🥷 Setting up NUFORC Stealth Scraper..."

# Install Python dependencies
echo "📦 Installing Python packages..."
pip install -r requirements_stealth.txt

# Install Playwright browser
echo "🌐 Installing Chromium browser for Playwright..."
playwright install chromium

# Check if .env exists
if [ ! -f .env ]; then
    echo "📝 Creating .env file template..."
    cat > .env << 'EOF'
# Google Gemini API Key (get free key from https://ai.google.dev/)
GEMINI_API_KEY=your_gemini_api_key_here

# Optional: Add other environment variables here
EOF
    echo "⚠️  Please edit .env file and add your Gemini API key"
    echo "   Get free key from: https://ai.google.dev/"
else
    echo "✅ .env file already exists"
fi

# Make scripts executable
chmod +x nuforc_stealth.py

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Usage:"
echo "  python3 nuforc_stealth.py yesterday   # Get yesterday's reports"
echo "  python3 nuforc_stealth.py today       # Get today's reports"
echo "  python3 nuforc_stealth.py 2025-10-25  # Get specific date"
echo ""
echo "Don't forget to:"
echo "1. Add your Gemini API key to .env file"
echo "2. Test with a recent date first"
echo "3. Set up daily cron job for automation"