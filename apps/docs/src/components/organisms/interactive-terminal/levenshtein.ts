import { GENERATED_COMPONENTS } from '@/lib/components.generated';
import { levenshteinDistance } from '@/lib/part-lookup';

export { levenshteinDistance };

export const REGISTRY_COMPONENT_NAMES: readonly string[] =
  GENERATED_COMPONENTS.map((c) => c.slug);

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
