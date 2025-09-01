#!/usr/bin/env python3
"""
MUFON CMS Explorer - Login and analyze search capabilities
"""
import asyncio
import httpx
from bs4 import BeautifulSoup
from datetime import datetime, timedelta
import json

async def explore_mufon_cms():
    """Login to MUFON CMS and explore search capabilities"""
    
    # Credentials from secrets file
    username = "varak"
    password = "ufobeep123pass"
    
    async with httpx.AsyncClient(follow_redirects=True) as client:
        print("Step 1: Getting login page...")
        
        # Get login page to extract form details
        login_page = await client.get("https://mufon.app.neoncrm.com/np/clients/mufon/login.jsp")
        soup = BeautifulSoup(login_page.text, 'html.parser')
        
        print("Login page HTML structure:")
        print(f"Title: {soup.title.get_text() if soup.title else 'No title'}")
        
        # Find the login form and extract ALL details
        forms = soup.find_all('form')
        print(f"Found {len(forms)} forms on login page")
        
        login_form = None
        for i, form in enumerate(forms):
            action = form.get('action')
            method = form.get('method', 'GET')
            print(f"  Form {i}: action='{action}', method='{method}'")
            
            inputs = form.find_all('input')
            for inp in inputs:
                inp_type = inp.get('type', 'text')
                inp_name = inp.get('name', 'unnamed')
                inp_value = inp.get('value', '')
                print(f"    Input: {inp_type} name='{inp_name}' value='{inp_value}'")
            
            # Use the form with signIn.do action (the actual login form)
            if action and 'signIn.do' in action:
                login_form = form
        
        if not login_form:
            print("❌ No login form found!")
            return None
        
        # Extract form action and method
        form_action = login_form.get('action')
        form_method = login_form.get('method', 'POST').upper()
        
        # If action is relative, make it absolute
        if form_action and not form_action.startswith('http'):
            if form_action.startswith('/'):
                form_action = f"https://mufon.app.neoncrm.com{form_action}"
            else:
                form_action = f"https://mufon.app.neoncrm.com/np/clients/mufon/{form_action}"
        
        # Extract all input fields
        form_data = {}
        for inp in login_form.find_all('input'):
            name = inp.get('name')
            value = inp.get('value', '')
            inp_type = inp.get('type', 'text')
            
            if name:
                if inp_type == 'submit':
                    continue  # Skip submit buttons for now
                elif name.lower() in ['username', 'loginname', 'login']:
                    form_data[name] = username
                elif name.lower() in ['password', 'pwd', 'loginpassword']:
                    form_data[name] = password
                else:
                    form_data[name] = value
        
        print(f"Form action: {form_action}")
        print(f"Form method: {form_method}")
        print(f"Form data: {form_data}")
        
        print("Step 2: Attempting login...")
        
        # Perform login
        login_url = form_action or str(login_page.url)
        login_response = await client.request(
            form_method,
            login_url,
            data=form_data,
            headers={
                'Content-Type': 'application/x-www-form-urlencoded',
                'Referer': str(login_page.url)
            }
        )
        
        print(f"Login response status: {login_response.status_code}")
        print(f"Final URL after login: {login_response.url}")
        
        # Check if login was successful
        if "login" in str(login_response.url).lower() and login_response.status_code != 200:
            print("❌ Login may have failed - still on login page")
            return None
        
        print("✅ Login appears successful!")
        
        # Now explore the authenticated site
        print("\nStep 3: Exploring authenticated areas...")
        
        # We're already on the account home page after login
        dashboard_soup = BeautifulSoup(login_response.text, 'html.parser')
        
        print(f"Authenticated page title: {dashboard_soup.title.get_text() if dashboard_soup.title else 'No title'}")
        
        # Look for specific MUFON functionality
        print("\nSearching for MUFON-specific links and forms...")
        
        # Look for case management, reports, or database access
        mufon_links = []
        all_links = dashboard_soup.find_all('a', href=True)
        
        for link in all_links:
            href = link.get('href')
            text = link.get_text(strip=True)
            if text and href and any(keyword in text.lower() for keyword in 
                ['case', 'report', 'sighting', 'investigation', 'database', 'cms', 'search']):
                mufon_links.append((text, href))
        
        print("MUFON-related links found:")
        for text, href in mufon_links:
            if not href.startswith('http'):
                if href.startswith('/'):
                    href = f"https://mufon.app.neoncrm.com{href}"
                else:
                    href = f"https://mufon.app.neoncrm.com/{href}"
            print(f"  - {text}: {href}")
        
        # Also check for any forms on the authenticated page
        auth_forms = dashboard_soup.find_all('form')
        print(f"\nFound {len(auth_forms)} forms on authenticated dashboard")
        
        for i, form in enumerate(auth_forms):
            action = form.get('action', 'No action')
            method = form.get('method', 'GET')
            inputs = form.find_all(['input', 'select', 'textarea'])
            print(f"  Form {i+1}: {action} ({method}) with {len(inputs)} fields")
            
            # Show relevant form fields
            for inp in inputs[:3]:
                inp_type = inp.get('type', inp.name)
                inp_name = inp.get('name', 'unnamed')
                print(f"    - {inp_type}: {inp_name}")
        
        # Extract navigation links and available sections
        nav_links = []
        for link in dashboard_soup.find_all('a', href=True):
            href = link.get('href')
            text = link.get_text(strip=True)
            if href and text and len(text) > 2:
                nav_links.append((text, href))
        
        print("Available navigation options:")
        for text, href in nav_links[:20]:  # Show first 20 links
            print(f"  - {text}: {href}")
        
        # Look for search functionality
        search_forms = dashboard_soup.find_all('form')
        search_inputs = dashboard_soup.find_all('input', {'type': 'search'})
        
        print(f"\nFound {len(search_forms)} forms and {len(search_inputs)} search inputs")
        
        # Try to find case/report search functionality
        print("\nStep 4: Looking for case/report search...")
        
        # Common MUFON CMS URLs to try (now authenticated)
        test_urls = [
            "https://mufon.app.neoncrm.com/np/clients/mufon/caseManagementSystem/caseManagementHome.do",
            "https://mufon.app.neoncrm.com/np/clients/mufon/caseManagementSystem/caseSearchInput.do", 
            "https://mufon.app.neoncrm.com/np/clients/mufon/caseManagementSystem/caseAdvancedSearchInput.do",
            "https://mufon.app.neoncrm.com/np/clients/mufon/caseManagementSystem/caseReportInput.do",
            "https://mufon.app.neoncrm.com/np/clients/mufon/reports/",
            "https://mufon.app.neoncrm.com/np/clients/mufon/cases/",
            "https://mufon.app.neoncrm.com/np/clients/mufon/sightings/",
            "https://mufon.app.neoncrm.com/np/clients/mufon/search/",
            "https://mufon.app.neoncrm.com/np/clients/mufon/caseManagementSystem/",
            "https://mufon.app.neoncrm.com/np/admin/",
            "https://mufon.app.neoncrm.com/np/clients/mufon/",
        ]
        
        for test_url in test_urls:
            try:
                test_response = await client.get(test_url)
                print(f"  {test_url}: {test_response.status_code}")
                
                if test_response.status_code == 200:
                    test_soup = BeautifulSoup(test_response.text, 'html.parser')
                    
                    # Look for search forms
                    forms = test_soup.find_all('form')
                    if forms:
                        print(f"    Found {len(forms)} forms on this page")
                        
                        for i, form in enumerate(forms):
                            inputs = form.find_all(['input', 'select', 'textarea'])
                            if inputs:
                                print(f"      Form {i+1} has {len(inputs)} fields:")
                                for inp in inputs[:5]:  # Show first 5 fields
                                    field_type = inp.get('type', inp.name)
                                    field_name = inp.get('name', 'unnamed')
                                    print(f"        - {field_type}: {field_name}")
                    
                    # Look for data tables
                    tables = test_soup.find_all('table')
                    if tables:
                        print(f"    Found {len(tables)} data tables")
                        
                        for i, table in enumerate(tables):
                            headers = [th.get_text(strip=True) for th in table.find_all(['th', 'td'])[:10]]
                            if headers:
                                print(f"      Table {i+1} headers: {headers}")
            
            except Exception as e:
                print(f"  {test_url}: Error - {e}")
        
        # Try to perform a date-based search if we find a form
        print("\nStep 5: Attempting date-based search...")
        
        # Calculate date range (last 30 days)
        end_date = datetime.now()
        start_date = end_date - timedelta(days=30)
        
        print(f"Searching for reports from {start_date.strftime('%Y-%m-%d')} to {end_date.strftime('%Y-%m-%d')}")
        
        # This would be implemented based on the forms we discover above
        print("(Search implementation will depend on forms found above)")
        
        return {
            "login_successful": True,
            "navigation_links": nav_links,
            "authenticated_urls": test_urls
        }

if __name__ == "__main__":
    result = asyncio.run(explore_mufon_cms())
    if result:
        print(f"\n✅ Exploration complete. Found {len(result['navigation_links'])} navigation options.")
    else:
        print("\n❌ Exploration failed.")