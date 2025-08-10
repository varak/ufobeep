import React from 'react';
import Head from 'next/head';
import { GetStaticProps } from 'next';
import { useTranslation } from 'next-i18next';
import { getI18nProps } from '../lib/i18n-config';
import { generateLocalizedMetadata, generateStructuredData } from '../lib/metadata';
import LanguageSwitcher from '../components/LanguageSwitcher';
import { MiniMap } from '../components/MiniMap';
import { AppDownloadCTA } from '../components/AppDownloadCTA';

export default function HomePage() {
  const { t } = useTranslation(['pages', 'common', 'navigation', 'meta']);
  const locale = 'en'; // This will be provided by the router in a real scenario
  
  const metadata = generateLocalizedMetadata({
    page: 'home',
    t,
    locale,
  });
  
  const structuredData = generateStructuredData({
    page: 'home',
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
        <meta property="og:site_name" content={metadata.openGraph?.siteName || ''} />
        <meta property="og:locale" content={metadata.openGraph?.locale || ''} />
        
        {/* Twitter */}
        <meta name="twitter:card" content={metadata.twitter?.card || ''} />
        <meta name="twitter:site" content={metadata.twitter?.site || ''} />
        <meta name="twitter:creator" content={metadata.twitter?.creator || ''} />
        <meta name="twitter:title" content={metadata.twitter?.title || ''} />
        <meta name="twitter:description" content={metadata.twitter?.description || ''} />
        
        {/* Canonical */}
        <link rel="canonical" href={metadata.alternates?.canonical || ''} />
        
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
            <div className="w-10 h-10 bg-gradient-to-r from-green-400 to-emerald-500 rounded-lg flex items-center justify-center">
              <span className="text-xl font-bold text-white">🛸</span>
            </div>
            <h1 className="text-2xl font-bold text-white">
              {t('common:appName')}
            </h1>
          </div>
          
          <nav className="flex items-center gap-6">
            <a href="/alerts" className="text-gray-300 hover:text-white transition-colors">
              {t('navigation:alerts')}
            </a>
            <a href="/app" className="text-gray-300 hover:text-white transition-colors">
              {t('navigation:app')}
            </a>
            <LanguageSwitcher variant="minimal" />
          </nav>
        </header>

        {/* Hero Section */}
        <main className="container mx-auto px-4 py-12">
          <div className="text-center mb-16">
            <h1 className="text-5xl md:text-7xl font-bold text-white mb-6">
              {t('pages:home.hero.title')}
            </h1>
            <p className="text-xl md:text-2xl text-gray-300 mb-8 max-w-4xl mx-auto">
              {t('pages:home.hero.subtitle')}
            </p>
            
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <a
                href="/app"
                className="
                  bg-gradient-to-r from-green-500 to-emerald-600 
                  text-white px-8 py-4 rounded-lg font-semibold
                  hover:from-green-600 hover:to-emerald-700 
                  transition-all duration-200 transform hover:scale-105
                "
              >
                {t('pages:home.hero.ctaPrimary')}
              </a>
              <a
                href="/alerts"
                className="
                  border-2 border-white/20 text-white px-8 py-4 rounded-lg font-semibold
                  hover:border-white/40 hover:bg-white/5
                  transition-all duration-200
                "
              >
                {t('pages:home.hero.ctaSecondary')}
              </a>
            </div>
          </div>

          {/* Features Grid */}
          <div className="grid md:grid-cols-3 gap-8 mb-16">
            <div className="bg-white/10 backdrop-blur-sm rounded-xl p-8 border border-white/10">
              <div className="w-12 h-12 bg-blue-500/20 rounded-lg flex items-center justify-center mb-4">
                <span className="text-2xl">⚡</span>
              </div>
              <h3 className="text-xl font-semibold text-white mb-3">
                {t('pages:home.hero.features.realtime')}
              </h3>
              <p className="text-gray-300">
                Report sightings with GPS precision and real-time data collection.
              </p>
            </div>

            <div className="bg-white/10 backdrop-blur-sm rounded-xl p-8 border border-white/10">
              <div className="w-12 h-12 bg-green-500/20 rounded-lg flex items-center justify-center mb-4">
                <span className="text-2xl">🌐</span>
              </div>
              <h3 className="text-xl font-semibold text-white mb-3">
                {t('pages:home.hero.features.community')}
              </h3>
              <p className="text-gray-300">
                Connect with observers worldwide and discuss your sightings.
              </p>
            </div>

            <div className="bg-white/10 backdrop-blur-sm rounded-xl p-8 border border-white/10">
              <div className="w-12 h-12 bg-purple-500/20 rounded-lg flex items-center justify-center mb-4">
                <span className="text-2xl">🔬</span>
              </div>
              <h3 className="text-xl font-semibold text-white mb-3">
                {t('pages:home.hero.features.scientific')}
              </h3>
              <p className="text-gray-300">
                Scientific data collection with metadata and verification.
              </p>
            </div>
          </div>

          {/* Recent Sightings Section */}
          <section className="mb-16">
            <div className="flex justify-between items-center mb-8">
              <h2 className="text-3xl font-bold text-white">
                {t('pages:home.recentSightings.title')}
              </h2>
              <a
                href="/alerts"
                className="text-green-400 hover:text-green-300 font-medium"
              >
                {t('pages:home.recentSightings.viewAll')} →
              </a>
            </div>
            
            <div className="bg-white/5 backdrop-blur-sm rounded-xl border border-white/10 overflow-hidden">
              <MiniMap />
            </div>
          </section>

          {/* App Download CTA */}
          <AppDownloadCTA />
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
    revalidate: 3600, // Revalidate every hour
  };
};