#!/usr/bin/env python3
"""
Mobile network capture: monitors device traffic for MUFON requests
"""
import json, time, subprocess, re
from pathlib import Path

ART = Path("mufon_artifacts")
ART.mkdir(exist_ok=True)
CAPTURE = ART / "mobile_captured_requests.jsonl"

def capture_http_traffic():
    """Monitor network traffic using tcpdump or similar"""
    print("🔍 Monitoring network traffic for MUFON/z2systems requests...")
    print("📱 Now open browser on phone and navigate to MUFON search")
    print("🎯 Go to: mufon.com → Track UFOs → Database Search")
    print("📅 Set date range to last 2 days and search")
    print("⏹️  Press Ctrl+C when done\n")
    
    with open(CAPTURE, "w") as f:
        f.write("")  # Clear file
    
    try:
        # Use netstat to monitor active connections (simple approach)
        while True:
            time.sleep(1)
            try:
                # Monitor for any z2systems/neon/mufon connections
                result = subprocess.run(['netstat', '-tuln'], capture_output=True, text=True)
                connections = result.stdout
                
                if any(keyword in connections.lower() for keyword in ['z2systems', 'neon', 'mufon']):
                    timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
                    print(f"[{timestamp}] 🎯 Detected MUFON-related connection!")
                    
                    # Log the detection
                    with open(CAPTURE, "a") as f:
                        f.write(json.dumps({
                            "time": time.time(),
                            "timestamp": timestamp,
                            "type": "connection_detected",
                            "details": "MUFON-related network activity detected"
                        }) + "\n")
                        
            except Exception as e:
                pass
                
    except KeyboardInterrupt:
        print("\n✅ Capture stopped. Check the results!")
        return True

def main():
    print("📱 MUFON Mobile Capture Tool")
    print("=" * 50)
    capture_http_traffic()
    
    if CAPTURE.exists() and CAPTURE.stat().st_size > 0:
        print(f"\n📊 Captured data saved to: {CAPTURE}")
        print("\nNext steps:")
        print("1. Check browser network developer tools on phone")
        print("2. Look for POST requests to z2systems/neon domains")
        print("3. Copy the request details to build httpx scraper")
    else:
        print("\n⚠️ No specific requests captured.")
        print("Try using browser developer tools on the phone instead.")

if __name__ == "__main__":
    main()