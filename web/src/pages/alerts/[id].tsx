import React from 'react';
import Head from 'next/head';
import { GetStaticProps, GetStaticPaths } from 'next';
import { useRouter } from 'next/router';
import { useTranslation } from 'next-i18next';
import { getI18nProps } from '../../lib/i18n-config';
import { generateLocalizedMetadata, generateStructuredData } from '../../lib/metadata';
import LanguageSwitcher from '../../components/LanguageSwitcher';
import { MatrixTranscript } from '../../components/MatrixTranscript';

export default function AlertDetailPage() {
  const router = useRouter();
  const { id } = router.query;
  const { t } = useTranslation(['pages', 'common', 'navigation', 'meta']);
  const locale = 'en';
  
  // Mock alert data - in production this would come from your API
  const mockAlertData = {
    id: id as string,
    title: `UFO Sighting Report #${id}`,
    description: 'Observed a bright, disc-shaped object moving silently across the evening sky at approximately 7:30 PM local time. The object displayed unusual flight characteristics, including rapid acceleration and sudden directional changes that appeared to defy conventional physics.',
    location: 'San Francisco Bay Area, California, USA',
    timestamp: '2024-01-10T15:30:00Z',
    category: 'UAP',
    imageUrl: '/images/sighting-placeholder.jpg',
    reporterName: 'Anonymous Observer',
    witnesses: 3,
    coordinates: { lat: 37.7749, lng: -122.4194 },
  };

  const metadata = generateLocalizedMetadata({
    page: 'alertDetail',
    t,
    locale,
    params: { id: id as string },
    alertData: mockAlertData,
  });
  
  const structuredData = generateStructuredData({
    page: 'alertDetail',
    t,
    locale,
    params: { id: id as string },
    additionalData: {
      alert: {
        title: mockAlertData.title,
        description: mockAlertData.description,
        createdAt: mockAlertData.timestamp,
        updatedAt: mockAlertData.timestamp,
        reporterName: mockAlertData.reporterName,
        location: mockAlertData.location,
        coordinates: mockAlertData.coordinates,
        imageUrl: mockAlertData.imageUrl,
        id: mockAlertData.id,
      }
    }
  });

  return (
    <>
      <Head>
        <title>{metadata.title as string}</title>
        <meta name="description" content={metadata.description || ''} />
        <meta name="keywords" content={metadata.keywords || ''} />
        
        {/* Canonical URL */}
        <link rel="canonical" href={metadata.alternates?.canonical || ''} />
        
        {/* Language alternates */}
        {metadata.alternates?.languages && Object.entries(metadata.alternates.languages).map(([lang, url]) => (
          <link key={lang} rel="alternate" hrefLang={lang} href={url as string} />
        ))}
        
        {/* OpenGraph tags */}
        <meta property="og:title" content={metadata.openGraph?.title || ''} />
        <meta property="og:description" content={metadata.openGraph?.description || ''} />
        <meta property="og:type" content={metadata.openGraph?.type || ''} />
        <meta property="og:url" content={metadata.openGraph?.url?.toString() || ''} />
        <meta property="og:site_name" content={metadata.openGraph?.siteName || ''} />
        <meta property="og:locale" content={metadata.openGraph?.locale || ''} />
        {metadata.openGraph?.images?.map((image, index) => (
          <React.Fragment key={index}>
            <meta property="og:image" content={image.url?.toString() || ''} />
            <meta property="og:image:width" content={image.width?.toString() || ''} />
            <meta property="og:image:height" content={image.height?.toString() || ''} />
            <meta property="og:image:alt" content={image.alt || ''} />
          </React.Fragment>
        ))}
        
        {/* Twitter Card tags */}
        <meta name="twitter:card" content={metadata.twitter?.card || ''} />
        <meta name="twitter:site" content={metadata.twitter?.site || ''} />
        <meta name="twitter:creator" content={metadata.twitter?.creator || ''} />
        <meta name="twitter:title" content={metadata.twitter?.title || ''} />
        <meta name="twitter:description" content={metadata.twitter?.description || ''} />
        {metadata.twitter?.images?.[0] && (
          <meta name="twitter:image" content={metadata.twitter.images[0] as string} />
        )}
        
        {/* Additional SEO meta tags */}
        <meta name="author" content={mockAlertData.reporterName} />
        <meta name="geo.region" content="US-CA" />
        <meta name="geo.position" content={`${mockAlertData.coordinates.lat};${mockAlertData.coordinates.lng}`} />
        <meta name="ICBM" content={`${mockAlertData.coordinates.lat}, ${mockAlertData.coordinates.lng}`} />
        
        {/* Article-specific meta tags */}
        <meta property="article:published_time" content={mockAlertData.timestamp} />
        <meta property="article:modified_time" content={mockAlertData.timestamp} />
        <meta property="article:author" content={mockAlertData.reporterName} />
        <meta property="article:section" content="UFO Sightings" />
        <meta property="article:tag" content={mockAlertData.category} />
        
        {/* Structured Data */}
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{
            __html: JSON.stringify(structuredData)
          }}
        />
      </Head>

      <div className="min-h-screen bg-gradient-to-br from-slate-900 via-blue-900 to-slate-800">
        {/* Header */}
        <header className="container mx-auto px-4 py-6 flex justify-between items-center">
          <div className="flex items-center gap-3">
            <a href="/" className="flex items-center gap-3">
              <div className="w-10 h-10 bg-gradient-to-r from-green-400 to-emerald-500 rounded-lg flex items-center justify-center">
                <span className="text-xl font-bold text-white">🛸</span>
              </div>
              <span className="text-2xl font-bold text-white">
                {t('common:appName')}
              </span>
            </a>
          </div>
          
          <nav className="flex items-center gap-6">
            <a href="/" className="text-gray-300 hover:text-white transition-colors">
              {t('navigation:home')}
            </a>
            <a href="/alerts" className="text-gray-300 hover:text-white transition-colors">
              {t('navigation:alerts')}
            </a>
            <a href="/app" className="text-gray-300 hover:text-white transition-colors">
              {t('navigation:app')}
            </a>
            <LanguageSwitcher variant="minimal" />
          </nav>
        </header>

        <main className="container mx-auto px-4 py-12">
          {/* Breadcrumb */}
          <nav className="mb-8" aria-label={t('navigation:breadcrumb')}>
            <div className="flex items-center gap-2 text-sm text-gray-400">
              <a href="/" className="hover:text-white transition-colors">
                {t('navigation:home')}
              </a>
              <span>/</span>
              <a href="/alerts" className="hover:text-white transition-colors">
                {t('navigation:alerts')}
              </a>
              <span>/</span>
              <span className="text-white">#{id}</span>
            </div>
          </nav>

          {/* Alert Details */}
          <div className="grid lg:grid-cols-3 gap-8">
            {/* Main Content */}
            <div className="lg:col-span-2">
              <div className="bg-white/10 backdrop-blur-sm rounded-xl p-8 border border-white/10 mb-8">
                <h1 className="text-3xl font-bold text-white mb-6">
                  {t('pages:alertDetail.title')} #{id}
                </h1>
                
                <div className="grid md:grid-cols-2 gap-6 mb-8">
                  <div>
                    <h3 className="text-lg font-semibold text-white mb-2">
                      {t('pages:alertDetail.reportedBy')}
                    </h3>
                    <p className="text-gray-300">Anonymous Observer</p>
                  </div>
                  
                  <div>
                    <h3 className="text-lg font-semibold text-white mb-2">
                      {t('pages:alertDetail.reportedAt')}
                    </h3>
                    <p className="text-gray-300">January 10, 2024 at 3:30 PM UTC</p>
                  </div>
                  
                  <div>
                    <h3 className="text-lg font-semibold text-white mb-2">
                      {t('pages:alertDetail.coordinates')}
                    </h3>
                    <p className="text-gray-300">37.7749° N, 122.4194° W</p>
                  </div>
                  
                  <div>
                    <h3 className="text-lg font-semibold text-white mb-2">
                      {t('pages:alertDetail.compass')}
                    </h3>
                    <p className="text-gray-300">245° SW</p>
                  </div>
                </div>
                
                <div className="mb-8">
                  <h3 className="text-lg font-semibold text-white mb-4">
                    {t('common:description')}
                  </h3>
                  <p className="text-gray-300 leading-relaxed">
                    Observed a bright, disc-shaped object moving silently across the evening sky at approximately 7:30 PM local time. 
                    The object displayed unusual flight characteristics, including rapid acceleration and sudden directional changes 
                    that appeared to defy conventional physics. Multiple witnesses present at the location confirmed the sighting. 
                    The object was visible for approximately 45 seconds before disappearing behind cloud cover.
                  </p>
                </div>
                
                <div className="flex flex-wrap gap-2 mb-6">
                  <span className="bg-blue-600/20 text-blue-300 px-3 py-1 rounded-full text-sm">
                    UFO
                  </span>
                  <span className="bg-green-600/20 text-green-300 px-3 py-1 rounded-full text-sm">
                    Verified
                  </span>
                  <span className="bg-purple-600/20 text-purple-300 px-3 py-1 rounded-full text-sm">
                    Multiple Witnesses
                  </span>
                </div>
                
                <div className="flex gap-4">
                  <button className="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg transition-colors">
                    {t('pages:alertDetail.shareReport')}
                  </button>
                  <button className="bg-white/10 hover:bg-white/20 text-white px-4 py-2 rounded-lg transition-colors">
                    {t('pages:alertDetail.reportIssue')}
                  </button>
                </div>
              </div>
              
              {/* Discussion Section */}
              <div className="bg-white/10 backdrop-blur-sm rounded-xl p-8 border border-white/10">
                <h2 className="text-2xl font-bold text-white mb-6">
                  {t('pages:alertDetail.discussion')}
                </h2>
                <p className="text-gray-300 mb-6">
                  {t('pages:alertDetail.joinDiscussion')}
                </p>
                
                <MatrixTranscript />
              </div>
            </div>
            
            {/* Sidebar */}
            <div className="lg:col-span-1">
              <div className="bg-white/10 backdrop-blur-sm rounded-xl p-6 border border-white/10 mb-8">
                <h3 className="text-lg font-semibold text-white mb-4">
                  Sighting Location
                </h3>
                <div className="aspect-video bg-gray-800 rounded-lg mb-4 flex items-center justify-center">
                  <span className="text-gray-400">Map Placeholder</span>
                </div>
                <p className="text-gray-300 text-sm">
                  San Francisco Bay Area, California, USA
                </p>
              </div>
              
              <div className="bg-white/10 backdrop-blur-sm rounded-xl p-6 border border-white/10">
                <h3 className="text-lg font-semibold text-white mb-4">
                  {t('pages:alertDetail.relatedSightings')}
                </h3>
                <div className="space-y-3">
                  {[1, 2, 3].map((i) => (
                    <a
                      key={i}
                      href={`/alerts/${parseInt(id as string) + i}`}
                      className="block p-3 bg-white/5 rounded-lg hover:bg-white/10 transition-colors"
                    >
                      <div className="text-sm text-white font-medium mb-1">
                        Sighting #{parseInt(id as string) + i}
                      </div>
                      <div className="text-xs text-gray-400">
                        2.5 km away • 3 days ago
                      </div>
                    </a>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </main>

        {/* Footer */}
        <footer className="container mx-auto px-4 py-8 border-t border-white/10 mt-16">
          <div className="flex flex-col md:flex-row justify-between items-center gap-4">
            <div className="text-gray-400">
              © 2024 {t('common:appName')}. All rights reserved.
            </div>
            <div className="flex gap-6">
              <a href="/privacy" className="text-gray-400 hover:text-white transition-colors">
                {t('navigation:privacy')}
              </a>
              <a href="/terms" className="text-gray-400 hover:text-white transition-colors">
                {t('navigation:terms')}
              </a>
              <a href="/safety" className="text-gray-400 hover:text-white transition-colors">
                {t('navigation:safety')}
              </a>
            </div>
          </div>
        </footer>
      </div>
    </>
  );
}

export const getStaticProps: GetStaticProps = async ({ locale, params }) => {
  return {
    ...(await getI18nProps({ locale } as any, ['alerts'])),
    revalidate: 300,
  };
};

export const getStaticPaths: GetStaticPaths = async ({ locales }) => {
  const paths: Array<{ params: { id: string }; locale: string }> = [];
  
  // Generate paths for sample alerts in all locales
  const alertIds = ['1', '2', '3', '4', '5'];
  const supportedLocales = locales || ['en', 'es', 'de'];
  
  supportedLocales.forEach(locale => {
    alertIds.forEach(id => {
      paths.push({
        params: { id },
        locale,
      });
    });
  });

  return {
    paths,
    fallback: true,
  };
};