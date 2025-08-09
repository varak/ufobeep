import { env } from '@/config/environment'

export async function GET() {
  const baseUrl = env.siteUrl
  
  const robots = `User-agent: *
Allow: /
Allow: /app
Allow: /privacy
Allow: /terms
Allow: /safety
Allow: /alerts/*

# Disallow sensitive areas (when they exist)
Disallow: /admin/
Disallow: /api/
Disallow: /_next/
Disallow: /404
Disallow: /500

# Allow search engines to crawl images and assets
Allow: /images/
Allow: /icons/
Allow: /*.css$
Allow: /*.js$

# Sitemap location
Sitemap: ${baseUrl}/sitemap.xml

# Crawl delay to be respectful
Crawl-delay: 1

# Specific rules for different bots
User-agent: Googlebot
Allow: /
Crawl-delay: 0

User-agent: Bingbot  
Allow: /
Crawl-delay: 1

User-agent: ia_archiver
Allow: /
Crawl-delay: 2

# Social media bots (for link previews)
User-agent: facebookexternalhit
Allow: /

User-agent: Twitterbot
Allow: /

User-agent: LinkedInBot
Allow: /

# Block AI training bots (optional - can be removed if desired)
User-agent: GPTBot
Disallow: /

User-agent: CCBot
Disallow: /

User-agent: ChatGPT-User
Disallow: /

User-agent: Google-Extended
Disallow: /`

  return new Response(robots, {
    headers: {
      'Content-Type': 'text/plain',
      'Cache-Control': 'public, max-age=86400, s-maxage=86400'
    }
  })
}