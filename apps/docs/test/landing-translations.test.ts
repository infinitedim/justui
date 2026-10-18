import { describe, expect, it } from 'vitest';
import { formatMessage } from '@/lib/format-message';
import { kitTranslations, getKitDictionary } from '@/lib/kit-translations';
import {
  landingTranslations,
  getLandingDictionary,
} from '@/lib/landing-translations';
import {
  notFoundTranslations,
  getNotFoundDictionary,
} from '@/lib/not-found-translations';
import { siteTranslations, getSiteDictionary } from '@/lib/site-translations';

const modules = {
  site: siteTranslations,
  landing: landingTranslations,
  notFound: notFoundTranslations,
  kit: kitTranslations,
};

function placeholders(value: unknown): Array<string> {
  return (
    JSON.stringify(value)
      .match(/\{\w+\}/g)
      ?.toSorted() ?? []
  );
}

describe('landing and 404 translations', () => {
  it.each(Object.entries(modules))(
    '%s has the same keys and placeholders in EN and ID',
    (_name, dict) => {
      expect(Object.keys(dict.id).toSorted()).toEqual(
        Object.keys(dict.en).toSorted()
      );
      for (const key of Object.keys(dict.en)) {
        const en: unknown = Reflect.get(dict.en, key);
        const id: unknown = Reflect.get(dict.id, key);
        expect(placeholders(id), key).toEqual(placeholders(en));
      }
    }
  );

  it('falls back to English for unknown locales', () => {
    expect(getSiteDictionary('fr')).toBe(siteTranslations.en);
    expect(getLandingDictionary('id')).toBe(landingTranslations.id);
    expect(getNotFoundDictionary('xx')).toBe(notFoundTranslations.en);
    expect(getKitDictionary('en')).toBe(kitTranslations.en);
  });

  it('fills count placeholders from data, not from the copy', () => {
    expect(
      formatMessage(landingTranslations.en.partsCount, { count: 33 })
    ).toBe('33 parts');
    expect(
      formatMessage(notFoundTranslations.id.lookupNear, {
        query: 'buton',
        best: 'button',
      })
    ).toBe('Tidak ada part bernama buton. Maksudnya button?');
  });
});
