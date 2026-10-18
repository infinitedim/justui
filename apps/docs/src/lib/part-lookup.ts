import { PART_SLUGS } from '@/lib/parts';

/** Parts shown when the 404 has no query to rank against. */
export const DEFAULT_NEAREST_PARTS: readonly string[] = [
  'button',
  'card',
  'input',
];

/** Distance at or below which a missed lookup gets a "did you mean". */
const NEAR_MISS_DISTANCE = 2;

/** Levenshtein edit distance between two strings, one row of memory. */
export function levenshteinDistance(a: string, b: string): number {
  if (a === b) return 0;
  if (a.length === 0) return b.length;
  if (b.length === 0) return a.length;

  const s1 = a.length >= b.length ? a : b;
  const s2 = a.length >= b.length ? b : a;
  const row = new Uint16Array(s2.length + 1);
  for (let j = 0; j <= s2.length; j++) row[j] = j;

  for (let i = 1; i <= s1.length; i++) {
    let prevDiagonal = row[0] ?? 0;
    row[0] = i;
    for (let j = 1; j <= s2.length; j++) {
      const temp = row[j] ?? 0;
      const cost = s1.charCodeAt(i - 1) === s2.charCodeAt(j - 1) ? 0 : 1;
      row[j] = Math.min(
        (row[j - 1] ?? 0) + 1,
        (row[j] ?? 0) + 1,
        prevDiagonal + cost
      );
      prevDiagonal = temp;
    }
  }
  return row[s2.length] ?? 0;
}

/**
 * Turns a requested URL or typed text into a part-name query: drops the
 * origin and the locale prefix, keeps the last path segment, lowercases it
 * and maps `_` and spaces to `-` (`/en/date_picker` -> `date-picker`).
 */
export function normalizePartQuery(input: string): string {
  const withoutOrigin = input.trim().replace(/^https?:\/\/[^/]+/i, '');
  const withoutLocale = withoutOrigin.replace(/^\/(en|id)(?=\/|$)/i, '');
  const segment =
    withoutLocale
      .replace(/^\/+|\/+$/g, '')
      .split('/')
      .pop() ?? '';
  return segment.toLowerCase().replace(/[_\s]+/g, '-');
}

/**
 * The `count` parts closest to `query`. A prefix match scores 2 better and
 * a substring match 1 better than the plain edit distance; ties keep the
 * registry order. An empty query returns the default parts.
 */
export function nearestParts(query: string, count = 3): readonly string[] {
  if (query.length === 0) return DEFAULT_NEAREST_PARTS.slice(0, count);
  return PART_SLUGS.map((slug, index) => ({
    slug,
    index,
    score:
      levenshteinDistance(query, slug) -
      (slug.startsWith(query) ? 2 : 0) -
      (slug.includes(query) ? 1 : 0),
  }))
    .toSorted((a, b) => a.score - b.score || a.index - b.index)
    .slice(0, count)
    .map((item) => item.slug);
}

export type PartLookup =
  | { readonly kind: 'empty' }
  | { readonly kind: 'exact'; readonly slug: string }
  | { readonly kind: 'near'; readonly best: string }
  | { readonly kind: 'none' };

/** Classifies a normalized query for the 404 lookup feedback. */
export function classifyPartLookup(query: string): PartLookup {
  if (query.length === 0) return { kind: 'empty' };
  if (PART_SLUGS.includes(query)) return { kind: 'exact', slug: query };
  const best = nearestParts(query, 1)[0];
  if (
    best !== undefined &&
    levenshteinDistance(query, best) <= NEAR_MISS_DISTANCE
  ) {
    return { kind: 'near', best };
  }
  return { kind: 'none' };
}
