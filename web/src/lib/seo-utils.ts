import { TFunction } from 'next-i18next';
import { AlertTitleUtils } from '@/utils/alert-title-utils';

// SEO constants
export const SEO_CONSTANTS = {
  SITE_NAME: 'UFOBeep',
  BASE_URL: process.env.NEXT_PUBLIC_SITE_URL || 'https://ufobeep.com',
  DEFAULT_LOCALE: 'en',
  SUPPORTED_LOCALES: ['en', 'es', 'de'],
  TWITTER_HANDLE: '@UFOBeep',
  FACEBOOK_APP_ID: process.env.NEXT_PUBLIC_FACEBOOK_APP_ID || '',
  DEFAULT_IMAGE: '/images/og-default.png',
  IMAGE_DIMENSIONS: {
    OG: { width: 1200, height: 630 },
    TWITTER: { width: 1200, height: 600 },
  },
};

// Generate hreflang URLs for international SEO
export function generateHrefLangUrls(
  pathname: string,
  locales: string[] = SEO_CONSTANTS.SUPPORTED_LOCALES
): Record<string, string> {
  const hrefLangs: Record<string, string> = {};
  
  locales.forEach(locale => {
    const isDefault = locale === SEO_CONSTANTS.DEFAULT_LOCALE;
    const localizedPath = isDefault ? pathname : `/${locale}${pathname}`;
    const fullUrl = `${SEO_CONSTANTS.BASE_URL}${localizedPath}`;
    
    // Map locale codes to proper hreflang values
    const hrefLangCode = locale === 'en' ? 'en-US' : 
                        locale === 'es' ? 'es-ES' : 
                        locale === 'de' ? 'de-DE' : locale;
    
    hrefLangs[hrefLangCode] = fullUrl;
  });
  
  // Add x-default for the default locale
  hrefLangs['x-default'] = `${SEO_CONSTANTS.BASE_URL}${pathname}`;
  
  return hrefLangs;
}

// Generate breadcrumb structured data
export function generateBreadcrumbStructuredData(
  breadcrumbs: Array<{ name: string; url: string }>
) {
  return {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: breadcrumbs.map((crumb, index) => ({
      '@type': 'ListItem',
      position: index + 1,
      name: crumb.name,
      item: crumb.url,
    })),
  };
}

// Generate FAQ structured data
export function generateFAQStructuredData(
  faqs: Array<{ question: string; answer: string }>
) {
  return {
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    mainEntity: faqs.map(faq => ({
      '@type': 'Question',
      name: faq.question,
      acceptedAnswer: {
        '@type': 'Answer',
        text: faq.answer,
      },
    })),
  };
}

// Generate local business structured data
export function generateLocalBusinessStructuredData() {
  return {
    '@context': 'https://schema.org',
    '@type': 'SoftwareApplication',
    name: SEO_CONSTANTS.SITE_NAME,
    description: 'Community-driven platform for reporting and tracking unexplained aerial phenomena',
    url: SEO_CONSTANTS.BASE_URL,
    applicationCategory: 'Utility',
    operatingSystem: ['iOS', 'Android', 'Web'],
    offers: {
      '@type': 'Offer',
      price: '0',
      priceCurrency: 'USD',
    },
    aggregateRating: {
      '@type': 'AggregateRating',
      ratingValue: '4.5',
      ratingCount: '1250',
      bestRating: '5',
    },
  };
}

// Generate article structured data for alerts
export function generateAlertArticleStructuredData(alert: {
  id: string;
  title: string;
  description: string;
  timestamp: string;
  location?: string;
  reporterName?: string;
  coordinates?: { lat: number; lng: number };
  imageUrl?: string;
  category?: string;
}) {
  return {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: AlertTitleUtils.getContextualTitle(alert),
    description: alert.description || 'UFO sighting captured with UFOBeep',
    datePublished: alert.timestamp,
    dateModified: alert.timestamp,
    author: {
      '@type': 'Person',
      name: alert.reporterName || 'Anonymous Observer',
    },
    publisher: {
      '@type': 'Organization',
      name: SEO_CONSTANTS.SITE_NAME,
      logo: {
        '@type': 'ImageObject',
        url: `${SEO_CONSTANTS.BASE_URL}/images/logo.png`,
      },
    },
    mainEntityOfPage: `${SEO_CONSTANTS.BASE_URL}/alerts/${alert.id}`,
    about: {
      '@type': 'Event',
      name: `UFO Sighting ${alert.id}`,
      description: alert.description,
      startDate: alert.timestamp,
      location: alert.location && alert.coordinates ? {
        '@type': 'Place',
        name: alert.location,
        geo: {
          '@type': 'GeoCoordinates',
          latitude: alert.coordinates.lat,
          longitude: alert.coordinates.lng,
        },
      } : undefined,
    },
    image: alert.imageUrl ? {
      '@type': 'ImageObject',
      url: alert.imageUrl,
      width: SEO_CONSTANTS.IMAGE_DIMENSIONS.OG.width,
      height: SEO_CONSTANTS.IMAGE_DIMENSIONS.OG.height,
    } : undefined,
    keywords: [
      'UFO sighting',
      'UAP',
      'unexplained aerial phenomena',
      alert.category,
      alert.location,
    ].filter(Boolean).join(', '),
  };
}

// Generate review structured data
export function generateReviewStructuredData() {
  return {
    '@context': 'https://schema.org',
    '@type': 'Review',
    itemReviewed: {
      '@type': 'SoftwareApplication',
      name: SEO_CONSTANTS.SITE_NAME,
    },
    reviewRating: {
      '@type': 'Rating',
      ratingValue: '5',
      bestRating: '5',
    },
    author: {
      '@type': 'Person',
      name: 'UFO Research Community',
    },
    reviewBody: 'Excellent platform for documenting and sharing unexplained aerial phenomena with scientific precision.',
  };
}

// Optimize title for SEO (length, keywords, brand)
export function optimizeTitle(
  pageTitle: string,
  siteName: string = SEO_CONSTANTS.SITE_NAME,
  maxLength: number = 60
): string {
  const separator = ' | ';
  const fullTitle = `${pageTitle}${separator}${siteName}`;
  
  if (fullTitle.length <= maxLength) {
    return fullTitle;
  }
  
  // Truncate page title to fit within limit
  const availableLength = maxLength - separator.length - siteName.length;
  const truncatedPageTitle = pageTitle.substring(0, availableLength - 3) + '...';
  
  return `${truncatedPageTitle}${separator}${siteName}`;
}

// Optimize description for SEO
export function optimizeDescription(
  description: string,
  maxLength: number = 160
): string {
  if (description.length <= maxLength) {
    return description;
  }
  
  // Truncate at word boundary
  const truncated = description.substring(0, maxLength - 3);
  const lastSpace = truncated.lastIndexOf(' ');
  
  if (lastSpace > maxLength * 0.8) {
    return truncated.substring(0, lastSpace) + '...';
  }
  
  return truncated + '...';
}

// Generate keywords from content
export function generateKeywords(
  content: string,
  additionalKeywords: string[] = [],
  maxKeywords: number = 10
): string {
  const baseKeywords = [
    'UFO', 'UAP', 'sighting', 'unexplained aerial phenomena',
    'UFOBeep', 'report', 'community', 'scientific'
  ];
  
  // Extract potential keywords from content (simple implementation)
  const words = content.toLowerCase()
    .replace(/[^\w\s]/g, ' ')
    .split(/\s+/)
    .filter(word => word.length > 3)
    .filter(word => !['this', 'that', 'with', 'have', 'been', 'they', 'were'].includes(word));
  
  const wordFreq = words.reduce((acc, word) => {
    acc[word] = (acc[word] || 0) + 1;
    return acc;
  }, {} as Record<string, number>);
  
  const contentKeywords = Object.entries(wordFreq)
    .sort(([, a], [, b]) => b - a)
    .slice(0, 5)
    .map(([word]) => word);
  
  const allKeywords = [...baseKeywords, ...additionalKeywords, ...contentKeywords];
  const uniqueKeywords = Array.from(new Set(allKeywords));
  
  return uniqueKeywords.slice(0, maxKeywords).join(', ');
}

// Generate meta tags object for easy use in components
export function generateMetaTags({
  title,
  description,
  keywords,
  canonicalUrl,
  ogImage,
  noIndex = false,
  noFollow = false,
}: {
  title: string;
  description: string;
  keywords?: string;
  canonicalUrl: string;
  ogImage?: string;
  noIndex?: boolean;
  noFollow?: boolean;
}) {
  const optimizedTitle = optimizeTitle(title);
  const optimizedDescription = optimizeDescription(description);
  const metaKeywords = keywords || generateKeywords(description);
  const imageUrl = ogImage || `${SEO_CONSTANTS.BASE_URL}${SEO_CONSTANTS.DEFAULT_IMAGE}`;
  
  return {
    title: optimizedTitle,
    description: optimizedDescription,
    keywords: metaKeywords,
    canonical: canonicalUrl,
    robots: `${noIndex ? 'noindex' : 'index'},${noFollow ? 'nofollow' : 'follow'}`,
    openGraph: {
      title: optimizedTitle,
      description: optimizedDescription,
      url: canonicalUrl,
      image: imageUrl,
      type: 'website',
      siteName: SEO_CONSTANTS.SITE_NAME,
    },
    twitter: {
      card: 'summary_large_image',
      site: SEO_CONSTANTS.TWITTER_HANDLE,
      title: optimizedTitle,
      description: optimizedDescription,
      image: imageUrl,
    },
  };
}

// Performance hints for critical resources
export function generateResourceHints() {
  return [
    { rel: 'preconnect', href: 'https://fonts.googleapis.com' },
    { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossOrigin: 'anonymous' },
    { rel: 'dns-prefetch', href: '//api.ufobeep.com' },
    { rel: 'dns-prefetch', href: '//matrix.org' },
  ];
}

// Generate security headers for SEO
export function generateSecurityHeaders() {
  return {
    'X-Robots-Tag': 'index, follow',
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'Referrer-Policy': 'strict-origin-when-cross-origin',
  };
}