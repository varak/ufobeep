import { Metadata } from 'next';
import { TFunction } from 'next-i18next';

interface LocalizedMetadataProps {
  page: string;
  t: TFunction;
  locale: string;
  params?: Record<string, string>;
  images?: Array<{
    url: string;
    width: number;
    height: number;
    alt: string;
  }>;
}

interface OpenGraphImage {
  url: string;
  width: number;
  height: number;
  alt: string;
  type?: string;
}

export function generateLocalizedMetadata({
  page,
  t,
  locale,
  params = {},
  images,
}: LocalizedMetadataProps): Metadata {
  const siteName = t('meta:site.name');
  const siteDescription = t('meta:site.description');
  const author = t('meta:site.author');
  
  // Get page-specific metadata
  const title = t(`meta:pages.${page}.title`, params);
  const description = t(`meta:pages.${page}.description`, params);
  const keywords = t(`meta:pages.${page}.keywords`, params);
  
  // Generate canonical URL
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || 'https://ufobeep.com';
  const localizedPath = locale === 'en' ? '' : `/${locale}`;
  const pagePath = page === 'home' ? '' : `/${page === 'alertDetail' ? 'alerts' : page}`;
  const canonicalUrl = `${baseUrl}${localizedPath}${pagePath}`;
  
  // Generate OpenGraph images
  const ogImages: OpenGraphImage[] = [];
  
  if (images) {
    ogImages.push(...images);
  } else {
    // Use default page-specific or fallback image
    const defaultImage = t(`meta:openGraph.images.${page}`, { returnObjects: true, defaultValue: null });
    if (defaultImage && typeof defaultImage === 'object' && 'url' in defaultImage) {
      ogImages.push({
        url: `${baseUrl}${defaultImage.url}`,
        width: defaultImage.width,
        height: defaultImage.height,
        alt: defaultImage.alt,
      });
    } else {
      const fallbackImage = t('meta:openGraph.images.default', { returnObjects: true });
      if (fallbackImage && typeof fallbackImage === 'object' && 'url' in fallbackImage) {
        ogImages.push({
          url: `${baseUrl}${fallbackImage.url}`,
          width: fallbackImage.width,
          height: fallbackImage.height,
          alt: fallbackImage.alt,
        });
      }
    }
  }
  
  // Generate alternates for other languages
  const alternates: Record<string, string> = {};
  const supportedLocales = ['en', 'es', 'de'];
  
  supportedLocales.forEach((supportedLocale) => {
    const altLocalizedPath = supportedLocale === 'en' ? '' : `/${supportedLocale}`;
    alternates[supportedLocale] = `${baseUrl}${altLocalizedPath}${pagePath}`;
  });
  
  return {
    title,
    description,
    keywords,
    authors: [{ name: author }],
    creator: author,
    publisher: siteName,
    
    // OpenGraph
    openGraph: {
      type: 'website',
      siteName,
      title,
      description,
      url: canonicalUrl,
      locale: getOpenGraphLocale(locale),
      alternateLocale: supportedLocales
        .filter((l) => l !== locale)
        .map(getOpenGraphLocale),
      images: ogImages,
    },
    
    // Twitter
    twitter: {
      card: 'summary_large_image',
      site: t('meta:twitter.site'),
      creator: t('meta:twitter.creator'),
      title,
      description,
      images: ogImages.map((img) => img.url),
    },
    
    // Canonical URL
    alternates: {
      canonical: canonicalUrl,
      languages: alternates,
    },
    
    // Robots
    robots: {
      index: true,
      follow: true,
      googleBot: {
        index: true,
        follow: true,
        'max-video-preview': -1,
        'max-image-preview': 'large',
        'max-snippet': -1,
      },
    },
    
    // Additional metadata
    category: 'Science & Technology',
    classification: 'Community Platform',
    referrer: 'strict-origin-when-cross-origin',
    
    // Icons and manifest
    manifest: '/manifest.json',
    icons: {
      icon: [
        { url: '/favicon-16x16.png', sizes: '16x16', type: 'image/png' },
        { url: '/favicon-32x32.png', sizes: '32x32', type: 'image/png' },
      ],
      apple: [
        { url: '/apple-touch-icon.png', sizes: '180x180', type: 'image/png' },
      ],
      other: [
        { url: '/android-chrome-192x192.png', sizes: '192x192', type: 'image/png' },
        { url: '/android-chrome-512x512.png', sizes: '512x512', type: 'image/png' },
      ],
    },
    
    // Verification (placeholder for future use)
    verification: {
      // google: 'your-google-verification-code',
      // yandex: 'your-yandex-verification-code',
      // yahoo: 'your-yahoo-verification-code',
    },
  };
}

function getOpenGraphLocale(locale: string): string {
  const localeMap: Record<string, string> = {
    en: 'en_US',
    es: 'es_ES',
    de: 'de_DE',
  };
  return localeMap[locale] || 'en_US';
}

// Generate structured data (JSON-LD) for better SEO
export function generateStructuredData({
  page,
  t,
  locale,
  params = {},
  additionalData = {},
}: {
  page: string;
  t: TFunction;
  locale: string;
  params?: Record<string, string>;
  additionalData?: Record<string, any>;
}) {
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || 'https://ufobeep.com';
  const siteName = t('meta:site.name');
  const siteDescription = t('meta:site.description');
  
  // Base organization data
  const organization = {
    '@type': 'Organization',
    name: siteName,
    description: siteDescription,
    url: baseUrl,
    logo: `${baseUrl}/images/logo.png`,
    sameAs: [
      'https://twitter.com/UFOBeep',
      'https://github.com/UFOBeep',
    ],
  };
  
  // Base website data
  const website = {
    '@type': 'WebSite',
    name: siteName,
    description: siteDescription,
    url: baseUrl,
    publisher: organization,
    potentialAction: {
      '@type': 'SearchAction',
      target: `${baseUrl}/alerts?q={search_term_string}`,
      'query-input': 'required name=search_term_string',
    },
  };
  
  // Page-specific structured data
  const pageTitle = t(`meta:pages.${page}.title`, params);
  const pageDescription = t(`meta:pages.${page}.description`, params);
  const localizedPath = locale === 'en' ? '' : `/${locale}`;
  const pagePath = page === 'home' ? '' : `/${page === 'alertDetail' ? 'alerts' : page}`;
  const pageUrl = `${baseUrl}${localizedPath}${pagePath}`;
  
  let pageSpecificData: any = {
    '@type': 'WebPage',
    name: pageTitle,
    description: pageDescription,
    url: pageUrl,
    isPartOf: website,
    inLanguage: locale,
  };
  
  // Add page-specific structured data
  switch (page) {
    case 'home':
      pageSpecificData = {
        ...pageSpecificData,
        '@type': 'WebPage',
        mainEntity: {
          '@type': 'SoftwareApplication',
          name: siteName,
          description: siteDescription,
          applicationCategory: 'Utility',
          operatingSystem: ['iOS', 'Android'],
          offers: {
            '@type': 'Offer',
            price: '0',
            priceCurrency: 'USD',
          },
        },
      };
      break;
      
    case 'alerts':
      pageSpecificData = {
        ...pageSpecificData,
        '@type': 'CollectionPage',
        mainEntity: {
          '@type': 'ItemList',
          name: t(`meta:pages.${page}.title`),
          description: t(`meta:pages.${page}.description`),
        },
      };
      break;
      
    case 'alertDetail':
      if (additionalData.alert) {
        pageSpecificData = {
          ...pageSpecificData,
          '@type': 'Article',
          headline: additionalData.alert.title,
          description: additionalData.alert.description,
          datePublished: additionalData.alert.createdAt,
          author: {
            '@type': 'Person',
            name: additionalData.alert.reporterName || 'Anonymous Observer',
          },
          publisher: organization,
          mainEntityOfPage: pageUrl,
        };
      }
      break;
  }
  
  return {
    '@context': 'https://schema.org',
    '@graph': [organization, website, pageSpecificData, ...Object.values(additionalData)],
  };
}

// Hook for easy metadata generation in pages
export function useLocalizedMetadata(
  page: string,
  t: TFunction,
  locale: string,
  options: {
    params?: Record<string, string>;
    images?: Array<{ url: string; width: number; height: number; alt: string }>;
    additionalData?: Record<string, any>;
  } = {}
) {
  const metadata = generateLocalizedMetadata({
    page,
    t,
    locale,
    params: options.params,
    images: options.images,
  });
  
  const structuredData = generateStructuredData({
    page,
    t,
    locale,
    params: options.params,
    additionalData: options.additionalData,
  });
  
  return {
    metadata,
    structuredData,
  };
}