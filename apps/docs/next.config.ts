import { createMDX } from 'fumadocs-mdx/next';
import type { NextConfig } from 'next';
import bundleAnalyzer from '@next/bundle-analyzer';

const withBundleAnalyzer = bundleAnalyzer({
  enabled: process.env.ANALYZE === 'true',
});

const withMDX = createMDX();

const isDev = process.env.NODE_ENV === 'development';

const cspHeader = `
  default-src 'self';
  script-src 'self' 'unsafe-eval' 'unsafe-inline' https://va.vercel-scripts.com;
  style-src 'self' 'unsafe-inline';
  img-src 'self' blob: data: https:;
  font-src 'self' data:;
  connect-src 'self' https://vitals.vercel-insights.com;
  frame-src 'self';
  object-src 'none';
  base-uri 'self';
  form-action 'self';
  frame-ancestors 'self';
  upgrade-insecure-requests;
`;

const defaultLocale = 'id';
const supportedLocales = ['id', 'en'];

const nextConfig: NextConfig = {
  reactStrictMode: true,
  images: {
    qualities: [25, 50, 75, 100],
  },
  reactCompiler: true,
  typedRoutes: true,
  experimental: {
    typedEnv: true,
  },
  typescript: {
    ignoreBuildErrors: false,
  },
  // Proxy-style i18n redirects (replaces middleware.ts)
  async redirects() {
    const redirects = [];

    // Redirect root path to default locale
    redirects.push({
      source: '/',
      destination: `/${defaultLocale}`,
      permanent: false,
    });

    // Redirect docs root to default locale docs
    redirects.push({
      source: '/docs',
      destination: `/${defaultLocale}/docs`,
      permanent: false,
    });

    // Redirect all /docs/:path* without locale to default locale
    redirects.push({
      source: '/docs/:path*',
      destination: `/${defaultLocale}/docs/:path*`,
      permanent: false,
    });

    return redirects;
  },
  // Proxy rewrites for locale handling
  async rewrites() {
    return {
      beforeFiles: [
        // Proxy non-locale prefixed paths to default locale
        // This ensures Fumadocs links with hidePrefix work correctly
      ],
    };
  },
  ...(isDev
    ? {}
    : {
        async headers() {
          return [
            {
              source: '/(.*)',
              headers: [
                {
                  key: 'Content-Security-Policy',
                  value: cspHeader.replace(/\n/g, '').trim(),
                },
                {
                  key: 'X-DNS-Prefetch-Control',
                  value: 'on',
                },
                {
                  key: 'X-Content-Type-Options',
                  value: 'nosniff',
                },
                {
                  key: 'X-Frame-Options',
                  value: 'SAMEORIGIN',
                },
                {
                  key: 'Referrer-Policy',
                  value: 'strict-origin-when-cross-origin',
                },
                {
                  key: 'Permissions-Policy',
                  value:
                    'geolocation=(), microphone=(), camera=(), payment=(), usb=(), accelerometer=(), gyroscope=(), magnetometer=()',
                },
                {
                  key: 'Cross-Origin-Embedder-Policy',
                  value: 'credentialless',
                },
                {
                  key: 'Cross-Origin-Opener-Policy',
                  value: 'same-origin',
                },
                {
                  key: 'Cross-Origin-Resource-Policy',
                  value: 'same-origin',
                },
                {
                  key: 'X-Permitted-Cross-Domain-Policies',
                  value: 'none',
                },
                {
                  key: 'Strict-Transport-Security',
                  value: 'max-age=31536000; includeSubDomains; preload',
                },
              ],
            },
            {
              source: '/:path*\\.(ico|png|jpg|jpeg|gif|webp|svg|css|js)',
              headers: [
                {
                  key: 'Cache-Control',
                  value: 'public, max-age=31536000, immutable',
                },
              ],
            },
          ];
        },
      }),
};

export default withMDX(withBundleAnalyzer(nextConfig));
