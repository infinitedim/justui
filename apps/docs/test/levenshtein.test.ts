import { describe, expect, it } from 'vitest';
import {
  levenshteinDistance,
  findClosestMatch,
  REGISTRY_COMPONENT_NAMES,
} from '@/components/organisms/interactive-terminal/levenshtein';

describe('levenshtein', () => {
  it('calculates exact match distance as 0', () => {
    expect(levenshteinDistance('button', 'button')).toBe(0);
    expect(levenshteinDistance('', '')).toBe(0);
  });

  it('calculates single deletion/insertion distance as 1', () => {
    expect(levenshteinDistance('buton', 'button')).toBe(1);
    expect(levenshteinDistance('switc', 'switch')).toBe(1);
    expect(levenshteinDistance('butto', 'button')).toBe(1);
  });

  it('calculates single substitution distance as 1', () => {
    expect(levenshteinDistance('batton', 'button')).toBe(1);
  });

  it('handles empty string boundaries', () => {
    expect(levenshteinDistance('', 'button')).toBe(6);
    expect(levenshteinDistance('button', '')).toBe(6);
  });

  it('finds closest match in registry component names', () => {
    const match = findClosestMatch('buton', REGISTRY_COMPONENT_NAMES);
    expect(match).toEqual({ match: 'button', distance: 1 });

    const switchMatch = findClosestMatch('switc', REGISTRY_COMPONENT_NAMES);
    expect(switchMatch).toEqual({ match: 'switch', distance: 1 });
  });

  it('returns null when all candidates exceed maxDistance', () => {
    const match = findClosestMatch('xyzzy', REGISTRY_COMPONENT_NAMES, 2);
    expect(match).toBeNull();
  });

  it('returns null for empty or whitespace-only input', () => {
    expect(findClosestMatch('', ['add', 'button'])).toBeNull();
    expect(findClosestMatch('   ', ['add', 'button'])).toBeNull();
  });
});
