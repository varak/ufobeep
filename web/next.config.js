const { i18n } = require('./next-i18next.config');

/** @type {import('next').NextConfig} */
const nextConfig = {
  // Experimental features
  experimental: {
    // Disable problematic optimizations for now
    // optimizeCss: true,
  },
  
  // Build configuration
  output: 'standalone',
  
  // Image optimization
  images: {
    domains: ['localhost', 'ufobeep.com', 'api.ufobeep.com'],
    formats: ['image/webp', 'image/avif'],
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'ufobeep.com',
        port: '',
        pathname: '/media/**',
      },
      {
        protocol: 'https', 
        hostname: 'api.ufobeep.com',
        port: '',
        pathname: '/media/**',
      }
    ],
  },
  
  // Internationalization
  i18n,
  
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
          destination: `${process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8000'}/:path*`,
        },
      ];
    }
    return [];
  },

  // Redirects for admin interface
  async redirects() {
    return [
      {
        source: '/admin/:path*',
        destination: 'https://api.ufobeep.com/admin/:path*',
        permanent: false,
      },
    ];
  },
  
  // Webpack configuration
  webpack: (config, { buildId, dev, isServer, defaultLoaders, webpack }) => {
    // Add custom webpack config if needed
    return config;
  },
};

module.exports = nextConfig;