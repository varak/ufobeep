#!/bin/bash
# UFOBeep API Startup Script

cd /home/ufobeep/ufobeep/api

# Kill any existing processes
pkill -f "uvicorn.*8000" 2>/dev/null
pkill -f "simple_email_api" 2>/dev/null

# Wait for processes to die
sleep 2

# Activate virtual environment and start simple email API (which works)
source venv/bin/activate
exec python simple_email_api.py