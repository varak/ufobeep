#!/bin/bash
# UFOBeep API Startup Script

cd /home/ufobeep/ufobeep/api

# Kill any existing processes
pkill -f "uvicorn.*8000" 2>/dev/null
pkill -f "simple_email_api" 2>/dev/null

# Wait for processes to die
sleep 2

# Activate virtual environment and start the main FastAPI application
source ../venv/bin/activate
exec uvicorn app.main:app --host 0.0.0.0 --port 8000