import { serverSideTranslations } from 'next-i18next/serverSideTranslations';
import { GetServerSidePropsContext, GetStaticPropsContext } from 'next';

export const defaultNamespaces = ['common', 'navigation', 'pages', 'meta'];

export async function getServerSideTranslations(
  locale: string = 'en',
  namespaces: string[] = defaultNamespaces
) {
  return await serverSideTranslations(locale, namespaces);
}

export async function getI18nProps(
  context: GetServerSidePropsContext | GetStaticPropsContext,
  additionalNamespaces: string[] = []
) {
  const locale = context.locale || 'en';
  const namespaces = [...defaultNamespaces, ...additionalNamespaces];
  
  return {
    props: {
      ...(await serverSideTranslations(locale, namespaces)),
    },
  };
}

// Helper for static pages
export async function getStaticI18nProps(
  locale: string = 'en',
  additionalNamespaces: string[] = []
) {
  const namespaces = [...defaultNamespaces, ...additionalNamespaces];
  
  return {
    props: {
      ...(await serverSideTranslations(locale, namespaces)),
    },
  };
}

// Generate static paths for all supported locales
export function getI18nPaths(paths: Array<{ params: Record<string, string> }> = [{}]) {
  const supportedLocales = ['en', 'es', 'de'];
  
  return {
    paths: supportedLocales.flatMap((locale) =>
      paths.map((path) => ({
        ...path,
        locale,
      }))
    ),
    fallback: false,
  };
}

// Type definitions for i18n props
export interface I18nProps {
  _nextI18Next?: {
    initialI18nStore: any;
    initialLocale: string;
    ns: string[];
    userConfig: any;
  };
}

// Configuration for different page types
export const pageConfigs = {
  home: {
    namespaces: ['common', 'navigation', 'pages', 'meta'],
    revalidate: 3600, // 1 hour
  },
  app: {
    namespaces: ['common', 'navigation', 'pages', 'meta'],
    revalidate: 3600,
  },
  alerts: {
    namespaces: ['common', 'navigation', 'pages', 'meta', 'alerts'],
    revalidate: 300, // 5 minutes
  },
  alertDetail: {
    namespaces: ['common', 'navigation', 'pages', 'meta', 'alerts'],
    revalidate: 300,
  },
  privacy: {
    namespaces: ['common', 'navigation', 'pages', 'meta'],
    revalidate: 86400, // 24 hours
  },
  terms: {
    namespaces: ['common', 'navigation', 'pages', 'meta'],
    revalidate: 86400,
  },
  safety: {
    namespaces: ['common', 'navigation', 'pages', 'meta'],
    revalidate: 86400,
  },
} as const;

export type PageType = keyof typeof pageConfigs;