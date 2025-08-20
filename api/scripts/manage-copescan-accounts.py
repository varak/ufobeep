#!/usr/bin/env python3
"""
CopeScan Account Management Script

This script manages DevShare accounts for the CopeScan app.
It can add accounts, rotate active accounts, and track submission counts.

Usage:
    python manage-copescan-accounts.py add-account --username user@example.com --password mypass --name "Account 1"
    python manage-copescan-accounts.py list-accounts
    python manage-copescan-accounts.py set-active --name "Account 1"
    python manage-copescan-accounts.py rotate
    python manage-copescan-accounts.py status
"""

import argparse
import json
import requests
import sys
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional
import secrets
import string

# Configuration
CONFIG_FILE = "/home/ufobeep/copescan-config.json"
ACCOUNTS_FILE = "/home/ufobeep/copescan-accounts.json"
API_BASE_URL = "https://api.ufobeep.com/copescan"
FRESH_COPE_URL = "https://www.freshcope.com/rewards/earn"

def generate_secure_password(length=12):
    """Generate a secure random password"""
    alphabet = string.ascii_letters + string.digits + "!@#$%^&*"
    return ''.join(secrets.choice(alphabet) for _ in range(length))

def load_accounts() -> Dict:
    """Load accounts database from file"""
    accounts_path = Path(ACCOUNTS_FILE)
    if accounts_path.exists():
        with open(accounts_path, 'r') as f:
            return json.load(f)
    return {
        "accounts": [],
        "created": datetime.utcnow().isoformat(),
        "last_updated": datetime.utcnow().isoformat()
    }

def save_accounts(accounts_data: Dict):
    """Save accounts database to file"""
    accounts_data["last_updated"] = datetime.utcnow().isoformat()
    
    accounts_path = Path(ACCOUNTS_FILE)
    accounts_path.parent.mkdir(parents=True, exist_ok=True)
    
    with open(accounts_path, 'w') as f:
        json.dump(accounts_data, f, indent=2)

def validate_credentials(username: str, password: str) -> bool:
    """Validate credentials against Fresh Cope website"""
    try:
        print(f"Validating credentials for {username}...")
        
        response = requests.post(FRESH_COPE_URL, 
            data={
                'username': username,
                'password': password,
                'code': 'TEST1-2345-6789'  # Test code (will fail but shows if login works)
            },
            headers={
                'Content-Type': 'application/x-www-form-urlencoded',
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
            },
            timeout=10
        )
        
        # Check if we got a login error vs invalid code error
        if response.status_code == 200:
            response_text = response.text.lower()
            if 'invalid login' in response_text or 'incorrect username' in response_text:
                return False
            # If we got here, login worked (even if code was invalid)
            return True
        else:
            return False
            
    except Exception as e:
        print(f"Error validating credentials: {e}")
        return False

def update_active_config(username: str, password: str, account_name: str):
    """Update the active DevShare configuration"""
    try:
        config_data = {
            "username": username,
            "password": password,
            "account_name": account_name,
            "last_updated": datetime.utcnow().isoformat()
        }
        
        # Update via API
        response = requests.post(f"{API_BASE_URL}/devshare-config", json=config_data, timeout=10)
        if response.status_code == 200:
            print(f"✅ Successfully updated active DevShare account to: {account_name}")
            return True
        else:
            print(f"❌ Failed to update via API: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Error updating active config: {e}")
        return False

def add_account(username: str, password: str, name: str, validate: bool = True):
    """Add a new account to the database"""
    accounts_data = load_accounts()
    
    # Check if account already exists
    for account in accounts_data["accounts"]:
        if account["username"] == username:
            print(f"❌ Account {username} already exists")
            return False
        if account["name"] == name:
            print(f"❌ Account name '{name}' already exists")
            return False
    
    # Validate credentials if requested
    if validate and not validate_credentials(username, password):
        print(f"❌ Failed to validate credentials for {username}")
        return False
    
    # Add account
    new_account = {
        "name": name,
        "username": username,
        "password": password,
        "created": datetime.utcnow().isoformat(),
        "submissions_this_month": 0,
        "last_used": None,
        "status": "active"
    }
    
    accounts_data["accounts"].append(new_account)
    save_accounts(accounts_data)
    
    print(f"✅ Added account: {name} ({username})")
    return True

def list_accounts():
    """List all accounts"""
    accounts_data = load_accounts()
    
    if not accounts_data["accounts"]:
        print("No accounts found")
        return
    
    print("\n📋 CopeScan Accounts:")
    print("-" * 80)
    
    for i, account in enumerate(accounts_data["accounts"], 1):
        status_icon = "🟢" if account["status"] == "active" else "🔴"
        submissions = account.get("submissions_this_month", 0)
        last_used = account.get("last_used", "Never")
        if last_used != "Never":
            last_used = datetime.fromisoformat(last_used).strftime("%Y-%m-%d %H:%M")
        
        print(f"{i}. {status_icon} {account['name']}")
        print(f"   Username: {account['username']}")
        print(f"   Submissions: {submissions}/30")
        print(f"   Last used: {last_used}")
        print(f"   Created: {datetime.fromisoformat(account['created']).strftime('%Y-%m-%d')}")
        print()

def set_active_account(name: str):
    """Set an account as the active DevShare account"""
    accounts_data = load_accounts()
    
    # Find account
    target_account = None
    for account in accounts_data["accounts"]:
        if account["name"] == name:
            target_account = account
            break
    
    if not target_account:
        print(f"❌ Account '{name}' not found")
        return False
    
    if target_account["status"] != "active":
        print(f"❌ Account '{name}' is not active")
        return False
    
    # Update active configuration
    success = update_active_config(
        target_account["username"],
        target_account["password"],
        target_account["name"]
    )
    
    if success:
        # Update last_used timestamp
        target_account["last_used"] = datetime.utcnow().isoformat()
        save_accounts(accounts_data)
    
    return success

def rotate_account():
    """Automatically rotate to the next available account"""
    accounts_data = load_accounts()
    
    # Find active accounts with < 25 submissions (leave buffer)
    available_accounts = [
        acc for acc in accounts_data["accounts"]
        if acc["status"] == "active" and acc.get("submissions_this_month", 0) < 25
    ]
    
    if not available_accounts:
        print("❌ No available accounts for rotation")
        return False
    
    # Sort by least used
    available_accounts.sort(key=lambda x: x.get("submissions_this_month", 0))
    next_account = available_accounts[0]
    
    print(f"🔄 Rotating to account: {next_account['name']} ({next_account.get('submissions_this_month', 0)} submissions)")
    
    return set_active_account(next_account["name"])

def show_status():
    """Show current system status"""
    try:
        # Get current active account
        response = requests.get(f"{API_BASE_URL}/devshare-status", timeout=10)
        if response.status_code == 200:
            status = response.json()
            print("\n📊 CopeScan DevShare Status:")
            print("-" * 40)
            print(f"Active Account: {status['current_account']}")
            print(f"Username: {status['username']}")
            print(f"Last Updated: {status['last_updated']}")
            print(f"Config File: {'✅ Exists' if status['config_file_exists'] else '❌ Missing'}")
            print(f"System Status: {status['status']}")
        else:
            print(f"❌ Failed to get status: {response.status_code}")
    except Exception as e:
        print(f"❌ Error getting status: {e}")
    
    # Show account summary
    accounts_data = load_accounts()
    if accounts_data["accounts"]:
        print(f"\n📈 Account Summary:")
        print(f"Total Accounts: {len(accounts_data['accounts'])}")
        active_count = len([acc for acc in accounts_data['accounts'] if acc['status'] == 'active'])
        print(f"Active Accounts: {active_count}")
        
        total_submissions = sum(acc.get('submissions_this_month', 0) for acc in accounts_data['accounts'])
        print(f"Total Submissions This Month: {total_submissions}")

def main():
    parser = argparse.ArgumentParser(description="CopeScan Account Management")
    subparsers = parser.add_subparsers(dest='command', help='Available commands')
    
    # Add account command
    add_parser = subparsers.add_parser('add-account', help='Add a new account')
    add_parser.add_argument('--username', required=True, help='Account username/email')
    add_parser.add_argument('--password', help='Account password (will generate if not provided)')
    add_parser.add_argument('--name', required=True, help='Friendly account name')
    add_parser.add_argument('--no-validate', action='store_true', help='Skip credential validation')
    
    # List accounts command
    subparsers.add_parser('list-accounts', help='List all accounts')
    
    # Set active command
    set_parser = subparsers.add_parser('set-active', help='Set active account')
    set_parser.add_argument('--name', required=True, help='Account name to activate')
    
    # Rotate command
    subparsers.add_parser('rotate', help='Rotate to next available account')
    
    # Status command
    subparsers.add_parser('status', help='Show system status')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        return
    
    if args.command == 'add-account':
        password = args.password
        if not password:
            password = generate_secure_password()
            print(f"Generated password: {password}")
        
        add_account(args.username, password, args.name, validate=not args.no_validate)
        
    elif args.command == 'list-accounts':
        list_accounts()
        
    elif args.command == 'set-active':
        set_active_account(args.name)
        
    elif args.command == 'rotate':
        rotate_account()
        
    elif args.command == 'status':
        show_status()

if __name__ == '__main__':
    main()