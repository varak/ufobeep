#!/usr/bin/env python3
import httpx
import re

# Check the login form structure
with httpx.Client(timeout=30.0) as client:
    response = client.get('https://mufon.app.neoncrm.com/np/signIn.do')
    
    # Look for form inputs
    inputs = re.findall(r'<input[^>]*name=(["\'])([^"\']*)\1', response.text, re.IGNORECASE)
    print('Form inputs found:', [inp[1] for inp in inputs])
    
    # Save login page
    with open('debug_login_page.html', 'w') as f:
        f.write(response.text)
    print('Login form saved to debug_login_page.html')
    
    # Try to find the actual login form
    if 'username' in response.text.lower():
        print('Found username field')
    if 'email' in response.text.lower():
        print('Found email field') 
    if 'password' in response.text.lower():
        print('Found password field')