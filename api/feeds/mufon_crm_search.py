#!/usr/bin/env python3
"""
MUFON CRM Authenticated Search - Search for recent reports within the authenticated CRM
"""
import asyncio
import httpx
from bs4 import BeautifulSoup
from datetime import datetime, timedelta
import json

async def search_mufon_crm():
    """Login to MUFON CRM and perform a date-based search"""
    
    # Credentials from secrets file
    username = "varak"
    password = "ufobeep123pass"
    
    async with httpx.AsyncClient(follow_redirects=True, timeout=30.0) as client:
        print("Step 1: Logging into MUFON CRM...")
        
        # Get login page
        login_page = await client.get("https://mufon.app.neoncrm.com/np/clients/mufon/login.jsp")
        soup = BeautifulSoup(login_page.text, 'html.parser')
        
        # Find the correct login form (signIn.do)
        login_form = None
        for form in soup.find_all('form'):
            if form.get('action') and 'signIn.do' in form.get('action'):
                login_form = form
                break
        
        if not login_form:
            print("❌ Login form not found")
            return None
        
        # Extract form data
        form_data = {}
        for inp in login_form.find_all('input'):
            name = inp.get('name')
            value = inp.get('value', '')
            inp_type = inp.get('type', 'text')
            
            if name:
                if name == 'loginName':
                    form_data[name] = username
                elif name == 'loginPassword':
                    form_data[name] = password
                else:
                    form_data[name] = value
        
        # Perform login
        login_url = "https://mufon.app.neoncrm.com/np/security/signIn.do"
        login_response = await client.post(login_url, data=form_data)
        
        if "accountHome.do" not in str(login_response.url):
            print("❌ Login failed")
            return None
        
        print("✅ Successfully logged into MUFON CRM")
        
        print("\nStep 2: Looking for search functionality...")
        
        # Try accessing the database search page directly
        search_page_url = "https://mufon.app.neoncrm.com/np/clients/mufon/neonPage.jsp?pageId=19"
        
        search_response = await client.get(search_page_url)
        search_soup = BeautifulSoup(search_response.text, 'html.parser')
        
        print(f"Search page title: {search_soup.title.get_text() if search_soup.title else 'No title'}")
        
        # Look for search forms
        forms = search_soup.find_all('form')
        print(f"Found {len(forms)} forms on search page")
        
        search_form = None
        for i, form in enumerate(forms):
            action = form.get('action', 'No action')
            method = form.get('method', 'GET')
            inputs = form.find_all(['input', 'select', 'textarea'])
            
            print(f"\nForm {i+1}: {action} ({method})")
            print(f"  Fields: {len(inputs)}")
            
            # Look for date/search related fields
            date_fields = []
            search_fields = []
            
            for inp in inputs:
                inp_type = inp.get('type', inp.name)
                inp_name = inp.get('name', 'unnamed')
                inp_id = inp.get('id', '')
                inp_value = inp.get('value', '')
                
                print(f"    - {inp_type}: {inp_name} (id: {inp_id}) = '{inp_value}'")
                
                # Check for date fields
                if any(keyword in inp_name.lower() for keyword in ['date', 'from', 'to', 'start', 'end']):
                    date_fields.append((inp_name, inp_type))
                
                # Check for search/query fields  
                if any(keyword in inp_name.lower() for keyword in ['search', 'query', 'case', 'report']):
                    search_fields.append((inp_name, inp_type))
            
            if date_fields or search_fields:
                print(f"  -> Promising form with date fields: {date_fields}, search fields: {search_fields}")
                search_form = form
        
        if not search_form:
            print("❌ No suitable search form found")
            
            # Try to find any links that might lead to search functionality
            print("\nLooking for search-related links...")
            for link in search_soup.find_all('a', href=True):
                href = link.get('href')
                text = link.get_text(strip=True)
                if text and any(keyword in text.lower() for keyword in ['search', 'database', 'report', 'case']):
                    print(f"  - {text}: {href}")
            
            return None
        
        print("\nStep 3: Attempting search with date range...")
        
        # Calculate date range (last 30 days)
        end_date = datetime.now()
        start_date = end_date - timedelta(days=30)
        
        # Prepare search form data
        search_data = {}
        for inp in search_form.find_all('input'):
            name = inp.get('name')
            value = inp.get('value', '')
            inp_type = inp.get('type', 'text')
            
            if name:
                if inp_type == 'submit':
                    continue  # Don't include submit buttons in data
                elif 'date' in name.lower() and 'start' in name.lower():
                    search_data[name] = start_date.strftime('%m/%d/%Y')
                elif 'date' in name.lower() and 'end' in name.lower():
                    search_data[name] = end_date.strftime('%m/%d/%Y')
                elif 'from' in name.lower():
                    search_data[name] = start_date.strftime('%m/%d/%Y')
                elif 'to' in name.lower():
                    search_data[name] = end_date.strftime('%m/%d/%Y')
                else:
                    search_data[name] = value
        
        print(f"Search data: {search_data}")
        
        # Perform search
        search_action = search_form.get('action')
        if search_action and not search_action.startswith('http'):
            if search_action.startswith('/'):
                search_action = f"https://mufon.app.neoncrm.com{search_action}"
            else:
                search_action = f"https://mufon.app.neoncrm.com/np/clients/mufon/{search_action}"
        
        search_method = search_form.get('method', 'POST').upper()
        
        print(f"Submitting search to: {search_action} ({search_method})")
        
        results_response = await client.request(search_method, search_action, data=search_data)
        results_soup = BeautifulSoup(results_response.text, 'html.parser')
        
        print(f"\nStep 4: Analyzing search results...")
        print(f"Results page title: {results_soup.title.get_text() if results_soup.title else 'No title'}")
        
        # Look for data tables
        tables = results_soup.find_all('table')
        print(f"Found {len(tables)} tables in results")
        
        for i, table in enumerate(tables):
            rows = table.find_all('tr')
            if len(rows) > 1:  # Has header + data
                headers = [th.get_text(strip=True) for th in rows[0].find_all(['th', 'td'])]
                print(f"\nTable {i+1} ({len(rows)-1} data rows):")
                print(f"  Headers: {headers}")
                
                # Show first few data rows
                for j, row in enumerate(rows[1:6]):  # Show first 5 data rows
                    cells = [td.get_text(strip=True) for td in row.find_all(['td', 'th'])]
                    print(f"  Row {j+1}: {cells}")
                
                if len(rows) > 6:
                    print(f"  ... and {len(rows)-6} more rows")
        
        # Look for any JSON data or additional info
        scripts = results_soup.find_all('script')
        for script in scripts:
            if script.string and ('case' in script.string.lower() or 'report' in script.string.lower()):
                print(f"\nFound relevant script data: {script.string[:200]}...")
        
        return {
            "authenticated": True,
            "search_performed": True,
            "tables_found": len(tables),
            "results_url": str(results_response.url)
        }

if __name__ == "__main__":
    result = asyncio.run(search_mufon_crm())
    if result:
        print(f"\n✅ Search complete. Found {result['tables_found']} data tables.")
    else:
        print("\n❌ Search failed.")