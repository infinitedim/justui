import { describe, expect, it } from 'vitest';
import {
  PART_COUNT,
  PART_SLUGS,
  partCode,
  partDir,
  partFiles,
  partMainFile,
  partSharedDeps,
} from '@/lib/parts';
import {
  classifyPartLookup,
  levenshteinDistance,
  nearestParts,
  normalizePartQuery,
} from '@/lib/part-lookup';

describe('parts', () => {
  it('lists the 33 public registry parts in alphabetical order', () => {
    expect(PART_COUNT).toBe(33);
    expect(PART_SLUGS[0]).toBe('accordion');
    expect(PART_SLUGS.at(-1)).toBe('tooltip');
    expect([...PART_SLUGS]).toEqual([...PART_SLUGS].toSorted());
    expect(PART_SLUGS.some((slug) => slug.startsWith('_'))).toBe(false);
  });

  it('numbers parts by alphabetical position', () => {
    expect(partCode('accordion')).toBe('01');
    expect(partCode('button')).toBe('07');
    expect(partCode('tooltip')).toBe('33');
    expect(partCode('shared')).toBe('--');
  });

  it('derives the files `justui add button` writes', () => {
    expect(partMainFile('date-picker')).toBe('just_date_picker.dart');
    expect(partDir('button')).toBe('lib/widgets/button');
    expect(partFiles('button')).toEqual([
      'just_button.dart',
      'just_button_style.dart',
      'just_button_theme.dart',
      'just_button_variants.dart',
      'just_icon_button.dart',
    ]);
    expect(partSharedDeps('button')).toEqual([
      '_shared_pressable',
      '_shared_focus_indicator',
      '_shared_progress_spinner',
    ]);
    expect(partFiles('button').length + partSharedDeps('button').length).toBe(
      8
    );
    expect(partFiles('missing')).toEqual([]);
  });
});

describe('part lookup', () => {
  it('measures edit distance', () => {
    expect(levenshteinDistance('buton', 'button')).toBe(1);
    expect(levenshteinDistance('', 'abc')).toBe(3);
    expect(levenshteinDistance('same', 'same')).toBe(0);
  });

  it('normalizes requested paths and typed text', () => {
    expect(normalizePartQuery('/en/buton')).toBe('buton');
    expect(normalizePartQuery('/id/docs/date_picker/')).toBe('date-picker');
    expect(normalizePartQuery('https://justui.vercel.app/en')).toBe('');
    expect(normalizePartQuery('  Time Picker ')).toBe('time-picker');
  });

  // Expected values come from running the `nearest()` reference in the
  // design handoff (Not Found.dc.html) on the same inputs.
  it.each([
    ['buton', ['button', 'badge', 'avatar']],
    ['dialg', ['dialog', 'badge', 'card']],
    ['date', ['badge', 'card', 'table']],
    ['radi', ['radio', 'badge', 'card']],
    ['zzz', ['card', 'tabs', 'badge']],
    ['', ['button', 'card', 'input']],
  ])('ranks %j like the handoff reference', (query, expected) => {
    expect(nearestParts(query)).toEqual(expected);
  });

  it('limits the result to the requested count', () => {
    expect(nearestParts('xyz', 2)).toHaveLength(2);
  });

  it('classifies lookups as exact, near or none', () => {
    expect(classifyPartLookup('')).toEqual({ kind: 'empty' });
    expect(classifyPartLookup('button')).toEqual({
      kind: 'exact',
      slug: 'button',
    });
    expect(classifyPartLookup('buton')).toEqual({
      kind: 'near',
      best: 'button',
    });
    expect(classifyPartLookup('zzz')).toEqual({ kind: 'none' });
  });
});
