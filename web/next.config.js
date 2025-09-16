/** @type {import('next').NextConfig} */
const nextConfig = {
  // Experimental features
  experimental: {
    // Disable problematic optimizations for now
    // optimizeCss: true,
  },
  
  // Build configuration: use default output (avoid standalone to prevent sharp requirement)
  
  // Image optimization
  images: {
    domains: ['localhost', 'ufobeep.com'],
    formats: ['image/webp', 'image/avif'],
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'ufobeep.com',
        port: '',
        pathname: '/media/**',
      }
    ],
  },
  
  // Note: Using custom App Router translation system instead of next-i18next
  
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
  
  // Rewrites for API proxying in development and production
  async rewrites() {
    const apiDestination = process.env.NODE_ENV === 'development'
      ? `${process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8000'}/:path*`
      : 'http://localhost:8000/:path*';

    return [
      // Don't proxy SSE stream endpoints - handle them locally with Next.js
      {
        source: '/api/beep/:id/comments/stream',
        destination: '/api/beep/:id/comments/stream', // Keep local
      },
      {
        source: '/api/alerts/stream',
        destination: '/api/alerts/stream', // Keep local
      },
      {
        source: '/api/debug/:path*',
        destination: '/api/debug/:path*', // Keep debug endpoints local
      },
      // Proxy all other API requests to backend
      {
        source: '/api/:path*',
        destination: apiDestination,
      },
    ];
  },

  // Redirects for admin interface only
  async redirects() {
    return [
      {
        source: '/admin/:path*',
        // api.ufobeep.com is deprecated; route admin under main domain
        destination: '/api/admin/:path*',
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
