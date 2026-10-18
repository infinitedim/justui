import { describe, expect, it } from 'vitest';

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
import {
  isPreset,
  PRESETS,
  DEFAULT_PRESET,
  PRESET_OPTIONS,
} from '@/lib/presets';
import { justuiLight, justuiDark } from '@/lib/justui-shiki-theme';

describe('Library Helpers', () => {
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

    it('points the Components link at the components page', () => {
      const urls = baseOptions('id').links?.map(
        (l) => (l as { url: string }).url
      );
      expect(urls).toEqual(['/id/docs/introduction', '/id/docs/components']);
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
