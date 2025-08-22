#!/usr/bin/env python3
"""
DKIM Setup for UFOBeep
Generates DKIM keys and provides DNS record information
"""

import subprocess
import os
import sys

def setup_dkim_for_ufobeep():
    """Set up DKIM for ufobeep.com"""
    domain = "ufobeep.com"
    
    print(f"🔐 Setting up DKIM for {domain}")
    
    # Install opendkim if not present
    try:
        subprocess.run(["sudo", "apt", "update"], check=True)
        subprocess.run(["sudo", "apt", "install", "-y", "opendkim", "opendkim-tools"], check=True)
        print("✅ OpenDKIM installed")
    except subprocess.CalledProcessError:
        print("❌ Failed to install OpenDKIM")
        return False
    
    # Create DKIM directory
    dkim_dir = f"/etc/opendkim"
    keys_dir = f"{dkim_dir}/keys/{domain}"
    
    try:
        os.makedirs(keys_dir, exist_ok=True)
        print(f"✅ Created DKIM directory: {keys_dir}")
    except Exception as e:
        print(f"❌ Failed to create directory: {e}")
        return False
    
    # Generate DKIM key pair
    private_key_path = f"{keys_dir}/default.private"
    public_key_path = f"{keys_dir}/default.txt"
    
    try:
        # Generate 2048-bit RSA key
        subprocess.run([
            "opendkim-genkey", 
            "-b", "2048",
            "-d", domain,
            "-D", keys_dir,
            "-s", "default"
        ], check=True)
        
        print("✅ DKIM keys generated")
        
        # Read the public key for DNS
        with open(public_key_path, 'r') as f:
            public_key_content = f.read()
        
        print("\n" + "="*50)
        print("📋 DNS RECORD TO ADD:")
        print("="*50)
        print(public_key_content)
        print("="*50)
        
        # Set proper permissions
        subprocess.run(["sudo", "chown", "-R", "opendkim:opendkim", dkim_dir], check=True)
        subprocess.run(["sudo", "chmod", "600", private_key_path], check=True)
        subprocess.run(["sudo", "chmod", "644", public_key_path], check=True)
        
        print("✅ DKIM permissions set")
        
        return True
        
    except Exception as e:
        print(f"❌ Failed to generate DKIM keys: {e}")
        return False

def configure_postfix_dkim():
    """Configure Postfix to use DKIM"""
    print("\n🔧 Configuring Postfix for DKIM...")
    
    # OpenDKIM configuration
    opendkim_conf = """
# OpenDKIM Configuration for UFOBeep
Syslog yes
UMask 002
Domain ufobeep.com
KeyFile /etc/opendkim/keys/ufobeep.com/default.private
Selector default
SOCKET inet:8891@localhost
PidFile /var/run/opendkim/opendkim.pid
SignatureAlgorithm rsa-sha256
Mode sv
SubDomains no
AutoRestart yes
AutoRestartRate 10/1h
Background yes
DNSTimeout 5
SignatureExpireTime 1209600
"""
    
    try:
        with open("/tmp/opendkim.conf", "w") as f:
            f.write(opendkim_conf.strip())
        
        subprocess.run(["sudo", "cp", "/tmp/opendkim.conf", "/etc/opendkim.conf"], check=True)
        print("✅ OpenDKIM configuration written")
        
        # Add Postfix configuration
        postfix_additions = """
# DKIM Configuration
milter_default_action = accept
milter_protocol = 2
smtpd_milters = inet:localhost:8891
non_smtpd_milters = $smtpd_milters
"""
        
        with open("/tmp/postfix_dkim.conf", "w") as f:
            f.write(postfix_additions.strip())
        
        # Append to main.cf
        subprocess.run(["sudo", "sh", "-c", "cat /tmp/postfix_dkim.conf >> /etc/postfix/main.cf"], check=True)
        print("✅ Postfix DKIM configuration added")
        
        return True
        
    except Exception as e:
        print(f"❌ Failed to configure DKIM: {e}")
        return False

def restart_services():
    """Restart email services"""
    print("\n🔄 Restarting email services...")
    
    try:
        subprocess.run(["sudo", "systemctl", "enable", "opendkim"], check=True)
        subprocess.run(["sudo", "systemctl", "restart", "opendkim"], check=True)
        subprocess.run(["sudo", "systemctl", "restart", "postfix"], check=True)
        
        print("✅ Services restarted")
        return True
        
    except Exception as e:
        print(f"❌ Failed to restart services: {e}")
        return False

def main():
    """Main setup function"""
    print("🚀 UFOBeep DKIM Setup")
    print("=" * 30)
    
    if os.geteuid() == 0:
        print("❌ Don't run as root. Run as regular user with sudo privileges.")
        sys.exit(1)
    
    # Step 1: Generate DKIM keys
    if not setup_dkim_for_ufobeep():
        print("❌ DKIM setup failed")
        sys.exit(1)
    
    # Step 2: Configure Postfix
    if not configure_postfix_dkim():
        print("❌ Postfix configuration failed")  
        sys.exit(1)
    
    # Step 3: Restart services
    if not restart_services():
        print("❌ Service restart failed")
        sys.exit(1)
    
    print("\n🎉 DKIM setup complete!")
    print("\n📝 Next steps:")
    print("1. Add the DNS TXT record shown above to your domain")
    print("2. Update DMARC policy to: v=DMARC1; p=none; adkim=r; aspf=r;")
    print("3. Wait 24-48 hours for DNS propagation")
    print("4. Test email delivery")

if __name__ == "__main__":
    main()