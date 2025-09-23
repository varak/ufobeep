// Import Sentry for error tracking
const { withSentryConfig } = require('@sentry/nextjs');

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
      // First, handle all routes that should NOT be proxied to backend
      // These return empty array to prevent fallback to catch-all rule

      // WebSocket endpoints are handled by nginx proxy at /ws/*
      // No local rewrites needed for WebSocket connections

      // Debug endpoints - handle locally
      {
        source: '/api/debug/:path*',
        destination: '/api/debug/:path*',
      },

      // All other API routes - proxy to backend
      {
        source: '/api/:path*',
        destination: apiDestination,
      },
    ];
  },

  // Redirects - admin API but preserve admin pages
  async redirects() {
    return [
      // Only redirect /admin without any path to avoid conflicts with /admin/users page
      {
        source: '/admin',
        destination: '/api/admin',
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

// Export with Sentry configuration
module.exports = withSentryConfig(nextConfig, {
  // For all available options, see:
  // https://github.com/getsentry/sentry-webpack-plugin#options

  // Suppresses source map uploading logs during build
  silent: true,
  org: process.env.SENTRY_ORG,
  project: process.env.SENTRY_PROJECT,
}, {
  // For all available options, see:
  // https://docs.sentry.io/platforms/javascript/guides/nextjs/manual-setup/

  // Upload a larger set of source maps for prettier stack traces (increases build time)
  widenClientFileUpload: true,

  // Route browser requests to Sentry through a Next.js rewrite to circumvent ad-blockers
  tunnelRoute: "/monitoring",

  // Hides source maps from generated client bundles
  hideSourceMaps: true,

  // Automatically tree-shake Sentry logger statements to reduce bundle size
  disableLogger: true,

  // Enables automatic instrumentation of Vercel Cron Monitors.
  // See the following for more information:
  // https://docs.sentry.io/product/crons/
  // https://docs.sentry.io/platforms/javascript/guides/nextjs/manual-setup/
  automaticVercelMonitors: true,
});
