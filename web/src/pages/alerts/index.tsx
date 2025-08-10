import React from 'react';
import Head from 'next/head';
import { GetStaticProps } from 'next';
import { useTranslation } from 'next-i18next';
import { getI18nProps } from '../../lib/i18n-config';
import { generateLocalizedMetadata, generateStructuredData } from '../../lib/metadata';
import LanguageSwitcher from '../../components/LanguageSwitcher';

export default function AlertsPage() {
  const { t } = useTranslation(['pages', 'common', 'navigation', 'meta']);
  const locale = 'en';
  
  const metadata = generateLocalizedMetadata({
    page: 'alerts',
    t,
    locale,
  });
  
  const structuredData = generateStructuredData({
    page: 'alerts',
    t,
    locale,
  });

  return (
    <>
      <Head>
        <title>{metadata.title as string}</title>
        <meta name="description" content={metadata.description || ''} />
        <meta name="keywords" content={metadata.keywords || ''} />
        
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
            <a href="/app" className="text-gray-300 hover:text-white transition-colors">
              {t('navigation:app')}
            </a>
            <LanguageSwitcher variant="minimal" />
          </nav>
        </header>

        <main className="container mx-auto px-4 py-12">
          {/* Title */}
          <div className="text-center mb-12">
            <h1 className="text-4xl md:text-6xl font-bold text-white mb-6">
              {t('pages:alerts.title')}
            </h1>
            <p className="text-xl text-gray-300 mb-8">
              {t('pages:alerts.subtitle')}
            </p>
          </div>

          {/* Filters */}
          <div className="bg-white/10 backdrop-blur-sm rounded-xl p-6 border border-white/10 mb-8">
            <div className="flex flex-wrap gap-4">
              <button className="bg-green-600 text-white px-4 py-2 rounded-lg font-medium">
                {t('pages:alerts.filters.all')}
              </button>
              <button className="bg-white/10 text-white px-4 py-2 rounded-lg hover:bg-white/20 transition-colors">
                {t('pages:alerts.filters.recent')}
              </button>
              <button className="bg-white/10 text-white px-4 py-2 rounded-lg hover:bg-white/20 transition-colors">
                {t('pages:alerts.filters.nearby')}
              </button>
              <button className="bg-white/10 text-white px-4 py-2 rounded-lg hover:bg-white/20 transition-colors">
                {t('pages:alerts.filters.category')}
              </button>
            </div>
          </div>

          {/* Placeholder for alerts list */}
          <div className="space-y-6">
            {[1, 2, 3].map((i) => (
              <div key={i} className="bg-white/10 backdrop-blur-sm rounded-xl p-6 border border-white/10">
                <div className="flex justify-between items-start mb-4">
                  <h3 className="text-xl font-semibold text-white">
                    Sample UFO Sighting #{i}
                  </h3>
                  <span className="text-sm text-gray-300">
                    2 hours ago
                  </span>
                </div>
                <p className="text-gray-300 mb-4">
                  Bright lights moving in formation observed over downtown area. Multiple witnesses report unusual flight patterns.
                </p>
                <div className="flex justify-between items-center">
                  <div className="flex gap-2">
                    <span className="bg-blue-600/20 text-blue-300 px-2 py-1 rounded text-sm">
                      {t('pages:alerts.categories.ufo')}
                    </span>
                    <span className="bg-green-600/20 text-green-300 px-2 py-1 rounded text-sm">
                      Verified
                    </span>
                  </div>
                  <a
                    href={`/alerts/${i}`}
                    className="text-green-400 hover:text-green-300 font-medium"
                  >
                    {t('common:view')} →
                  </a>
                </div>
              </div>
            ))}
          </div>

          {/* No alerts message */}
          <div className="text-center py-12">
            <p className="text-gray-400 text-lg">
              {t('pages:alerts.noAlerts')}
            </p>
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

export const getStaticProps: GetStaticProps = async ({ locale }) => {
  return {
    ...(await getI18nProps({ locale } as any, ['alerts'])),
    revalidate: 300,
  };
};