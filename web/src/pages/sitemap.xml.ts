import { GetServerSideProps } from 'next';

interface SitemapUrl {
  loc: string;
  lastmod?: string;
  changefreq?: 'always' | 'hourly' | 'daily' | 'weekly' | 'monthly' | 'yearly' | 'never';
  priority?: number;
  alternates?: Array<{ hreflang: string; href: string }>;
}

function generateSiteMap(urls: SitemapUrl[]): string {
  const xmlHeader = `<?xml version="1.0" encoding="UTF-8"?>`;
  const xsiSchema = `xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml"`;
  
  return `${xmlHeader}
<urlset ${xsiSchema}>
${urls.map(url => {
  const alternates = url.alternates?.map(alt => 
    `    <xhtml:link rel="alternate" hreflang="${alt.hreflang}" href="${alt.href}" />`
  ).join('\n') || '';
  
  return `  <url>
    <loc>${url.loc}</loc>
    ${url.lastmod ? `<lastmod>${url.lastmod}</lastmod>` : ''}
    ${url.changefreq ? `<changefreq>${url.changefreq}</changefreq>` : ''}
    ${url.priority !== undefined ? `<priority>${url.priority}</priority>` : ''}
${alternates}
  </url>`;
}).join('\n')}
</urlset>`;
}

function SiteMap() {
  // getServerSideProps will do the heavy lifting
}

export const getServerSideProps: GetServerSideProps = async ({ res, req }) => {
  // Base URL from environment or request
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || 
                  `${req.headers['x-forwarded-proto'] || 'http'}://${req.headers.host}`;
  
  const supportedLocales = ['en', 'es', 'de'];
  const currentDate = new Date().toISOString();
  
  // Static pages with their priorities and change frequencies
  const staticPages = [
    {
      path: '',
      priority: 1.0,
      changefreq: 'daily' as const,
    },
    {
      path: '/app',
      priority: 0.9,
      changefreq: 'weekly' as const,
    },
    {
      path: '/alerts',
      priority: 0.8,
      changefreq: 'hourly' as const,
    },
    {
      path: '/privacy',
      priority: 0.3,
      changefreq: 'monthly' as const,
    },
    {
      path: '/terms',
      priority: 0.3,
      changefreq: 'monthly' as const,
    },
    {
      path: '/safety',
      priority: 0.4,
      changefreq: 'monthly' as const,
    },
  ];
  
  const sitemapUrls: SitemapUrl[] = [];
  
  // Generate URLs for static pages in all locales
  staticPages.forEach(page => {
    supportedLocales.forEach(locale => {
      const isDefaultLocale = locale === 'en';
      const localePath = isDefaultLocale ? '' : `/${locale}`;
      const fullPath = `${localePath}${page.path}`;
      const url = `${baseUrl}${fullPath}`;
      
      // Generate alternates for other locales
      const alternates = supportedLocales.map(altLocale => {
        const isAltDefault = altLocale === 'en';
        const altLocalePath = isAltDefault ? '' : `/${altLocale}`;
        const altUrl = `${baseUrl}${altLocalePath}${page.path}`;
        
        return {
          hreflang: altLocale === 'en' ? 'en-US' : 
                   altLocale === 'es' ? 'es-ES' : 'de-DE',
          href: altUrl,
        };
      });
      
      // Add x-default for English
      if (locale === 'en') {
        alternates.push({
          hreflang: 'x-default',
          href: `${baseUrl}${page.path}`,
        });
      }
      
      sitemapUrls.push({
        loc: url,
        lastmod: currentDate,
        changefreq: page.changefreq,
        priority: page.priority,
        alternates,
      });
    });
  });
  
  // Generate URLs for dynamic alert pages
  // In a real app, you'd fetch this from your API/database
  const alertIds = Array.from({ length: 100 }, (_, i) => (i + 1).toString());
  
  alertIds.forEach(alertId => {
    supportedLocales.forEach(locale => {
      const isDefaultLocale = locale === 'en';
      const localePath = isDefaultLocale ? '' : `/${locale}`;
      const alertPath = `/alerts/${alertId}`;
      const url = `${baseUrl}${localePath}${alertPath}`;
      
      // Generate alternates for alert pages
      const alternates = supportedLocales.map(altLocale => {
        const isAltDefault = altLocale === 'en';
        const altLocalePath = isAltDefault ? '' : `/${altLocale}`;
        const altUrl = `${baseUrl}${altLocalePath}${alertPath}`;
        
        return {
          hreflang: altLocale === 'en' ? 'en-US' : 
                   altLocale === 'es' ? 'es-ES' : 'de-DE',
          href: altUrl,
        };
      });
      
      if (locale === 'en') {
        alternates.push({
          hreflang: 'x-default',
          href: `${baseUrl}${alertPath}`,
        });
      }
      
      sitemapUrls.push({
        loc: url,
        lastmod: currentDate,
        changefreq: 'daily',
        priority: 0.7,
        alternates,
      });
    });
  });
  
  // Sort URLs by priority (highest first) and then by URL
  sitemapUrls.sort((a, b) => {
    if (a.priority !== b.priority) {
      return (b.priority || 0) - (a.priority || 0);
    }
    return a.loc.localeCompare(b.loc);
  });
  
  const sitemap = generateSiteMap(sitemapUrls);
  
  res.setHeader('Content-Type', 'text/xml');
  res.setHeader('Cache-Control', 'public, s-maxage=3600, stale-while-revalidate=86400');
  res.write(sitemap);
  res.end();
  
  return {
    props: {},
  };
};

export default SiteMap;