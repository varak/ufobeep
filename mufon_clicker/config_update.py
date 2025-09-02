#!/usr/bin/env python3
# Quick script to update the configuration in extend_mufon_details.py

import re

# Read the file
with open('extend_mufon_details.py', 'r') as f:
    content = f.read()

# Update the configuration
content = re.sub(
    r'RESULTS_URL = "PASTE_RESULTS_URL_HERE".*',
    'RESULTS_URL = "https://mufon.app.neoncrm.com/np/publicaccess/neonPage.do?pageId=19&"',
    content
)

# Write back
with open('extend_mufon_details.py', 'w') as f:
    f.write(content)

print("Configuration updated successfully")