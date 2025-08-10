import React from 'react';
import { useTranslation } from 'next-i18next';

interface Feature {
  id: string;
  icon: React.ReactNode;
  title: string;
  description: string;
  highlight?: boolean;
}

interface FeaturesSectionProps {
  className?: string;
}

const FeaturesSection: React.FC<FeaturesSectionProps> = ({ className = '' }) => {
  const { t } = useTranslation('common');

  const features: Feature[] = [
    {
      id: 'realtime-reporting',
      icon: (
        <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
        </svg>
      ),
      title: t('features.realtime.title', 'Real-time Alerts'),
      description: t('features.realtime.description', 'Get instant notifications about UFO sightings near your location with precise coordinates and timing.'),
      highlight: true
    },
    {
      id: 'global-community',
      icon: (
        <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
        </svg>
      ),
      title: t('features.community.title', 'Global Community'),
      description: t('features.community.description', 'Connect with thousands of sky watchers worldwide. Share experiences and verify sightings together.')
    },
    {
      id: 'scientific-analysis',
      icon: (
        <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
        </svg>
      ),
      title: t('features.analysis.title', 'Scientific Analysis'),
      description: t('features.analysis.description', 'Advanced data enrichment with weather conditions, aircraft tracking, and celestial object positions.'),
      highlight: true
    },
    {
      id: 'pilot-mode',
      icon: (
        <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
        </svg>
      ),
      title: t('features.pilot.title', 'Pilot Mode'),
      description: t('features.pilot.description', 'Aviation-grade navigation tools with artificial horizon, weather data, and airspace information.')
    },
    {
      id: 'ar-compass',
      icon: (
        <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9" />
        </svg>
      ),
      title: t('features.compass.title', 'AR Compass'),
      description: t('features.compass.description', 'Augmented reality compass showing precise directions to nearby sightings with bearing calculations.'),
      highlight: true
    },
    {
      id: 'offline-sync',
      icon: (
        <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-3m-1 4l-3-3m0 0l-3 3m3-3v12" />
        </svg>
      ),
      title: t('features.offline.title', 'Offline Sync'),
      description: t('features.offline.description', 'Record sightings even without internet connection. Data syncs automatically when back online.')
    }
  ];

  return (
    <section className={`bg-white ${className}`} data-testid="features-section">
      <div className="container-fluid section-padding">
        {/* Section Header */}
        <div className="text-center max-w-3xl mx-auto mb-16 fade-in">
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-gray-900 mb-6">
            {t('features.title', 'Everything You Need to')}
            <span className="block text-gradient bg-gradient-to-r from-blue-600 to-purple-600">
              {t('features.subtitle', 'Track the Unknown')}
            </span>
          </h2>
          <p className="text-xl text-gray-600 leading-relaxed">
            {t('features.description', 'Professional-grade tools and community features designed for serious UFO researchers and sky watchers.')}
          </p>
        </div>

        {/* Features Grid */}
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8 lg:gap-12">
          {features.map((feature, index) => (
            <div
              key={feature.id}
              className={`group relative ${feature.highlight ? 'card-glow' : 'card'} p-8 text-center slide-up`}
              style={{ animationDelay: `${index * 100}ms` }}
              data-testid={`feature-${feature.id}`}
            >
              {/* Highlight Badge */}
              {feature.highlight && (
                <div className="absolute -top-3 left-1/2 transform -translate-x-1/2">
                  <span className="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-gradient-to-r from-blue-600 to-purple-600 text-white">
                    <svg className="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
                      <path fillRule="evenodd" d="M11.3 1.046A1 1 0 0112 2v5h4a1 1 0 01.82 1.573l-7 10A1 1 0 018 18v-5H4a1 1 0 01-.82-1.573l7-10a1 1 0 011.12-.38z" clipRule="evenodd" />
                    </svg>
                    Popular
                  </span>
                </div>
              )}

              {/* Icon */}
              <div className={`inline-flex items-center justify-center w-16 h-16 rounded-2xl mb-6 group-hover:scale-110 transition-transform duration-300 ${
                feature.highlight 
                  ? 'bg-gradient-to-r from-blue-600 to-purple-600 text-white' 
                  : 'bg-blue-100 text-blue-600 group-hover:bg-blue-600 group-hover:text-white'
              }`}>
                {feature.icon}
              </div>

              {/* Content */}
              <h3 className="text-xl font-bold text-gray-900 mb-4 group-hover:text-blue-600 transition-colors">
                {feature.title}
              </h3>
              <p className="text-gray-600 leading-relaxed">
                {feature.description}
              </p>

              {/* Hover Effect */}
              <div className="absolute inset-0 bg-gradient-to-br from-blue-50 to-purple-50 rounded-xl opacity-0 group-hover:opacity-100 transition-opacity duration-300 -z-10" />
            </div>
          ))}
        </div>

        {/* Bottom CTA */}
        <div className="text-center mt-16 fade-in">
          <div className="inline-flex items-center px-6 py-3 rounded-full bg-blue-50 text-blue-700 text-sm font-medium mb-6">
            <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
            </svg>
            {t('features.security', 'Privacy-first • Open source • No tracking')}
          </div>
          
          <h3 className="text-2xl font-bold text-gray-900 mb-4">
            {t('features.cta.title', 'Ready to Start Sky Watching?')}
          </h3>
          <p className="text-gray-600 mb-8 max-w-2xl mx-auto">
            {t('features.cta.description', 'Join our community of researchers and help document unexplained aerial phenomena worldwide.')}
          </p>
          
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <a href="/app" className="btn-primary">
              <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z" />
              </svg>
              {t('features.cta.download', 'Download UFOBeep')}
            </a>
            <a href="/alerts" className="btn-secondary">
              <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
              </svg>
              {t('features.cta.browse', 'Explore Sightings')}
            </a>
          </div>
        </div>
      </div>
    </section>
  );
};

export default FeaturesSection;