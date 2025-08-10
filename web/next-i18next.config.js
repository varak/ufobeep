const path = require('path');

/** @type {import('next-i18next').UserConfig} */
module.exports = {
  i18n: {
    defaultLocale: 'en',
    locales: ['en', 'es', 'de'],
    localePath: path.resolve('./public/locales'),
    localeDetection: true,
  },
  fallbackLng: {
    'es-ES': ['es', 'en'],
    'de-DE': ['de', 'en'],
    'en-US': ['en'],
    default: ['en'],
  },
  // Revalidation
  reloadOnPrerender: process.env.NODE_ENV === 'development',
  
  // Advanced options
  interpolation: {
    escapeValue: false,
  },
  react: {
    useSuspense: false,
  },
  
  // Debug mode in development
  debug: process.env.NODE_ENV === 'development',
  
  // Custom namespace separator
  nsSeparator: ':',
  keySeparator: '.',
  
  // Load all namespaces by default
  defaultNS: 'common',
  ns: ['common', 'navigation', 'pages', 'forms', 'alerts', 'errors', 'meta'],
  
  // Serialized options
  serializeConfig: false,
  
  // Custom detection options
  detection: {
    order: ['path', 'htmlTag', 'cookie', 'localStorage', 'navigator', 'header'],
    caches: ['cookie'],
    lookupFromPathIndex: 0,
    checkWhitelist: true,
  },
};