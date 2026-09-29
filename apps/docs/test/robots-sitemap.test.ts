import { describe, expect, it, vi, beforeEach } from 'vitest';
import robots from '@/app/robots';
import sitemap from '@/app/sitemap';
import { source } from '@/lib/source';

describe('robots metadata route', () => {
  it('returns valid robots config with sitemap', () => {
    const res = robots();
    expect(res.rules).toEqual({ userAgent: '*', allow: '/' });
    expect(res.sitemap).toBe('https://justui.vercel.app/sitemap.xml');
  });
});

describe('sitemap metadata route', () => {
  beforeEach(() => {
    vi.restoreAllMocks();
  });

  it('includes static locale pages and fumadocs documentation pages', () => {
    vi.spyOn(source, 'getPages').mockReturnValue([
      {
        locale: 'en',
        url: '/en/docs/introduction',
        slugs: ['introduction'],
        data: {} as never,
      },
      {
        locale: 'id',
        url: '/id/docs/components/button',
        slugs: ['components', 'button'],
        data: {} as never,
      },
    ] as never);

    const entries = sitemap();
    expect(Array.isArray(entries)).toBe(true);

    const urls = entries.map((e) => e.url);

    // Static pages
    expect(urls).toContain('https://justui.vercel.app/en');
    expect(urls).toContain('https://justui.vercel.app/id');
    expect(urls).toContain('https://justui.vercel.app/en/components');
    expect(urls).toContain('https://justui.vercel.app/id/components');
    expect(urls).toContain('https://justui.vercel.app/en/studio');
    expect(urls).toContain('https://justui.vercel.app/id/studio');

    // Should also include documentation pages
    const hasDocPages = urls.some((u) => u.includes('/docs/'));
    expect(hasDocPages).toBe(true);

    // Each entry must have lastModified and changeFrequency
    for (const entry of entries) {
      expect(entry.url).toMatch(/^https:\/\/justui\.vercel\.app\//);
      expect(entry.lastModified).toBeInstanceOf(Date);
      expect(entry.changeFrequency).toBeDefined();
    }
  });
});
