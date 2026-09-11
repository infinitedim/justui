import { describe, expect, it } from 'vitest';
import {
  MU,
  SIGMA,
  MIN_DELAY,
  getKeystrokeDelay,
  shouldSimulateTypo,
  getAdjacentKey,
  QWERTY_ADJACENCY,
} from '@/components/organisms/interactive-terminal/keystroke-engine';

describe('keystroke-engine', () => {
  it('generates Box-Muller delays within expected bounds', () => {
    let sum = 0;
    const samples = 1000;

    for (let i = 0; i < samples; i++) {
      const delay = getKeystrokeDelay('a', 'b');
      expect(delay).toBeGreaterThanOrEqual(MIN_DELAY);
      sum += delay;
    }

    const mean = sum / samples;
    expect(mean).toBeGreaterThan(MU - 2 * SIGMA);
    expect(mean).toBeLessThan(MU + 2 * SIGMA);
  });

  it('applies punctuation multiplier for spaces and hyphens', () => {
    let letterSum = 0;
    let punctSum = 0;
    const samples = 1000;

    for (let i = 0; i < samples; i++) {
      letterSum += getKeystrokeDelay('a', 'b');
      punctSum += getKeystrokeDelay(' ', 'b');
    }

    const letterMean = letterSum / samples;
    const punctMean = punctSum / samples;
    expect(punctMean).toBeGreaterThan(letterMean);
  });

  it('applies pause multiplier after word boundary', () => {
    let normalSum = 0;
    let afterSpaceSum = 0;
    const samples = 1000;

    for (let i = 0; i < samples; i++) {
      normalSum += getKeystrokeDelay('b', 'a');
      afterSpaceSum += getKeystrokeDelay('b', ' ');
    }

    const normalMean = normalSum / samples;
    const afterSpaceMean = afterSpaceSum / samples;
    expect(afterSpaceMean).toBeGreaterThan(normalMean);
  });

  it('returns valid adjacent keys for character lookup', () => {
    const adjacentA = QWERTY_ADJACENCY['a'];
    for (let i = 0; i < 50; i++) {
      const key = getAdjacentKey('a');
      expect(adjacentA).toContain(key);
    }
  });

  it('simulates typo with roughly 3% probability', () => {
    let typos = 0;
    const samples = 10000;

    for (let i = 0; i < samples; i++) {
      if (shouldSimulateTypo()) {
        typos++;
      }
    }

    const rate = typos / samples;
    expect(rate).toBeGreaterThan(0.01);
    expect(rate).toBeLessThan(0.06);
  });
});
