const supportedLocales = {
  en: {
    code: 'en',
    name: 'English',
    nativeName: 'English',
    flag: '🇺🇸',
    rtl: false,
  },
  es: {
    code: 'es',
    name: 'Spanish',
    nativeName: 'Español',
    flag: '🇪🇸',
    rtl: false,
  },
  de: {
    code: 'de',
    name: 'German',
    nativeName: 'Deutsch',
    flag: '🇩🇪',
    rtl: false,
  },
};

const defaultLocale = 'en';

function getLocaleInfo(locale) {
  return supportedLocales[locale] || supportedLocales[defaultLocale];
}

function getSupportedLocaleCodes() {
  return Object.keys(supportedLocales);
}

function isValidLocale(locale) {
  return locale in supportedLocales;
}

function getLocaleDisplayName(locale) {
  const info = getLocaleInfo(locale);
  return `${info.flag} ${info.nativeName}`;
}

function getBrowserLocale() {
  if (typeof window === 'undefined') {
    return defaultLocale;
  }

  const browserLocale = navigator.language.split('-')[0];
  return isValidLocale(browserLocale) ? browserLocale : defaultLocale;
}

function getNextjsLocaleConfig() {
  return {
    locales: getSupportedLocaleCodes(),
    defaultLocale,
    localeDetection: true,
  };
}

module.exports = {
  supportedLocales,
  defaultLocale,
  getLocaleInfo,
  getSupportedLocaleCodes,
  isValidLocale,
  getLocaleDisplayName,
  getBrowserLocale,
  getNextjsLocaleConfig,
};