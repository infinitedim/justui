import path from 'node:path';
import { createMDX } from 'fumadocs-mdx/next';
import type { NextConfig } from 'next';
import bundleAnalyzer from '@next/bundle-analyzer';

const withBundleAnalyzer = bundleAnalyzer({
  enabled: process.env.ANALYZE === 'true',
});

const withMDX = createMDX();

const isDev = process.env.NODE_ENV === 'development';

// Production CSP -- no unsafe-eval (not needed by Next.js in production).
// 'unsafe-inline' in script-src is retained because next-themes injects an inline
// script for theme initialisation; remove it only after adopting CSP nonces.
// img-src is scoped to known domains instead of the broad 'https:' wildcard.
const cspProduction = `
  default-src 'self';
  script-src 'self' 'unsafe-inline' 'wasm-unsafe-eval' https://va.vercel-scripts.com;
  style-src 'self' 'unsafe-inline';
  img-src 'self' blob: data: https://github.com https://raw.githubusercontent.com https://avatars.githubusercontent.com https://opengraph.githubassets.com;
  font-src 'self' data:;
  connect-src 'self' https://vitals.vercel-insights.com https://api.github.com https://raw.githubusercontent.com;
  frame-src 'self';
  object-src 'none';
  base-uri 'self';
  form-action 'self';
  frame-ancestors 'self';
  upgrade-insecure-requests;
`;

// Development CSP -- looser to allow Turbopack HMR (needs unsafe-eval)
// and React DevTools while still applying a baseline policy.
const cspDevelopment = `
  default-src 'self';
  script-src 'self' 'unsafe-eval' 'unsafe-inline' 'wasm-unsafe-eval';
  style-src 'self' 'unsafe-inline';
  img-src 'self' blob: data: https:;
  font-src 'self' data:;
  connect-src 'self' ws: wss: https://api.github.com https://raw.githubusercontent.com;
  frame-src 'self';
  object-src 'none';
  base-uri 'self';
  form-action 'self';
`;

const defaultLocale = 'en';

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
  redirects() {
    const redirects = [];

    // Redirect root path to default locale
    redirects.push({
      source: '/',
      destination: `/${defaultLocale}`,
      permanent: false,
    });

    // Redirect docs root to default locale docs introduction
    redirects.push({
      source: '/docs',
      destination: `/${defaultLocale}/docs/introduction`,
      permanent: false,
    });

    // Redirect all /docs/:path* without locale to default locale
    redirects.push({
      source: '/docs/:path*',
      destination: `/${defaultLocale}/docs/:path*`,
      permanent: false,
    });

    // The components catalog and the Theme Studio were removed. Old catalog
    // links land on the components page and the part docs, old Studio links
    // on the landing.
    redirects.push({
      source: '/components/:path*',
      destination: `/${defaultLocale}/docs/components/:path*`,
      permanent: false,
    });
    redirects.push({
      source: '/:lang(en|id)/components/:path*',
      destination: '/:lang/docs/components/:path*',
      permanent: false,
    });
    redirects.push({
      source: '/studio/:path*',
      destination: `/${defaultLocale}`,
      permanent: false,
    });
    redirects.push({
      source: '/:lang(en|id)/studio/:path*',
      destination: '/:lang',
      permanent: false,
    });

    return Promise.resolve(redirects);
  },
  // Proxy rewrites for locale handling
  rewrites() {
    return Promise.resolve({
      beforeFiles: [
        // Proxy non-locale prefixed paths to default locale
        // This ensures Fumadocs links with hidePrefix work correctly
      ],
    });
  },
  headers() {
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

    // Fingerprinted build output under /_next/static already gets
    // `immutable` caching from Next.js. Files in public/ keep stable names,
    // so they must not be cached as immutable.
    const headersList = [
      {
        source: '/(.*)',
        headers: [...baselineHeaders, ...productionHeaders],
      },
    ];

    return Promise.resolve(headersList);
  },
};

export default withMDX(withBundleAnalyzer(nextConfig));
