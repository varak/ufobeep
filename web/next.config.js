/** @type {import('next').NextConfig} */
const nextConfig = {
  // Experimental features
  experimental: {
    // Enable optimizations
    optimizeCss: true,
  },
  
  // Build configuration
  output: 'standalone',
  
  // Image optimization
  images: {
    domains: ['localhost', 'api.ufobeep.com', 'api-staging.ufobeep.com'],
    formats: ['image/webp', 'image/avif'],
  },
  
  // Internationalization (using i18n instead of spread)
  i18n: {
    locales: ['en', 'es', 'de'],
    defaultLocale: 'en',
    localeDetection: false,
  },
  
  // Headers for security and performance
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'Referrer-Policy',
            value: 'strict-origin-when-cross-origin',
          },
        ],
      },
    ];
  },
  
  // Rewrites for API proxying in development
  async rewrites() {
    if (process.env.NODE_ENV === 'development') {
      return [
        {
          source: '/api/:path*',
          destination: `${process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8000'}/v1/:path*`,
        },
      ];
    }
    return [];
  },
  
  // Webpack configuration
  webpack: (config, { buildId, dev, isServer, defaultLoaders, webpack }) => {
    // Add custom webpack config if needed
    return config;
  },
};

module.exports = nextConfig;