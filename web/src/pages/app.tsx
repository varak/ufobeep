import React from 'react';
import Head from 'next/head';
import { GetStaticProps } from 'next';
import { useTranslation } from 'next-i18next';
import { getI18nProps } from '../lib/i18n-config';
import { generateLocalizedMetadata, generateStructuredData } from '../lib/metadata';
import LanguageSwitcher from '../components/LanguageSwitcher';
import { AppDownloadCTA } from '../components/AppDownloadCTA';

export default function AppPage() {
  const { t } = useTranslation(['pages', 'common', 'navigation', 'meta']);
  const locale = 'en'; // This will be provided by the router in a real scenario
  
  const metadata = generateLocalizedMetadata({
    page: 'app',
    t,
    locale,
  });
  
  const structuredData = generateStructuredData({
    page: 'app',
    t,
    locale,
  });

  return (
    <>
      <Head>
        <title>{metadata.title as string}</title>
        <meta name="description" content={metadata.description || ''} />
        <meta name="keywords" content={metadata.keywords || ''} />
        
        {/* OpenGraph */}
        <meta property="og:title" content={metadata.openGraph?.title || ''} />
        <meta property="og:description" content={metadata.openGraph?.description || ''} />
        <meta property="og:type" content={metadata.openGraph?.type || ''} />
        <meta property="og:url" content={metadata.openGraph?.url?.toString() || ''} />
        
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
            <LanguageSwitcher variant="minimal" />
          </nav>
        </header>

        <main className="container mx-auto px-4 py-12">
          {/* Hero Section */}
          <div className="text-center mb-16">
            <h1 className="text-4xl md:text-6xl font-bold text-white mb-6">
              {t('pages:app.title')}
            </h1>
            <p className="text-xl text-gray-300 mb-8 max-w-3xl mx-auto">
              {t('pages:app.subtitle')}
            </p>
          </div>

          {/* App Features */}
          <section className="mb-16">
            <h2 className="text-3xl font-bold text-white mb-8 text-center">
              {t('pages:app.features.title')}
            </h2>
            
            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8 mb-12">
              <div className="bg-white/10 backdrop-blur-sm rounded-xl p-6 border border-white/10">
                <div className="w-12 h-12 bg-blue-500/20 rounded-lg flex items-center justify-center mb-4">
                  <span className="text-2xl">🧭</span>
                </div>
                <h3 className="text-lg font-semibold text-white mb-3">
                  {t('pages:app.features.compass')}
                </h3>
              </div>

              <div className="bg-white/10 backdrop-blur-sm rounded-xl p-6 border border-white/10">
                <div className="w-12 h-12 bg-green-500/20 rounded-lg flex items-center justify-center mb-4">
                  <span className="text-2xl">📍</span>
                </div>
                <h3 className="text-lg font-semibold text-white mb-3">
                  {t('pages:app.features.gps')}
                </h3>
              </div>

              <div className="bg-white/10 backdrop-blur-sm rounded-xl p-6 border border-white/10">
                <div className="w-12 h-12 bg-purple-500/20 rounded-lg flex items-center justify-center mb-4">
                  <span className="text-2xl">📸</span>
                </div>
                <h3 className="text-lg font-semibold text-white mb-3">
                  {t('pages:app.features.photos')}
                </h3>
              </div>

              <div className="bg-white/10 backdrop-blur-sm rounded-xl p-6 border border-white/10">
                <div className="w-12 h-12 bg-orange-500/20 rounded-lg flex items-center justify-center mb-4">
                  <span className="text-2xl">💬</span>
                </div>
                <h3 className="text-lg font-semibold text-white mb-3">
                  {t('pages:app.features.community')}
                </h3>
              </div>

              <div className="bg-white/10 backdrop-blur-sm rounded-xl p-6 border border-white/10">
                <div className="w-12 h-12 bg-red-500/20 rounded-lg flex items-center justify-center mb-4">
                  <span className="text-2xl">📱</span>
                </div>
                <h3 className="text-lg font-semibold text-white mb-3">
                  {t('pages:app.features.offline')}
                </h3>
              </div>
            </div>
          </section>

          {/* Download Section */}
          <AppDownloadCTA />

          {/* Permissions Section */}
          <section className="mt-16">
            <h2 className="text-3xl font-bold text-white mb-8 text-center">
              {t('pages:app.permissions.title')}
            </h2>
            
            <div className="bg-white/5 backdrop-blur-sm rounded-xl p-8 border border-white/10 max-w-4xl mx-auto">
              <div className="grid md:grid-cols-3 gap-6 mb-6">
                <div className="text-center">
                  <div className="w-12 h-12 bg-blue-500/20 rounded-lg flex items-center justify-center mx-auto mb-3">
                    <span className="text-xl">📍</span>
                  </div>
                  <h3 className="text-white font-semibold mb-2">
                    {t('pages:app.permissions.location')}
                  </h3>
                </div>

                <div className="text-center">
                  <div className="w-12 h-12 bg-green-500/20 rounded-lg flex items-center justify-center mx-auto mb-3">
                    <span className="text-xl">📷</span>
                  </div>
                  <h3 className="text-white font-semibold mb-2">
                    {t('pages:app.permissions.camera')}
                  </h3>
                </div>

                <div className="text-center">
                  <div className="w-12 h-12 bg-purple-500/20 rounded-lg flex items-center justify-center mx-auto mb-3">
                    <span className="text-xl">💾</span>
                  </div>
                  <h3 className="text-white font-semibold mb-2">
                    {t('pages:app.permissions.storage')}
                  </h3>
                </div>
              </div>
              
              <p className="text-gray-300 text-center">
                {t('pages:app.permissions.why')}
              </p>
            </div>
          </section>
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
    ...(await getI18nProps({ locale } as any)),
    revalidate: 3600,
  };
};