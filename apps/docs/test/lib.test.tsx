import { describe, expect, it, vi, beforeEach, afterEach } from 'vitest';

import { fetchStarCount, githubUrl } from '@/lib/github';
import {
  i18n,
  isLocale,
  localeStaticParams,
  localizedHref,
  locales,
  switchLocalePath,
} from '@/lib/i18n';
import { source } from '@/lib/source';
import { translations, baseOptions } from '@/lib/layout.shared';
import { ok, err, unwrapOr, mapResult } from '@/lib/result';
import {
  isPreset,
  parsePresetAlias,
  PRESETS,
  DEFAULT_PRESET,
  PRESET_OPTIONS,
} from '@/lib/presets';
import { justuiLight, justuiDark } from '@/lib/justui-shiki-theme';

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

    it('exposes a single locale source for routing helpers', () => {
      expect(locales).toEqual(['en', 'id']);
      expect(i18n.languages).toEqual([...locales]);
      expect(localeStaticParams()).toEqual([{ lang: 'en' }, { lang: 'id' }]);
      expect(isLocale('id')).toBe(true);
      expect(isLocale('fr')).toBe(false);
      expect(isLocale('robots.txt')).toBe(false);
    });

    it('builds and swaps locale-prefixed routes', () => {
      expect(localizedHref('id', '/docs/theming')).toBe('/id/docs/theming');
      expect(localizedHref('en', '')).toBe('/en');
      expect(switchLocalePath('/en/docs/guides/migration', 'id')).toBe(
        '/id/docs/guides/migration'
      );
      expect(switchLocalePath('/id', 'en')).toBe('/en');
      expect(switchLocalePath('/', 'id')).toBe('/id');
      expect(switchLocalePath('/english-page', 'id')).toBe('/id');
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

    it('localizes nav link labels instead of hardcoding English', () => {
      const linkText = (options: ReturnType<typeof baseOptions>) =>
        options.links?.map((l) => (l as { text: string }).text);

      expect(linkText(baseOptions('en'))).toEqual(['Docs', 'Components']);
      expect(linkText(baseOptions('id'))).toEqual(['Dokumentasi', 'Komponen']);
    });

    it('points the Components link at the landing parts index', () => {
      const urls = baseOptions('id').links?.map(
        (l) => (l as { url: string }).url
      );
      expect(urls).toEqual(['/id/docs/introduction', '/id#parts']);
    });
  });

  describe('result.ts', () => {
    it('creates and unwraps ok results', () => {
      const success = ok(123);
      expect(success.ok).toBe(true);
      if (success.ok) {
        expect(success.value).toBe(123);
      }
      expect(unwrapOr(success, 0)).toBe(123);
    });

    it('creates and unwraps err results', () => {
      const failure = err('something failed');
      expect(failure.ok).toBe(false);
      if (!failure.ok) {
        expect(failure.error).toBe('something failed');
      }
      expect(unwrapOr(failure, 999)).toBe(999);
    });

    it('maps successful results correctly', () => {
      const success = ok(10);
      const mappedSuccess = mapResult(success, (n) => n * 2);
      expect(unwrapOr(mappedSuccess, 0)).toBe(20);

      const failure = err('fail');
      const mappedFailure = mapResult(failure, (n: number) => n * 2);
      expect(mappedFailure.ok).toBe(false);
      expect(unwrapOr(mappedFailure, -1)).toBe(-1);
    });
  });

  describe('presets.ts', () => {
    it('validates preset values', () => {
      expect(PRESETS).toEqual(['default', 'neobrutalism']);
      expect(DEFAULT_PRESET).toBe('default');
      expect(isPreset('default')).toBe(true);
      expect(isPreset('neobrutalism')).toBe(true);
      expect(isPreset('invalid')).toBe(false);
      expect(isPreset(123)).toBe(false);
      expect(isPreset(null)).toBe(false);
    });

    it('parses preset aliases', () => {
      expect(parsePresetAlias('d')).toBe('default');
      expect(parsePresetAlias('default')).toBe('default');
      expect(parsePresetAlias('neo')).toBe('neobrutalism');
      expect(parsePresetAlias('neobrutalism')).toBe('neobrutalism');
      expect(parsePresetAlias('UNKNOWN')).toBeUndefined();
      expect(parsePresetAlias(undefined)).toBeUndefined();
    });

    it('provides preset options', () => {
      expect(PRESET_OPTIONS).toHaveLength(2);
      expect(PRESET_OPTIONS[0]?.value).toBe('default');
      expect(PRESET_OPTIONS[1]?.value).toBe('neobrutalism');
    });
  });

  describe('justui-shiki-theme.ts', () => {
    it('exports shiki themes matching token styles', () => {
      expect(justuiLight.name).toBe('justui-light');
      expect(justuiLight.type).toBe('light');
      expect(justuiLight.settings.length).toBeGreaterThan(0);
      expect(justuiDark.name).toBe('justui-dark');
      expect(justuiDark.type).toBe('dark');
      expect(justuiDark.settings.length).toBeGreaterThan(0);
    });
  });
});
