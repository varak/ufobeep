from fastapi import APIRouter, HTTPException
from fastapi.responses import JSONResponse
import json
import os
from pathlib import Path
from datetime import datetime
import logging

logger = logging.getLogger(__name__)

router = APIRouter()

# Default fallback credentials (same as currently hardcoded in app)
DEFAULT_DEVSHARE_CREDENTIALS = {
    "username": "mike@emke.com",
    "password": "cope123123A!",
    "account_name": "default",
    "last_updated": datetime.utcnow().isoformat()
}

# Path to config file on production server
CONFIG_FILE_PATH = "/home/ufobeep/copescan-config.json"

def load_devshare_config():
    """Load DevShare configuration from file, with fallback to defaults"""
    try:
        config_path = Path(CONFIG_FILE_PATH)
        if config_path.exists():
            with open(config_path, 'r') as f:
                config = json.load(f)
                logger.info(f"Loaded DevShare config: account={config.get('account_name', 'unknown')}")
                return config
        else:
            logger.warning(f"Config file not found at {CONFIG_FILE_PATH}, using defaults")
            return DEFAULT_DEVSHARE_CREDENTIALS
    except Exception as e:
        logger.error(f"Failed to load DevShare config: {e}")
        return DEFAULT_DEVSHARE_CREDENTIALS

def save_devshare_config(config):
    """Save DevShare configuration to file"""
    try:
        config_path = Path(CONFIG_FILE_PATH)
        config_path.parent.mkdir(parents=True, exist_ok=True)
        
        # Add timestamp
        config["last_updated"] = datetime.utcnow().isoformat()
        
        with open(config_path, 'w') as f:
            json.dump(config, f, indent=2)
        
        logger.info(f"Saved DevShare config: account={config.get('account_name', 'unknown')}")
        return True
    except Exception as e:
        logger.error(f"Failed to save DevShare config: {e}")
        return False

@router.get("/devshare-config")
async def get_devshare_config():
    """
    Returns current DevShare account credentials for CopeScan app.
    Used by mobile app to get current account for every 10th submission.
    """
    try:
        config = load_devshare_config()
        
        # Return only the fields needed by the mobile app
        return {
            "username": config["username"],
            "password": config["password"],
            "account_name": config.get("account_name", "default"),
            "last_updated": config.get("last_updated", "unknown")
        }
    except Exception as e:
        logger.error(f"Error getting DevShare config: {e}")
        # Return defaults on any error
        return {
            "username": DEFAULT_DEVSHARE_CREDENTIALS["username"],
            "password": DEFAULT_DEVSHARE_CREDENTIALS["password"],
            "account_name": "default",
            "last_updated": datetime.utcnow().isoformat()
        }

@router.post("/devshare-config")
async def update_devshare_config(config: dict):
    """
    Update DevShare configuration. For use by account management scripts.
    Expected format: {"username": "email", "password": "pass", "account_name": "name"}
    """
    try:
        # Validate required fields
        required_fields = ["username", "password"]
        for field in required_fields:
            if field not in config:
                raise HTTPException(status_code=400, detail=f"Missing required field: {field}")
        
        # Add account name if not provided
        if "account_name" not in config:
            config["account_name"] = f"account_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}"
        
        # Save configuration
        success = save_devshare_config(config)
        if not success:
            raise HTTPException(status_code=500, detail="Failed to save configuration")
        
        logger.info(f"Updated DevShare config via API: account={config['account_name']}")
        
        return {
            "success": True,
            "message": f"DevShare configuration updated successfully",
            "account_name": config["account_name"],
            "username": config["username"],
            "updated_at": datetime.utcnow().isoformat()
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating DevShare config: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to update configuration: {str(e)}")

@router.get("/devshare-status")
async def get_devshare_status():
    """
    Get status information about current DevShare configuration.
    Useful for monitoring and debugging.
    """
    try:
        config = load_devshare_config()
        config_path = Path(CONFIG_FILE_PATH)
        
        return {
            "current_account": config.get("account_name", "default"),
            "username": config["username"],
            "last_updated": config.get("last_updated", "unknown"),
            "config_file_exists": config_path.exists(),
            "config_file_path": CONFIG_FILE_PATH,
            "file_modified": config_path.stat().st_mtime if config_path.exists() else None,
            "status": "active"
        }
    except Exception as e:
        logger.error(f"Error getting DevShare status: {e}")
        return {
            "current_account": "error",
            "username": "error",
            "last_updated": "error",
            "config_file_exists": False,
            "config_file_path": CONFIG_FILE_PATH,
            "file_modified": None,
            "status": "error",
            "error": str(e)
        }