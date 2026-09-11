export const MU = 48;
export const SIGMA = 16;
export const MIN_DELAY = 12;
export const TYPO_PROBABILITY = 0.03;
export const PUNCTUATION_MULTIPLIER = 1.8;
export const PAUSE_MULTIPLIER = 2.5;

export const QWERTY_ADJACENCY: Record<string, readonly string[]> = {
  a: ['s', 'q', 'z', 'w'],
  b: ['v', 'n', 'g', 'h'],
  c: ['x', 'v', 'd', 'f'],
  d: ['s', 'f', 'e', 'c', 'x'],
  e: ['w', 'r', 'd', 's'],
  f: ['d', 'g', 'r', 't', 'v', 'c'],
  g: ['f', 'h', 't', 'y', 'b', 'v'],
  h: ['g', 'j', 'y', 'u', 'n', 'b'],
  i: ['u', 'o', 'k', 'j'],
  j: ['h', 'k', 'u', 'i', 'm', 'n'],
  k: ['j', 'l', 'i', 'o', 'm'],
  l: ['k', 'o', 'p'],
  m: ['n', 'k', 'j'],
  n: ['b', 'm', 'h', 'j'],
  o: ['i', 'p', 'k', 'l'],
  p: ['o', 'l'],
  q: ['w', 'a'],
  r: ['e', 't', 'f', 'd'],
  s: ['a', 'd', 'w', 'z', 'x'],
  t: ['r', 'y', 'g', 'f'],
  u: ['y', 'i', 'h', 'j'],
  v: ['c', 'b', 'f', 'g'],
  w: ['q', 'e', 's', 'a'],
  x: ['z', 'c', 's', 'd'],
  y: ['t', 'u', 'h', 'g'],
  z: ['a', 's', 'x'],
};

export function boxMullerGaussian(): number {
  let u1 = Math.random();
  while (u1 === 0) {
    u1 = Math.random();
  }
  const u2 = Math.random();
  return Math.sqrt(-2.0 * Math.log(u1)) * Math.cos(2.0 * Math.PI * u2);
}

export function getKeystrokeDelay(char: string, prevChar: string): number {
  let delay = MU + SIGMA * boxMullerGaussian();
  if (char === ' ' || char === '-' || char === '/' || char === '_') {
    delay *= PUNCTUATION_MULTIPLIER;
  }
  if (prevChar === ' ') {
    delay *= PAUSE_MULTIPLIER;
  }
  return Math.max(MIN_DELAY, Math.round(delay));
}

export function shouldSimulateTypo(): boolean {
  return Math.random() < TYPO_PROBABILITY;
}

export function getAdjacentKey(char: string): string {
  const lower = char.toLowerCase();
  const adjacent = QWERTY_ADJACENCY[lower];
  if (adjacent && adjacent.length > 0) {
    const index = Math.floor(Math.random() * adjacent.length);
    const key = adjacent[index];
    return char === char.toUpperCase() ? key.toUpperCase() : key;
  }
  return char;
}
