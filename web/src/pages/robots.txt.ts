import { GetServerSideProps } from 'next';

function generateRobotsTxt(baseUrl: string, isProduction: boolean): string {
  const sitemapUrl = `${baseUrl}/sitemap.xml`;
  
  if (isProduction) {
    return `# UFOBeep Production Robots.txt
# Allow all crawlers to access the site

User-agent: *
Allow: /

# Specific rules for major search engines
User-agent: Googlebot
Allow: /
Crawl-delay: 1

User-agent: Bingbot
Allow: /
Crawl-delay: 1

User-agent: Slurp
Allow: /
Crawl-delay: 2

User-agent: DuckDuckBot
Allow: /
Crawl-delay: 1

# Disallow admin and private areas (if they exist)
User-agent: *
Disallow: /admin/
Disallow: /api/
Disallow: /_next/
Disallow: /.*

# Allow specific API endpoints that should be crawled
User-agent: *
Allow: /api/sitemap
Allow: /api/health

# Crawl delay for all bots
Crawl-delay: 1

# Sitemap location
Sitemap: ${sitemapUrl}

# Additional sitemaps (if needed)
# Sitemap: ${baseUrl}/alerts-sitemap.xml
# Sitemap: ${baseUrl}/news-sitemap.xml`;
  } else {
    // Development/staging environment
    return `# UFOBeep Development/Staging Robots.txt
# Disallow all crawlers in non-production environments

User-agent: *
Disallow: /

# Allow specific development tools
User-agent: lighthouse
Allow: /

User-agent: PageSpeed Insights
Allow: /

# Sitemap still available for testing
Sitemap: ${sitemapUrl}`;
  }
}

function RobotsTxt() {
  // getServerSideProps will do the heavy lifting
}

export const getServerSideProps: GetServerSideProps = async ({ res, req }) => {
  // Determine base URL
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || 
                  `${req.headers['x-forwarded-proto'] || 'http'}://${req.headers.host}`;
  
  // Check if this is production
  const isProduction = process.env.NODE_ENV === 'production' || 
                      process.env.ENVIRONMENT === 'production' ||
                      baseUrl.includes('ufobeep.com');
  
  const robotsTxt = generateRobotsTxt(baseUrl, isProduction);
  
  res.setHeader('Content-Type', 'text/plain');
  res.setHeader('Cache-Control', 'public, s-maxage=86400, stale-while-revalidate=604800');
  res.write(robotsTxt);
  res.end();
  
  return {
    props: {},
  };
};

export default RobotsTxt;