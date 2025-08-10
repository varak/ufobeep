import type { AppProps } from 'next/app';
import { appWithTranslation } from 'next-i18next';
import { Inter } from 'next/font/google';
import Head from 'next/head';
import '../app/globals.css';
import { LocaleDetector } from '../components/LanguageSwitcher';

const inter = Inter({ subsets: ['latin'] });

function MyApp({ Component, pageProps }: AppProps) {
  return (
    <>
      <Head>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
      </Head>
      
      <div className={`${inter.className} bg-dark-background text-text-primary min-h-screen`}>
        <LocaleDetector />
        <Component {...pageProps} />
      </div>
    </>
  );
}

export default appWithTranslation(MyApp);