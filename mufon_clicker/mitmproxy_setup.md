# MUFON HTTP Capture Setup with mitmproxy

## Installation
```bash
# Install mitmproxy
sudo apt install mitmproxy

# Or download directly
wget https://snapshots.mitmproxy.org/9.0.1/mitmproxy-9.0.1-linux.tar.gz
tar -xzf mitmproxy-9.0.1-linux.tar.gz
```

## Setup Steps

1. **Start mitmproxy**
```bash
# Start proxy on port 8080
mitmproxy --port 8080

# Or with web interface
mitmweb --port 8080 --web-port 8081
```

2. **Configure Browser**
- Set HTTP proxy: `localhost:8080`
- Set HTTPS proxy: `localhost:8080`
- In Firefox: Settings → Network Settings → Manual proxy

3. **Install mitmproxy Certificate**
- Visit http://mitm.it while proxy is active
- Download certificate for your browser
- Install in browser's certificate store

4. **Capture MUFON Requests**
- Login to MUFON with proxy active
- Perform date search
- Click VIEW buttons
- All requests will be captured

5. **Export Captured Requests**
```bash
# Save flow to file
mitmdump -r captured.flow

# Export as HAR file
mitmdump -r captured.flow --export-har mufon_requests.har

# Export as curl commands
mitmdump -r captured.flow --export-curl-command
```

## Key Requests to Capture

1. **Login POST**
   - URL: `https://mufon.z2systems.com/np/clients/mufon/login.jsp`
   - Capture form data and cookies

2. **Search Form Submission**
   - URL: Search form action
   - Capture date parameters

3. **Results Table**
   - URL: iframe source or results endpoint
   - Capture pagination/filtering

4. **VIEW Button Click**
   - URL: `https://mufoncms.com/cgi-bin/public_report_handler.pl`
   - Capture case_id parameter

5. **Media Downloads**
   - URL: `https://mufoncms.com/cgi-bin/manage_attachment_images.pl`
   - Capture authentication cookies

## Python Script from Captures
Once captured, create httpx-based script:

```python
import httpx

# Use captured cookies
cookies = {
    'JSESSIONID': 'captured_value',
    # other cookies from mitmproxy
}

# Replay captured requests
client = httpx.Client(cookies=cookies)

# Login (if needed)
login_data = {
    'loginName': 'user',
    'loginPassword': 'pass',
    # captured form fields
}
response = client.post('https://mufon.z2systems.com/np/clients/mufon/login.jsp', data=login_data)

# Search with captured parameters
search_data = {
    'event_start_month': '09',
    'event_start_day': '03',
    'event_start_year': '2024',
    # other captured fields
}
response = client.post('captured_search_url', data=search_data)
```

## Alternative: Browser DevTools
1. Open Chrome/Firefox DevTools (F12)
2. Go to Network tab
3. Perform MUFON actions
4. Right-click requests → Copy as cURL
5. Convert to Python with https://curlconverter.com