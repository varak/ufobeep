import React from 'react';
import { useTranslation } from 'next-i18next';
import Image from 'next/image';
import Link from 'next/link';

interface HeroSectionProps {
  className?: string;
}

const HeroSection: React.FC<HeroSectionProps> = ({ className = '' }) => {
  const { t } = useTranslation('common');

  return (
    <section className={`relative overflow-hidden bg-gradient-to-br from-indigo-900 via-purple-900 to-pink-900 ${className}`}>
      {/* Background Effects */}
      <div className="absolute inset-0 bg-grid opacity-20" />
      <div className="absolute inset-0 bg-gradient-to-t from-black/20 to-transparent" />
      
      {/* Animated Background Elements */}
      <div className="absolute top-10 left-10 w-72 h-72 bg-blue-500/10 rounded-full blur-3xl animate-pulse" />
      <div className="absolute bottom-10 right-10 w-96 h-96 bg-purple-500/10 rounded-full blur-3xl animate-pulse delay-1000" />
      <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-80 h-80 bg-pink-500/10 rounded-full blur-3xl animate-pulse delay-500" />

      <div className="relative container-fluid section-padding">
        <div className="grid lg:grid-cols-2 gap-12 lg:gap-16 items-center">
          {/* Hero Content */}
          <div className="text-center lg:text-left space-y-8 fade-in">
            {/* Badge */}
            <div className="inline-flex items-center px-4 py-2 rounded-full bg-white/10 backdrop-blur-sm border border-white/20 text-white/90 text-sm font-medium">
              <span className="w-2 h-2 bg-green-400 rounded-full mr-2 animate-pulse" />
              {t('hero.badge', 'Real-time UFO Alert System')}
            </div>

            {/* Main Headline */}
            <h1 className="text-hero text-white">
              <span className="block" data-testid="hero-title">
                {t('hero.title.line1', 'Spot Something')}
              </span>
              <span className="block text-gradient bg-gradient-to-r from-blue-400 to-purple-400">
                {t('hero.title.line2', 'Strange in the Sky?')}
              </span>
            </h1>

            {/* Subtitle */}
            <p className="text-subtitle text-white/80 max-w-2xl mx-auto lg:mx-0" data-testid="hero-subtitle">
              {t('hero.subtitle', 'Join thousands of sky watchers worldwide. Report sightings, get real-time alerts, and connect with a community of UFO enthusiasts.')}
            </p>

            {/* CTA Buttons */}
            <div className="flex flex-col sm:flex-row gap-4 justify-center lg:justify-start">
              <Link 
                href="/app" 
                className="btn-primary group relative overflow-hidden"
                data-testid="download-app-btn"
              >
                <span className="relative z-10 flex items-center">
                  <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z" />
                  </svg>
                  {t('hero.cta.download', 'Download App')}
                </span>
                <div className="absolute inset-0 bg-gradient-to-r from-blue-500 to-purple-500 transform scale-x-0 group-hover:scale-x-100 transition-transform origin-left duration-300" />
              </Link>

              <Link 
                href="/alerts" 
                className="btn-secondary backdrop-blur-sm bg-white/10 border-white/20 text-white hover:bg-white/20"
                data-testid="view-sightings-btn"
              >
                <span className="flex items-center">
                  <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                  </svg>
                  {t('hero.cta.browse', 'Browse Sightings')}
                </span>
              </Link>
            </div>

            {/* Stats */}
            <div className="grid grid-cols-3 gap-8 pt-8 border-t border-white/20">
              <div className="text-center lg:text-left">
                <div className="text-2xl lg:text-3xl font-bold text-white">15K+</div>
                <div className="text-sm text-white/60">{t('hero.stats.sightings', 'Sightings')}</div>
              </div>
              <div className="text-center lg:text-left">
                <div className="text-2xl lg:text-3xl font-bold text-white">50K+</div>
                <div className="text-sm text-white/60">{t('hero.stats.users', 'Users')}</div>
              </div>
              <div className="text-center lg:text-left">
                <div className="text-2xl lg:text-3xl font-bold text-white">24/7</div>
                <div className="text-sm text-white/60">{t('hero.stats.monitoring', 'Monitoring')}</div>
              </div>
            </div>
          </div>

          {/* Hero Visual */}
          <div className="relative slide-in-right">
            <div className="relative">
              {/* Phone Mockup */}
              <div className="relative mx-auto w-80 h-[640px] bg-gray-900 rounded-[3rem] p-2 shadow-xl">
                <div className="w-full h-full bg-black rounded-[2.5rem] overflow-hidden relative">
                  {/* Status Bar */}
                  <div className="absolute top-0 inset-x-0 h-8 bg-gradient-to-b from-gray-900 to-transparent z-10" />
                  
                  {/* App Screenshot */}
                  <div className="absolute inset-0 bg-gradient-to-br from-blue-900 to-purple-900">
                    {/* Mock App Content */}
                    <div className="p-6 pt-12 text-white">
                      <div className="text-center mb-8">
                        <div className="w-16 h-16 bg-white/20 rounded-2xl mx-auto mb-4 flex items-center justify-center">
                          <svg className="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                          </svg>
                        </div>
                        <h3 className="text-xl font-bold">UFOBeep</h3>
                        <p className="text-sm text-white/60">Live Sighting Alerts</p>
                      </div>

                      {/* Real alert data will be shown here when available */}
                      <div className="space-y-3">
                        <div className="bg-white/10 backdrop-blur-sm rounded-xl p-4 border border-white/20 text-center">
                          <p className="text-xs text-white/60">Live alerts appear here</p>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              {/* Floating Elements */}
              <div className="absolute -top-6 -left-6 w-12 h-12 bg-blue-500/20 rounded-full border border-blue-500/30 flex items-center justify-center animate-bounce">
                <svg className="w-6 h-6 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
                </svg>
              </div>

              <div className="absolute -bottom-6 -right-6 w-12 h-12 bg-purple-500/20 rounded-full border border-purple-500/30 flex items-center justify-center animate-bounce delay-300">
                <svg className="w-6 h-6 text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                </svg>
              </div>

              <div className="absolute top-1/2 -right-12 w-8 h-8 bg-green-500/20 rounded-full border border-green-500/30 flex items-center justify-center animate-pulse">
                <div className="w-2 h-2 bg-green-400 rounded-full" />
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Bottom Wave */}
      <div className="absolute bottom-0 left-0 right-0">
        <svg className="w-full h-20 text-white" fill="currentColor" viewBox="0 0 1200 120" preserveAspectRatio="none">
          <path d="M0,0V46.29c47.79,22.2,103.59,32.17,158,28,70.36-5.37,136.33-33.31,206.8-37.5C438.64,32.43,512.34,53.67,583,72.05c69.27,18,138.3,24.88,209.4,13.08,36.15-6,69.85-17.84,104.45-29.34C989.49,25,1113-14.29,1200,52.47V0Z" opacity=".25"></path>
          <path d="M0,0V15.81C13,36.92,27.64,56.86,47.69,72.05,99.41,111.27,165,111,224.58,91.58c31.15-10.15,60.09-26.07,89.67-39.8,40.92-19,84.73-46,130.83-49.67,36.26-2.85,70.9,9.42,98.6,31.56,31.77,25.39,62.32,62,103.63,73,40.44,10.79,81.35-6.69,119.13-24.28s75.16-39,116.92-43.05c59.73-5.85,113.28,22.88,168.9,38.84,30.2,8.66,59,6.17,87.09-7.5,22.43-10.89,48-26.93,60.65-49.24V0Z" opacity=".5"></path>
          <path d="M0,0V5.63C149.93,59,314.09,71.32,475.83,42.57c43-7.64,84.23-20.12,127.61-26.46,59-8.63,112.48,12.24,165.56,35.4C827.93,77.22,886,95.24,951.2,90c86.53-7,172.46-45.71,248.8-84.81V0Z"></path>
        </svg>
      </div>
    </section>
  );
};

export default HeroSection;