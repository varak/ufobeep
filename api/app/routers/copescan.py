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
DEFAULT_DEVTAX_CREDENTIALS = {
    "username": "mike@emke.com",
    "password": "cope123123A!",
    "account_name": "default",
    "last_updated": datetime.utcnow().isoformat()
}

# Path to config file on production server
CONFIG_FILE_PATH = "/home/ufobeep/copescan-config.json"

def load_devtax_config():
    """Load DevTax configuration from file, with fallback to defaults"""
    try:
        config_path = Path(CONFIG_FILE_PATH)
        if config_path.exists():
            with open(config_path, 'r') as f:
                config = json.load(f)
                logger.info(f"Loaded DevTax config: account={config.get('account_name', 'unknown')}")
                return config
        else:
            logger.warning(f"Config file not found at {CONFIG_FILE_PATH}, using defaults")
            return DEFAULT_DEVTAX_CREDENTIALS
    except Exception as e:
        logger.error(f"Failed to load DevTax config: {e}")
        return DEFAULT_DEVTAX_CREDENTIALS

def save_devtax_config(config):
    """Save DevTax configuration to file"""
    try:
        config_path = Path(CONFIG_FILE_PATH)
        config_path.parent.mkdir(parents=True, exist_ok=True)
        
        # Add timestamp
        config["last_updated"] = datetime.utcnow().isoformat()
        
        with open(config_path, 'w') as f:
            json.dump(config, f, indent=2)
        
        logger.info(f"Saved DevTax config: account={config.get('account_name', 'unknown')}")
        return True
    except Exception as e:
        logger.error(f"Failed to save DevTax config: {e}")
        return False

@router.get("/devtax-config")
async def get_devtax_config():
    """
    Returns current DevTax account credentials for CopeScan app.
    Used by mobile app to get current account for every 10th submission.
    """
    try:
        config = load_devtax_config()
        
        # Return only the fields needed by the mobile app
        return {
            "username": config["username"],
            "password": config["password"],
            "account_name": config.get("account_name", "default"),
            "last_updated": config.get("last_updated", "unknown")
        }
    except Exception as e:
        logger.error(f"Error getting DevTax config: {e}")
        # Return defaults on any error
        return {
            "username": DEFAULT_DEVTAX_CREDENTIALS["username"],
            "password": DEFAULT_DEVTAX_CREDENTIALS["password"],
            "account_name": "default",
            "last_updated": datetime.utcnow().isoformat()
        }

@router.post("/devtax-config")
async def update_devtax_config(config: dict):
    """
    Update DevTax configuration. For use by account management scripts.
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
        success = save_devtax_config(config)
        if not success:
            raise HTTPException(status_code=500, detail="Failed to save configuration")
        
        logger.info(f"Updated DevTax config via API: account={config['account_name']}")
        
        return {
            "success": True,
            "message": f"DevTax configuration updated successfully",
            "account_name": config["account_name"],
            "username": config["username"],
            "updated_at": datetime.utcnow().isoformat()
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating DevTax config: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to update configuration: {str(e)}")

@router.get("/devtax-status")
async def get_devtax_status():
    """
    Get status information about current DevTax configuration.
    Useful for monitoring and debugging.
    """
    try:
        config = load_devtax_config()
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
        logger.error(f"Error getting DevTax status: {e}")
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