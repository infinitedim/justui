import { describe, expect, it, vi, beforeEach, afterEach } from 'vitest';

import { fetchStarCount, githubUrl } from '@/lib/github';
import { i18n } from '@/lib/i18n';
import { source } from '@/lib/source';
import { translations, baseOptions } from '@/lib/layout.shared';
import {
  getDictionary,
  getHomepageDictionary,
  getStudioDictionary,
} from '@/lib/i18n/dictionaries';

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

  describe('dictionaries.ts', () => {
    it('aggregates English homepage and studio dictionaries', () => {
      const dict = getDictionary('en');
      expect(dict.heroTitle).toBe('Copy. Paste. Ship.');
      expect(dict.navStudio).toBe('Studio');
      expect(dict.title).toBe('Theme Studio');
      expect(dict.seedColor).toBe('Seed Color');
      expect(dict.resolvedPalette).toBe('Resolved Palette');
    });

    it('aggregates Indonesian homepage and studio dictionaries', () => {
      const dict = getDictionary('id');
      expect(dict.heroTitle).toBe('Salin. Tempel. Rilis.');
      expect(dict.navStudio).toBe('Studio');
      expect(dict.seedColor).toBe('Warna Dasar');
      expect(dict.resolvedPalette).toBe('Palet Hasil');
    });

    it('falls back to English when an unsupported language is requested', () => {
      const dict = getDictionary('de');
      expect(dict.heroTitle).toBe('Copy. Paste. Ship.');
      expect(dict.seedColor).toBe('Seed Color');
    });

    it('re-exports individual dictionary getters as functions', () => {
      expect(typeof getHomepageDictionary).toBe('function');
      expect(typeof getStudioDictionary).toBe('function');
      expect(getHomepageDictionary('en').tagline).toBe(
        'Copy-paste Flutter components'
      );
      expect(getStudioDictionary('en').preset).toBe('Preset');
    });
  });
});

