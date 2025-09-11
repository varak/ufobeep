// Auto-generated locale configuration
export const supportedLocales = {
  "en": {
    "name": "English",
    "rtl": false
  },
  "es": {
    "name": "Spanish",
    "rtl": false
  },
  "de": {
    "name": "German",
    "rtl": false
  },
  "fr": {
    "name": "French",
    "rtl": false
  },
  "pt": {
    "name": "Portuguese",
    "rtl": false
  },
  "it": {
    "name": "Italian",
    "rtl": false
  },
  "ru": {
    "name": "Russian",
    "rtl": false
  },
  "ja": {
    "name": "Japanese",
    "rtl": false
  },
  "zh": {
    "name": "Chinese",
    "rtl": false
  },
  "ar": {
    "name": "Arabic",
    "rtl": true
  },
  "nl": {
    "name": "Dutch",
    "rtl": false
  },
  "pl": {
    "name": "Polish",
    "rtl": false
  },
  "cs": {
    "name": "Czech",
    "rtl": false
  },
  "tr": {
    "name": "Turkish",
    "rtl": false
  },
  "ko": {
    "name": "Korean",
    "rtl": false
  },
  "hi": {
    "name": "Hindi",
    "rtl": false
  },
  "sv": {
    "name": "Swedish",
    "rtl": false
  },
  "da": {
    "name": "Danish",
    "rtl": false
  },
  "no": {
    "name": "Norwegian",
    "rtl": false
  },
  "fi": {
    "name": "Finnish",
    "rtl": false
  },
  "el": {
    "name": "Greek",
    "rtl": false
  },
  "he": {
    "name": "Hebrew",
    "rtl": true
  }
};
export const defaultLocale = 'en';
export const fallbackLocale = 'en';

export function getLocaleDisplayName(locale) {
  return supportedLocales[locale]?.name || locale;
}

export function isRTLLocale(locale) {
  return supportedLocales[locale]?.rtl || false;
}
