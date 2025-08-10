import React from 'react';
import Head from 'next/head';
import { useRouter } from 'next/router';
import { generateHrefLangUrls, generateMetaTags, SEO_CONSTANTS } from '../lib/seo-utils';

interface SEOHeadProps {
  title: string;
  description: string;
  keywords?: string;
  ogImage?: string;
  noIndex?: boolean;
  noFollow?: boolean;
  structuredData?: object | object[];
  customCanonical?: string;
  breadcrumbs?: Array<{ name: string; url: string }>;
}

export function SEOHead({
  title,
  description,
  keywords,
  ogImage,
  noIndex = false,
  noFollow = false,
  structuredData,
  customCanonical,
  breadcrumbs,
}: SEOHeadProps) {
  const router = useRouter();
  const locale = router.locale || 'en';
  
  // Generate canonical URL
  const pathname = router.asPath.split('?')[0]; // Remove query params
  const canonicalUrl = customCanonical || 
    (locale === 'en' 
      ? `${SEO_CONSTANTS.BASE_URL}${pathname}`
      : `${SEO_CONSTANTS.BASE_URL}/${locale}${pathname}`);
  
  // Generate meta tags
  const metaTags = generateMetaTags({
    title,
    description,
    keywords,
    canonicalUrl,
    ogImage,
    noIndex,
    noFollow,
  });
  
  // Generate hreflang URLs
  const hrefLangUrls = generateHrefLangUrls(pathname);
  
  // Generate breadcrumb structured data if provided
  const breadcrumbData = breadcrumbs ? {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: breadcrumbs.map((crumb, index) => ({
      '@type': 'ListItem',
      position: index + 1,
      name: crumb.name,
      item: crumb.url,
    })),
  } : null;
  
  // Combine structured data
  const allStructuredData = [
    structuredData,
    breadcrumbData,
  ].filter(Boolean);

  return (
    <Head>
      {/* Basic meta tags */}
      <title>{metaTags.title}</title>
      <meta name="description" content={metaTags.description} />
      {metaTags.keywords && <meta name="keywords" content={metaTags.keywords} />}
      <meta name="robots" content={metaTags.robots} />
      
      {/* Canonical URL */}
      <link rel="canonical" href={canonicalUrl} />
      
      {/* Language alternates */}
      {Object.entries(hrefLangUrls).map(([lang, url]) => (
        <link
          key={lang}
          rel="alternate"
          hrefLang={lang}
          href={url}
        />
      ))}
      
      {/* OpenGraph tags */}
      <meta property="og:title" content={metaTags.openGraph.title} />
      <meta property="og:description" content={metaTags.openGraph.description} />
      <meta property="og:type" content={metaTags.openGraph.type} />
      <meta property="og:url" content={metaTags.openGraph.url} />
      <meta property="og:site_name" content={metaTags.openGraph.siteName} />
      <meta property="og:image" content={metaTags.openGraph.image} />
      <meta property="og:image:width" content={SEO_CONSTANTS.IMAGE_DIMENSIONS.OG.width.toString()} />
      <meta property="og:image:height" content={SEO_CONSTANTS.IMAGE_DIMENSIONS.OG.height.toString()} />
      <meta property="og:locale" content={locale === 'en' ? 'en_US' : locale === 'es' ? 'es_ES' : 'de_DE'} />
      
      {/* Twitter Card tags */}
      <meta name="twitter:card" content={metaTags.twitter.card} />
      <meta name="twitter:site" content={metaTags.twitter.site} />
      <meta name="twitter:title" content={metaTags.twitter.title} />
      <meta name="twitter:description" content={metaTags.twitter.description} />
      <meta name="twitter:image" content={metaTags.twitter.image} />
      
      {/* Additional meta tags for better SEO */}
      <meta name="author" content="UFOBeep Team" />
      <meta name="publisher" content="UFOBeep" />
      <meta name="copyright" content="© 2024 UFOBeep" />
      <meta name="language" content={locale} />
      <meta httpEquiv="Content-Language" content={locale} />
      
      {/* Mobile optimization */}
      <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
      <meta name="theme-color" content="#0f172a" />
      <meta name="msapplication-TileColor" content="#0f172a" />
      
      {/* Structured Data */}
      {allStructuredData.map((data, index) => (
        <script
          key={index}
          type="application/ld+json"
          dangerouslySetInnerHTML={{
            __html: JSON.stringify(data, null, 2)
          }}
        />
      ))}
      
      {/* Preload critical resources */}
      <link rel="preconnect" href="https://fonts.googleapis.com" />
      <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
      <link rel="dns-prefetch" href="//api.ufobeep.com" />
      
      {/* Icons */}
      <link rel="icon" href="/favicon.ico" />
      <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png" />
      <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png" />
      <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png" />
      <link rel="manifest" href="/manifest.json" />
    </Head>
  );
}

export default SEOHead;