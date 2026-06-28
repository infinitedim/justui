import { describe, expect, it, vi, beforeEach, afterEach } from 'vitest';

import { fetchStarCount, githubUrl } from '@/lib/github';
import { i18n } from '@/lib/i18n';
import { source } from '@/lib/source';
import { translations, baseOptions } from '@/lib/layout.shared';

describe('Library Helpers', () => {
  describe('github.ts', () => {
    const originalFetch = global.fetch;

    beforeEach(() => {
      vi.stubEnv('GITHUB_TOKEN', 'test-token');
    });

    afterEach(() => {
      global.fetch = originalFetch;
      vi.unstubAllEnvs();
    });

    it('fetches star count successfully with GITHUB_TOKEN', async () => {
      global.fetch = vi.fn().mockResolvedValue({
        ok: true,
        json: async () => ({ stargazers_count: 42 }),
      });

      const stars = await fetchStarCount();
      expect(stars).toBe(42);
      expect(global.fetch).toHaveBeenCalledWith(
        'https://api.github.com/repos/infinitedim/justui',
        expect.objectContaining({
          headers: expect.objectContaining({
            Authorization: 'Bearer test-token',
          }),
        })
      );
    });

    it('returns null on fetch error or non-ok response', async () => {
      global.fetch = vi.fn().mockResolvedValue({
        ok: false,
      });

      let stars = await fetchStarCount();
      expect(stars).toBeNull();

      global.fetch = vi.fn().mockRejectedValue(new Error('Network error'));
      stars = await fetchStarCount();
      expect(stars).toBeNull();
    });

    it('exports the correct githubUrl', () => {
      expect(githubUrl).toBe('https://github.com/infinitedim/justui');
    });
  });

  describe('i18n.ts', () => {
    it('defines i18n object correctly', () => {
      expect(i18n.languages).toContain('en');
      expect(i18n.languages).toContain('id');
    });
  });

  describe('source.ts', () => {
    it('defines source loader correctly', () => {
      expect(source.getPage).toBeTypeOf('function');
      expect(source.pageTree).toBeDefined();
    });
  });

  describe('layout.shared.tsx', () => {
    it('exports translations and extends uiTranslations', () => {
      expect(translations).toBeDefined();
    });

    it('returns correct baseOptions configuration', () => {
      const options = baseOptions('en');
      expect(options.githubUrl).toBe('https://github.com/infinitedim/justui');
      expect(options.i18n).toBe(true);
      expect(options.nav?.url).toBe('/en');
    });
  });
});
