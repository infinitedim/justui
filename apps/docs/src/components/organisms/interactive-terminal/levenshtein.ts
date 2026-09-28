import { GENERATED_COMPONENTS } from '@/lib/components.generated';

export const REGISTRY_COMPONENT_NAMES: readonly string[] =
  GENERATED_COMPONENTS.map((c) => c.slug);

export function levenshteinDistance(a: string, b: string): number {
  if (a === b) return 0;
  if (a.length === 0) return b.length;
  if (b.length === 0) return a.length;

  const s1 = a.length >= b.length ? a : b;
  const s2 = a.length >= b.length ? b : a;

  const m = s1.length;
  const n = s2.length;

  const row = new Uint16Array(n + 1);
  for (let j = 0; j <= n; j++) {
    row[j] = j;
  }

  for (let i = 1; i <= m; i++) {
    let prevDiagonal = row[0];
    row[0] = i;
    for (let j = 1; j <= n; j++) {
      const temp = row[j];
      const cost = s1.charCodeAt(i - 1) === s2.charCodeAt(j - 1) ? 0 : 1;
      const insertion = row[j - 1] + 1;
      const deletion = row[j] + 1;
      const substitution = prevDiagonal + cost;
      row[j] = Math.min(insertion, deletion, substitution);
      prevDiagonal = temp;
    }
  }

  return row[n];
}

export function findClosestMatch(
  input: string,
  candidates: readonly string[],
  maxDistance = 3
): { match: string; distance: number } | null {
  const normalized = input.trim().toLowerCase();
  if (normalized.length === 0) {
    return null;
  }
  let bestMatch: string | null = null;
  let minDistance = Number.POSITIVE_INFINITY;

  for (const candidate of candidates) {
    const dist = levenshteinDistance(normalized, candidate.toLowerCase());
    if (dist < minDistance) {
      minDistance = dist;
      bestMatch = candidate;
    }
  }

  if (bestMatch !== null && minDistance <= maxDistance) {
    return { match: bestMatch, distance: minDistance };
  }

  return null;
}
