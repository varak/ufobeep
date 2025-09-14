const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox','--disable-dev-shm-usage']
  });
  const page = await browser.newPage();

  page.on('console', (msg) => {
    try {
      const args = msg.args();
      const values = [];
      for (const a of args) {
        try {
          values.push(a._remoteObject && a._remoteObject.value !== undefined ? a._remoteObject.value : a.toString());
        } catch {}
      }
      console.log(`[console.${msg.type()}]`, msg.text(), values.length ? `| args: ${values.join(' | ')}` : '');
    } catch (e) {
      console.log('[console]', msg.type(), msg.text());
    }
  });
  page.on('pageerror', (err) => console.log('[pageerror]', err.message));
  page.on('requestfailed', (req) => console.log('[requestfailed]', req.url(), req.failure()?.errorText || 'unknown'));

  page.setDefaultNavigationTimeout(60000);
  page.setDefaultTimeout(60000);

  const url = process.argv[2] || 'https://ufobeep.com/map';
  console.log('[nav] goto', url);
  await page.goto(url, { waitUntil: 'domcontentloaded' });

  // Allow network to settle and scripts to run
  await new Promise(r => setTimeout(r, 10000));

  // Small diagnostic: query for the map container and fallback message
  const result = await page.evaluate(() => {
    const fallback = Array.from(document.querySelectorAll('*')).find(el => el.textContent && el.textContent.includes('Interactive map unavailable'))
    const diag = fallback ? fallback.closest('div')?.innerText || '' : ''
    return {
      title: document.title,
      hasFallback: !!fallback,
      fallbackText: diag.slice(0, 200)
    }
  });

  console.log('[result]', result);

  await browser.close();
})();
