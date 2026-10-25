import { describe, expect, it } from 'vitest';
import { PART_GROUPS, isWidePart } from '@/lib/part-groups';
import { PART_SLUGS } from '@/lib/parts';

describe('part groups', () => {
  it('hold every part exactly once', () => {
    const grouped: Array<string> = PART_GROUPS.flatMap((group) => [
      ...group.slugs,
    ]);
    expect(new Set(grouped).size).toBe(grouped.length);
    expect([...grouped].sort()).toEqual([...PART_SLUGS].sort());
  });

  it('are the six v3 runners, lettered A to F', () => {
    expect(PART_GROUPS.map((group) => group.letter).join('')).toBe('ABCDEF');
  });

  it('mark only real parts as wide', () => {
    expect(isWidePart('date-picker')).toBe(true);
    expect(isWidePart('button')).toBe(false);
    expect(isWidePart('not-a-part')).toBe(false);
  });
});
