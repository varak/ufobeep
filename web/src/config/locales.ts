export interface LocaleInfo {
  code: string;
  name: string;
  nativeName: string;
  flag: string;
  rtl: boolean;
}

export const supportedLocales: Record<string, LocaleInfo> = {
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

export const defaultLocale = 'en';

export function getLocaleInfo(locale: string): LocaleInfo {
  return supportedLocales[locale] || supportedLocales[defaultLocale];
}

export function getSupportedLocaleCodes(): string[] {
  return Object.keys(supportedLocales);
}

export function isValidLocale(locale: string): boolean {
  return locale in supportedLocales;
}

export function getLocaleDisplayName(locale: string): string {
  const info = getLocaleInfo(locale);
  return `${info.flag} ${info.nativeName}`;
}

export function getBrowserLocale(): string {
  if (typeof window === 'undefined') {
    return defaultLocale;
  }

  const browserLocale = navigator.language.split('-')[0];
  return isValidLocale(browserLocale) ? browserLocale : defaultLocale;
}

export function getNextjsLocaleConfig() {
  return {
    locales: getSupportedLocaleCodes(),
    defaultLocale,
    localeDetection: true,
  };
}