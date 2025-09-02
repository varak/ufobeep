"""
Simple MUFON Search - Direct parameter approach
Get form once, use parameters directly
"""
import httpx
from bs4 import BeautifulSoup
from typing import List, Dict, Any
from datetime import datetime, timedelta

async def simple_mufon_search(limit: int = 20, days_back: int = 2) -> List[Dict[str, Any]]:
    """Simple direct search approach"""
    username = "varak"
    password = "ufobeep123pass"
    
    async with httpx.AsyncClient(follow_redirects=True, timeout=30.0) as client:
        # Step 1: Login
        print("Logging in to MUFON...")
        login_page = await client.get("https://mufon.app.neoncrm.com/np/clients/mufon/login.jsp")
        soup = BeautifulSoup(login_page.text, 'html.parser')
        
        # Find login form
        login_form = soup.find('form', action=lambda x: x and 'signIn.do' in x)
        if not login_form:
            print("❌ Login form not found")
            return []
        
        # Build login data
        form_data = {}
        for inp in login_form.find_all('input'):
            name = inp.get('name')
            value = inp.get('value', '')
            if name:
                if name == 'loginName':
                    form_data[name] = username
                elif name == 'password':
                    form_data[name] = password
                else:
                    form_data[name] = value
        
        # Login
        login_response = await client.post("https://mufon.app.neoncrm.com/np/security/signIn.do", data=form_data)
        
        if "accountHome.do" not in str(login_response.url):
            print("❌ Authentication failed")
            return []
        
        print("✅ Successfully authenticated")
        
        # Step 2: Get search database page to understand parameters
        search_url = "https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19"
        search_page = await client.get(search_url)
        
        if search_page.status_code != 200:
            print(f"❌ Could not access search page: {search_page.status_code}")
            return []
        
        # Parse page once to understand form structure
        soup = BeautifulSoup(search_page.text, 'html.parser')
        print(f"Search page title: {soup.title.get_text() if soup.title else 'No title'}")
        
        # Find the choice form
        choice_form = None
        for form in soup.find_all('form'):
            if form.find('select', attrs={'name': 'choice'}):
                choice_form = form
                break
        
        if not choice_form:
            print("❌ No choice form found")
            return []
        
        # Get choice options
        choice_select = choice_form.find('select', attrs={'name': 'choice'})
        options = choice_select.find_all('option')
        
        print("Available choice options:")
        search_choice = None
        for option in options:
            value = option.get('value', '').strip()
            text = option.get_text().strip()
            print(f"  {text}: '{value}'")
            
            # Look for search option
            if any(keyword in text.lower() for keyword in ['search', 'database', 'report']):
                search_choice = value
                print(f"  -> Will use: '{text}' (value: '{value}')")
        
        if not search_choice and options:
            # Use first option as fallback
            search_choice = options[0].get('value', '').strip()
            print(f"  -> Using fallback: {options[0].get_text()} ('{search_choice}')")
        
        if not search_choice:
            print("❌ No usable choice option found")
            return []
        
        # Step 3: Make direct search request
        end_date = datetime.now()
        start_date = end_date - timedelta(days=days_back)
        
        search_data = {
            'choice': search_choice,
            'from_date': start_date.strftime('%m/%d/%Y'),
            'to_date': end_date.strftime('%m/%d/%Y')
        }
        
        print(f"Making search request with data: {search_data}")
        
        # Try POST to form action
        form_action = choice_form.get('action', '')
        if form_action.startswith('/'):
            form_action = f"https://mufon.z2systems.com{form_action}"
        elif not form_action.startswith('http'):
            form_action = search_url  # Use same URL
        
        results_response = await client.post(form_action, data=search_data)
        print(f"Search results status: {results_response.status_code}")
        
        if results_response.status_code == 200:
            results_soup = BeautifulSoup(results_response.text, 'html.parser')
            print(f"Results page title: {results_soup.title.get_text() if results_soup.title else 'No title'}")
            
            # Look for data table
            tables = results_soup.find_all('table')
            reports = []
            
            for table in tables:
                rows = table.find_all('tr')[1:]  # Skip header
                for row in rows[:limit]:
                    cells = row.find_all(['td', 'th'])
                    if len(cells) >= 3:
                        # Basic case data
                        case_data = {
                            'case_id': cells[0].get_text().strip() if cells[0] else '',
                            'location': cells[1].get_text().strip() if len(cells) > 1 else '',
                            'date': cells[2].get_text().strip() if len(cells) > 2 else '',
                            'summary': cells[3].get_text().strip() if len(cells) > 3 else '',
                        }
                        
                        if case_data['case_id']:
                            reports.append(case_data)
            
            print(f"Found {len(reports)} reports in search results")
            return reports
        
        print("❌ Search request failed")
        return []