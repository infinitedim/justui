import path from 'node:path';
import { createMDX } from 'fumadocs-mdx/next';
import type { NextConfig } from 'next';
import bundleAnalyzer from '@next/bundle-analyzer';

const withBundleAnalyzer = bundleAnalyzer({
  enabled: process.env.ANALYZE === 'true',
});

const withMDX = createMDX();

const isDev = process.env.NODE_ENV === 'development';

// Production CSP — no unsafe-eval (not needed by Next.js in production).
// 'unsafe-inline' in script-src is retained because next-themes injects an inline
// script for theme initialisation; remove it only after adopting CSP nonces.
// img-src is scoped to known domains instead of the broad 'https:' wildcard.
const cspProduction = `
  default-src 'self';
  script-src 'self' 'unsafe-inline' https://va.vercel-scripts.com;
  style-src 'self' 'unsafe-inline';
  img-src 'self' blob: data: https://github.com https://raw.githubusercontent.com https://avatars.githubusercontent.com https://opengraph.githubassets.com;
  font-src 'self' data:;
  connect-src 'self' https://vitals.vercel-insights.com https://api.github.com;
  frame-src 'self';
  object-src 'none';
  base-uri 'self';
  form-action 'self';
  frame-ancestors 'self';
  upgrade-insecure-requests;
`;

// Development CSP — looser to allow Turbopack HMR (needs unsafe-eval)
// and React DevTools while still applying a baseline policy.
const cspDevelopment = `
  default-src 'self';
  script-src 'self' 'unsafe-eval' 'unsafe-inline';
  style-src 'self' 'unsafe-inline';
  img-src 'self' blob: data: https:;
  font-src 'self' data:;
  connect-src 'self' ws: wss: https://api.github.com;
  frame-src 'self';
  object-src 'none';
  base-uri 'self';
  form-action 'self';
`;

const defaultLocale = 'en';
const _supportedLocales = ['en', 'id'];

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
  turbopack: {
    root: path.resolve(process.cwd(), '../../'),
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
  async headers() {
    const csp = (isDev ? cspDevelopment : cspProduction)
      .replace(/\n/g, ' ')
      .replace(/\s{2,}/g, ' ')
      .trim();

    // Baseline headers applied in both dev and prod so developers always
    // experience the same security posture.
    const baselineHeaders = [
      { key: 'Content-Security-Policy', value: csp },
      { key: 'X-Content-Type-Options', value: 'nosniff' },
      { key: 'X-Frame-Options', value: 'SAMEORIGIN' },
      { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
    ];

    // Production-only hardening headers (not useful / can interfere in dev).
    const productionHeaders = isDev
      ? []
      : [
          { key: 'X-DNS-Prefetch-Control', value: 'on' },
          {
            key: 'Permissions-Policy',
            value:
              'geolocation=(), microphone=(), camera=(), payment=(), usb=(), accelerometer=(), gyroscope=(), magnetometer=()',
          },
          { key: 'Cross-Origin-Embedder-Policy', value: 'credentialless' },
          { key: 'Cross-Origin-Opener-Policy', value: 'same-origin' },
          { key: 'Cross-Origin-Resource-Policy', value: 'same-origin' },
          { key: 'X-Permitted-Cross-Domain-Policies', value: 'none' },
          {
            key: 'Strict-Transport-Security',
            value: 'max-age=31536000; includeSubDomains; preload',
          },
        ];

    return [
      {
        source: '/(.*)',
        headers: [...baselineHeaders, ...productionHeaders],
      },
      {
        // Long-lived cache for immutable static assets.
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
};

export default withMDX(withBundleAnalyzer(nextConfig));
