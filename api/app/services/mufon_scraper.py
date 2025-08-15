"""
MUFON automated scraper service with intelligent deduplication
"""
import hashlib
import asyncio
import asyncpg
from datetime import datetime, timedelta
from typing import List, Dict, Any, Optional
import json
import re
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
import logging

logger = logging.getLogger(__name__)

class MufonScraper:
    """Automated MUFON data scraper with deduplication"""
    
    def __init__(self, username: str, password: str):
        self.username = username
        self.password = password
        self.base_url = "https://mufon.app.neoncrm.com/np/clients/mufon/neonPage.jsp?pageId=19"
        
    def generate_sighting_hash(self, sighting: Dict[str, Any]) -> str:
        """Generate unique hash for sighting to prevent duplicates"""
        # Create hash from key identifying fields
        hash_data = {
            'date_event': sighting.get('date_event', ''),
            'location': sighting.get('location', ''),
            'short_description': sighting.get('short_description', '')[:100],  # First 100 chars
        }
        
        # Create stable hash
        hash_str = json.dumps(hash_data, sort_keys=True)
        return hashlib.sha256(hash_str.encode()).hexdigest()
    
    async def check_duplicate(self, conn: asyncpg.Connection, sighting_hash: str) -> bool:
        """Check if sighting already exists in database"""
        exists = await conn.fetchval("""
            SELECT EXISTS(
                SELECT 1 FROM mufon_sightings 
                WHERE sighting_hash = $1
            )
        """, sighting_hash)
        return exists
    
    def setup_driver(self) -> webdriver.Chrome:
        """Setup headless Chrome driver"""
        chrome_options = Options()
        chrome_options.add_argument("--headless")
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--disable-dev-shm-usage")
        chrome_options.add_argument("--disable-gpu")
        chrome_options.add_argument("--window-size=1920,1080")
        
        # Use webdriver-manager to automatically download and manage Chrome driver
        service = Service(ChromeDriverManager().install())
        driver = webdriver.Chrome(service=service, options=chrome_options)
        return driver
    
    def scrape_recent_sightings(self, days_back: int = 2) -> List[Dict[str, Any]]:
        """Scrape recent sightings from MUFON"""
        driver = None
        sightings = []
        
        try:
            driver = self.setup_driver()
            
            # Navigate to MUFON search page
            logger.info(f"Navigating to MUFON search page...")
            driver.get(self.base_url)
            
            # Wait for login form
            wait = WebDriverWait(driver, 10)
            
            # Login
            username_field = wait.until(EC.presence_of_element_located((By.NAME, "username")))
            password_field = driver.find_element(By.NAME, "password")
            
            username_field.send_keys(self.username)
            password_field.send_keys(self.password)
            
            # Submit login
            login_button = driver.find_element(By.XPATH, "//input[@type='submit']")
            login_button.click()
            
            # Wait for search form to load
            wait.until(EC.presence_of_element_located((By.NAME, "dateSubmitted")))
            
            # Set date range for recent sightings
            date_from = (datetime.now() - timedelta(days=days_back)).strftime("%m/%d/%Y")
            date_to = datetime.now().strftime("%m/%d/%Y")
            
            date_field = driver.find_element(By.NAME, "dateSubmitted")
            date_field.clear()
            date_field.send_keys(f"{date_from} - {date_to}")
            
            # Submit search
            search_button = driver.find_element(By.XPATH, "//input[@value='Search']")
            search_button.click()
            
            # Wait for results
            wait.until(EC.presence_of_element_located((By.CLASS_NAME, "results-table")))
            
            # Parse results table
            table = driver.find_element(By.CLASS_NAME, "results-table")
            rows = table.find_elements(By.TAG_NAME, "tr")[1:]  # Skip header
            
            for row in rows:
                cells = row.find_elements(By.TAG_NAME, "td")
                if len(cells) >= 6:
                    sighting = {
                        'date_submitted': cells[0].text.strip(),
                        'date_event': self._parse_event_datetime(cells[1].text.strip()),
                        'short_description': cells[2].text.strip(),
                        'location': cells[3].text.strip(),
                        'long_description': cells[4].text.strip() if len(cells) > 4 else '',
                        'attachments': self._parse_attachments(cells[5].text.strip() if len(cells) > 5 else ''),
                        'mufon_case_id': self._extract_case_id(row)
                    }
                    sightings.append(sighting)
            
            logger.info(f"Scraped {len(sightings)} sightings from MUFON")
            
        except Exception as e:
            logger.error(f"Error scraping MUFON: {e}")
        finally:
            if driver:
                driver.quit()
        
        return sightings
    
    def _parse_event_datetime(self, datetime_str: str) -> Dict[str, str]:
        """Parse MUFON datetime format"""
        parts = datetime_str.strip().split('\n')
        date = parts[0] if parts else ''
        time = parts[1] if len(parts) > 1 else None
        
        return {
            'date': date,
            'time': time
        }
    
    def _parse_attachments(self, attachments_str: str) -> List[str]:
        """Parse attachment filenames"""
        if not attachments_str:
            return []
        
        # Split by newlines and filter valid filenames
        files = []
        for line in attachments_str.split('\n'):
            line = line.strip()
            if re.match(r'.*\.(mp4|mov|jpg|jpeg|png|gif|avi|wmv|pdf)$', line, re.IGNORECASE):
                files.append(line)
        
        return files
    
    def _extract_case_id(self, row_element) -> Optional[str]:
        """Try to extract MUFON case ID from row"""
        try:
            # Look for case ID in row attributes or links
            case_link = row_element.find_element(By.XPATH, ".//a[contains(@href, 'caseId=')]")
            href = case_link.get_attribute('href')
            match = re.search(r'caseId=(\d+)', href)
            if match:
                return match.group(1)
        except:
            pass
        return None

class MufonImportService:
    """Service to import and manage MUFON data"""
    
    def __init__(self, db_pool: asyncpg.Pool):
        self.db_pool = db_pool
        
    async def import_sightings(self, sightings: List[Dict[str, Any]], source: str = "auto_scrape") -> Dict[str, Any]:
        """Import sightings with deduplication"""
        imported = 0
        skipped = 0
        updated = 0
        errors = []
        
        async with self.db_pool.acquire() as conn:
            # Ensure table has hash column
            await conn.execute("""
                ALTER TABLE mufon_sightings 
                ADD COLUMN IF NOT EXISTS sighting_hash VARCHAR(64) UNIQUE,
                ADD COLUMN IF NOT EXISTS last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                ADD COLUMN IF NOT EXISTS update_count INTEGER DEFAULT 0,
                ADD COLUMN IF NOT EXISTS source_type VARCHAR(50) DEFAULT 'mufon'
            """)
            
            for sighting in sightings:
                try:
                    # Generate hash
                    scraper = MufonScraper("", "")  # Just for hash generation
                    sighting_hash = scraper.generate_sighting_hash(sighting)
                    
                    # Check if exists
                    existing = await conn.fetchrow("""
                        SELECT id, attachments, update_count 
                        FROM mufon_sightings 
                        WHERE sighting_hash = $1
                    """, sighting_hash)
                    
                    if existing:
                        # Check if we have new attachments to add
                        existing_attachments = set(json.loads(existing['attachments']) if existing['attachments'] else [])
                        new_attachments = set(sighting.get('attachments', []))
                        
                        if new_attachments - existing_attachments:
                            # Update with new attachments
                            all_attachments = list(existing_attachments | new_attachments)
                            await conn.execute("""
                                UPDATE mufon_sightings 
                                SET attachments = $1,
                                    last_updated = NOW(),
                                    update_count = update_count + 1
                                WHERE id = $2
                            """, json.dumps(all_attachments), existing['id'])
                            updated += 1
                            logger.info(f"Updated sighting {existing['id']} with new attachments")
                        else:
                            skipped += 1
                    else:
                        # Insert new sighting
                        event_data = sighting.get('date_event', {})
                        event_date = event_data.get('date') if isinstance(event_data, dict) else sighting.get('date_event')
                        event_time = event_data.get('time') if isinstance(event_data, dict) else None
                        
                        await conn.execute("""
                            INSERT INTO mufon_sightings (
                                sighting_hash,
                                mufon_case_id,
                                date_submitted,
                                date_event,
                                time_event,
                                short_description,
                                location_raw,
                                long_description,
                                attachments,
                                import_source,
                                source_type
                            ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
                        """,
                            sighting_hash,
                            sighting.get('mufon_case_id'),
                            datetime.strptime(sighting['date_submitted'], "%Y-%m-%d"),
                            datetime.strptime(event_date, "%Y-%m-%d") if event_date else None,
                            event_time,
                            sighting.get('short_description', ''),
                            sighting.get('location', ''),
                            sighting.get('long_description', ''),
                            json.dumps(sighting.get('attachments', [])),
                            source,
                            'mufon'
                        )
                        imported += 1
                        
                except Exception as e:
                    error_msg = f"Error importing sighting: {str(e)}"
                    errors.append(error_msg)
                    logger.error(error_msg)
        
        return {
            'imported': imported,
            'skipped': skipped,
            'updated': updated,
            'errors': errors,
            'total_processed': len(sightings)
        }

async def run_nightly_import():
    """Nightly cron job to import MUFON sightings"""
    logger.info("Starting nightly MUFON import...")
    
    # Database connection
    db_pool = await asyncpg.create_pool(
        host="localhost",
        port=5432,
        user="ufobeep_user",
        password="ufopostpass",
        database="ufobeep_db",
        min_size=1,
        max_size=5
    )
    
    try:
        # Initialize scraper with credentials from environment
        scraper = MufonScraper(
            username="varak",  # Should come from environment variable
            password="ufo4me123"  # Should come from environment variable
        )
        
        # Scrape recent sightings (last 3 days to catch any delays)
        sightings = scraper.scrape_recent_sightings(days_back=3)
        
        if sightings:
            # Import with deduplication
            import_service = MufonImportService(db_pool)
            result = await import_service.import_sightings(sightings, source="nightly_cron")
            
            logger.info(f"Import complete: {result}")
            
            # Log to database for monitoring
            async with db_pool.acquire() as conn:
                await conn.execute("""
                    INSERT INTO import_logs (
                        source,
                        imported_count,
                        skipped_count,
                        updated_count,
                        error_count,
                        run_date
                    ) VALUES ($1, $2, $3, $4, $5, $6)
                """, 'mufon_nightly', result['imported'], result['skipped'], 
                    result['updated'], len(result['errors']), datetime.now())
        
    except Exception as e:
        logger.error(f"Nightly import failed: {e}")
    finally:
        await db_pool.close()

if __name__ == "__main__":
    # Run the nightly import
    asyncio.run(run_nightly_import())