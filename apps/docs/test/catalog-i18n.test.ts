import { describe, expect, it } from 'vitest';
import { GENERATED_COMPONENTS } from '@/lib/components.generated';
import { catalogDictionaries, getCatalogDictionary } from '@/lib/catalog-i18n';

/** Collects the keys of an object tree, so en and id can be compared shape to shape. */
function keyPaths(value: unknown, prefix = ''): string[] {
  if (value === null || typeof value !== 'object' || Array.isArray(value)) {
    return [prefix];
  }
  return Object.entries(value as Record<string, unknown>).flatMap(
    ([key, child]) => keyPaths(child, prefix ? `${prefix}.${key}` : key)
  );
}

const BANNED_WORDS =
  /\b(versatile|seamless|smooth|elevate|dynamic|premium|powerful|production-ready)\b/i;

describe('catalog i18n', () => {
  const { en, id } = catalogDictionaries;

  it('has the same shape in English and Indonesian', () => {
    expect(keyPaths(id).sort()).toEqual(keyPaths(en).sort());
  });

  it('keeps list lengths equal across locales', () => {
    expect(id.crm.accordion.items).toHaveLength(en.crm.accordion.items.length);
    expect(id.crm.scrollArea.items).toHaveLength(
      en.crm.scrollArea.items.length
    );
    expect(id.crm.carousel.slides).toHaveLength(en.crm.carousel.slides.length);
    expect(id.crm.tabs.items.map((t) => t.id)).toEqual(
      en.crm.tabs.items.map((t) => t.id)
    );
  });

  it.each(['en', 'id'] as const)(
    'describes every registry component in %s',
    (lang) => {
      const { descriptions } = catalogDictionaries[lang];
      for (const component of GENERATED_COMPONENTS) {
        expect(descriptions[component.slug], component.slug).toBeTruthy();
      }
      expect(Object.keys(descriptions).sort()).toEqual(
        GENERATED_COMPONENTS.map((c) => c.slug).sort()
      );
    }
  );

  it.each(['en', 'id'] as const)(
    'writes %s descriptions as one plain sentence',
    (lang) => {
      for (const [slug, text] of Object.entries(
        catalogDictionaries[lang].descriptions
      )) {
        expect(text.length, slug).toBeLessThanOrEqual(120);
        expect(text.endsWith('.'), slug).toBe(true);
        // One sentence: no full stop followed by a new sentence.
        expect(/\.\s+[A-Z]/.test(text), slug).toBe(false);
        expect(BANNED_WORDS.test(text), slug).toBe(false);
      }
    }
  );

  it('falls back to English for unknown locales', () => {
    expect(getCatalogDictionary('cn')).toBe(en);
    expect(getCatalogDictionary('id')).toBe(id);
  });

  it('formats counts and queries without string concatenation in components', () => {
    expect(en.ui.resultCount(3, 33)).toBe('3 of 33');
    expect(id.ui.resultCount(3, 33)).toBe('3 dari 33');
    expect(en.ui.noResults('xyz')).toBe('Nothing matches "xyz".');
    expect(en.crm.button.logged(1)).toBe('1 call logged today');
    expect(en.crm.button.logged(2)).toBe('2 calls logged today');
  });
});
