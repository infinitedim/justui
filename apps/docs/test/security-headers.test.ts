import { describe, expect, it, beforeEach, vi } from 'vitest';
import { readFileSync } from 'node:fs';
import path from 'node:path';

vi.mock('fumadocs-core/search/server', () => ({
  createFromSource: () => ({
    GET: async (_req: unknown) =>
      Response.json([{ title: 'Button', url: '/docs/components/button' }]),
  }),
}));

import nextConfig from '../next.config';
import {
  GET as searchGet,
  _resetRateLimitsForTesting,
} from '@/app/api/search/route';
import type { NextRequest } from 'next/server';

function createSearchRequest(
  urlStr: string,
  headers?: Record<string, string>
): NextRequest {
  const url = new URL(urlStr);
  const req = new Request(urlStr, {
    headers: headers ? new Headers(headers) : undefined,
  });
  (req as unknown as { nextUrl: URL }).nextUrl = url;
  return req as unknown as NextRequest;
}

describe('security headers and CSP baseline', () => {
  it('locks all required production security headers and CSP directives', async () => {
    const resolvedConfig =
      typeof nextConfig === 'function'
        ? await (
            nextConfig as (
              phase: string,
              context: { defaultConfig: unknown }
            ) => Promise<{ headers?: () => Promise<Array<unknown>> }>
          )('phase-production-build', { defaultConfig: {} })
        : nextConfig;

    expect(resolvedConfig).toBeDefined();
    expect(typeof resolvedConfig.headers).toBe('function');

    const headersList = (await resolvedConfig.headers!()) as Array<{
      source: string;
      headers: Array<{ key: string; value: string }>;
    }>;

    const rootRule = headersList.find((entry) => entry.source === '/(.*)');
    expect(rootRule).toBeDefined();

    const headerMap = new Map<string, string>();
    for (const item of rootRule!.headers) {
      headerMap.set(item.key, item.value);
    }

    // Required security headers
    expect(headerMap.get('X-Content-Type-Options')).toBe('nosniff');
    expect(headerMap.get('X-Frame-Options')).toBe('SAMEORIGIN');
    expect(headerMap.get('Referrer-Policy')).toBe(
      'strict-origin-when-cross-origin'
    );
    expect(headerMap.get('Permissions-Policy')).toBe(
      'geolocation=(), microphone=(), camera=(), payment=(), usb=(), accelerometer=(), gyroscope=(), magnetometer=()'
    );
    expect(headerMap.get('Cross-Origin-Embedder-Policy')).toBe(
      'credentialless'
    );
    expect(headerMap.get('Cross-Origin-Opener-Policy')).toBe('same-origin');
    expect(headerMap.get('Cross-Origin-Resource-Policy')).toBe('same-origin');
    expect(headerMap.get('X-Permitted-Cross-Domain-Policies')).toBe('none');
    expect(headerMap.get('Strict-Transport-Security')).toBe(
      'max-age=31536000; includeSubDomains; preload'
    );

    // CSP directive validation
    const csp = headerMap.get('Content-Security-Policy');
    expect(csp).toBeDefined();

    const directives = new Map<string, Array<string>>();
    for (const rawDirective of csp!.split(';')) {
      const trimmed = rawDirective.trim();
      if (!trimmed) {
        continue;
      }
      const parts = trimmed.split(/\s+/);
      const name = parts[0]!;
      directives.set(name, parts.slice(1));
    }

    expect(directives.get('default-src')).toEqual(["'self'"]);
    expect(directives.get('object-src')).toEqual(["'none'"]);
    expect(directives.get('base-uri')).toEqual(["'self'"]);
    expect(directives.get('form-action')).toEqual(["'self'"]);
    expect(directives.get('frame-ancestors')).toEqual(["'self'"]);
    expect(directives.get('frame-src')).toEqual(["'self'"]);

    const scriptSrc = directives.get('script-src') ?? [];
    expect(scriptSrc).toContain("'self'");
    expect(scriptSrc).toContain("'unsafe-inline'");
    expect(scriptSrc).toContain("'wasm-unsafe-eval'");
    expect(scriptSrc).toContain('https://va.vercel-scripts.com');
    expect(scriptSrc).not.toContain("'unsafe-eval'");

    const styleSrc = directives.get('style-src') ?? [];
    expect(styleSrc).toContain("'self'");
    expect(styleSrc).toContain("'unsafe-inline'");
    expect(styleSrc).not.toContain("'unsafe-eval'");

    const imgSrc = directives.get('img-src') ?? [];
    expect(imgSrc).toContain("'self'");
    expect(imgSrc).toContain('blob:');
    expect(imgSrc).toContain('data:');
    expect(imgSrc).toContain('https://github.com');
    expect(imgSrc).toContain('https://raw.githubusercontent.com');
    expect(imgSrc).toContain('https://avatars.githubusercontent.com');
    expect(imgSrc).toContain('https://opengraph.githubassets.com');
    expect(imgSrc).not.toContain('https:');

    const fontSrc = directives.get('font-src') ?? [];
    expect(fontSrc).toContain("'self'");
    expect(fontSrc).toContain('data:');

    const connectSrc = directives.get('connect-src') ?? [];
    expect(connectSrc).toContain("'self'");
    expect(connectSrc).toContain('https://vitals.vercel-insights.com');
    expect(connectSrc).toContain('https://api.github.com');
    expect(connectSrc).toContain('https://raw.githubusercontent.com');
  });
});

describe('security.txt RFC 9116 validation', () => {
  it('validates syntax and asserts expiration is at least 30 days away', () => {
    const securityTxtPath = path.resolve(
      __dirname,
      '../public/.well-known/security.txt'
    );
    const content = readFileSync(securityTxtPath, 'utf-8');

    // Ascii purity check
    const isAscii = Buffer.from(content).every((byte) => byte <= 127);
    expect(isAscii).toBe(true);

    const lines = content.split('\n').map((l) => l.trim()).filter(Boolean);
    const fields = new Map<string, string>();
    for (const line of lines) {
      const colonIndex = line.indexOf(':');
      expect(colonIndex).toBeGreaterThan(0);
      const key = line.slice(0, colonIndex).trim();
      const val = line.slice(colonIndex + 1).trim();
      fields.set(key, val);
    }

    const contact = fields.get('Contact');
    expect(contact).toBeDefined();
    expect(
      contact!.startsWith(
        'https://github.com/infinitedim/justui/security/advisories/new'
      )
    ).toBe(true);

    const expiresStr = fields.get('Expires');
    expect(expiresStr).toBeDefined();
    const expiresDate = new Date(expiresStr!);
    expect(Number.isNaN(expiresDate.getTime())).toBe(false);

    const thirtyDaysMs = 30 * 24 * 60 * 60 * 1000;
    const oneYearMs = 366 * 24 * 60 * 60 * 1000;
    const remainingMs = expiresDate.getTime() - Date.now();
    expect(remainingMs).toBeGreaterThan(thirtyDaysMs);
    expect(remainingMs).toBeLessThanOrEqual(oneYearMs);

    expect(fields.get('Preferred-Languages')).toBe('en, id');
    expect(fields.get('Canonical')).toBe(
      'https://justui.vercel.app/.well-known/security.txt'
    );
    expect(fields.get('Policy')).toBe(
      'https://github.com/infinitedim/justui/blob/main/SECURITY.md'
    );
  });
});

describe('search API route security (/api/search)', () => {
  beforeEach(() => {
    _resetRateLimitsForTesting();
  });

  it('returns status 400 when query length exceeds 400 characters', async () => {
    const longQuery = 'a'.repeat(401);
    const req = createSearchRequest(
      `https://justui.vercel.app/api/search?query=${longQuery}`
    );
    const res = await searchGet(req);
    expect(res.status).toBe(400);
    expect(res.headers.get('Content-Type')).toContain('application/json');

    const data = (await res.json()) as { error: string };
    expect(data.error).toBe('Query length exceeds 400 characters');
  });

  it('returns status 200 and retains CDN cache headers for valid query', async () => {
    const req = createSearchRequest(
      'https://justui.vercel.app/api/search?query=button'
    );
    const res = await searchGet(req);
    expect(res.status).toBe(200);
    expect(res.headers.get('Content-Type')).toContain('application/json');
    expect(res.headers.get('Cache-Control')).toBe(
      'public, s-maxage=60, stale-while-revalidate=300'
    );
    expect(res.headers.get('X-Content-Type-Options')).toBe('nosniff');
  });

  it('triggers status 429 when rate limit threshold is exceeded', async () => {
    const testIp = '198.51.100.42';

    // 60 requests should pass
    for (let i = 0; i < 60; i++) {
      const req = createSearchRequest(
        'https://justui.vercel.app/api/search?query=button',
        { 'x-forwarded-for': testIp }
      );
      const res = await searchGet(req);
      expect(res.status).toBe(200);
    }

    // 61st request should be rate-limited
    const blockedReq = createSearchRequest(
      'https://justui.vercel.app/api/search?query=button',
      { 'x-forwarded-for': testIp }
    );
    const blockedRes = await searchGet(blockedReq);
    expect(blockedRes.status).toBe(429);
    expect(blockedRes.headers.get('Content-Type')).toContain('application/json');
    expect(blockedRes.headers.get('Retry-After')).toBeDefined();

    const retryAfter = Number(blockedRes.headers.get('Retry-After'));
    expect(retryAfter).toBeGreaterThan(0);
    expect(retryAfter).toBeLessThanOrEqual(60);

    const body = (await blockedRes.json()) as { error: string };
    expect(body.error).toBe('Too many requests');
  });

  it('allows requests again after rate limits are reset', async () => {
    const testIp = '198.51.100.99';

    for (let i = 0; i < 60; i++) {
      await searchGet(
        createSearchRequest(
          'https://justui.vercel.app/api/search?query=button',
          { 'x-forwarded-for': testIp }
        )
      );
    }

    const blockedRes = await searchGet(
      createSearchRequest(
        'https://justui.vercel.app/api/search?query=button',
        { 'x-forwarded-for': testIp }
      )
    );
    expect(blockedRes.status).toBe(429);

    _resetRateLimitsForTesting();

    const allowedRes = await searchGet(
      createSearchRequest(
        'https://justui.vercel.app/api/search?query=button',
        { 'x-forwarded-for': testIp }
      )
    );
    expect(allowedRes.status).toBe(200);
  });
});
