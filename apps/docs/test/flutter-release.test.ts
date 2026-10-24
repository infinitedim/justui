import { describe, expect, it } from 'vitest';
import { fvmrcFlutter, pickRelease } from '../scripts/flutter-release';

const SHA = 'a'.repeat(64);

function release(version: string, hash: string, channel = 'stable') {
  return {
    hash,
    channel,
    version,
    archive: `${channel}/linux/flutter_linux_${version}-${channel}.tar.xz`,
    sha256: SHA,
  };
}

const index = {
  current_release: { stable: 'h2', beta: 'h3' },
  releases: [
    release('3.48.0-1.0.pre', 'h3', 'beta'),
    release('3.47.8', 'h2'),
    release('3.47.5', 'h1'),
  ],
};

describe('flutter release', () => {
  it('reads "stable" or an exact version from .fvmrc', () => {
    expect(fvmrcFlutter('{ "flutter": "stable" }')).toBe('stable');
    expect(fvmrcFlutter('{ "flutter": "3.47.5" }')).toBe('3.47.5');
    expect(() => fvmrcFlutter('{ "flutter": "beta" }')).toThrow();
    expect(() => fvmrcFlutter('{ "flutter": "3.47.5; rm -rf /" }')).toThrow();
  });

  it('resolves the current stable release', () => {
    expect(pickRelease(index, 'stable').version).toBe('3.47.8');
  });

  it('resolves an exact stable version', () => {
    expect(pickRelease(index, '3.47.5').hash).toBe('h1');
    expect(() => pickRelease(index, '3.48.0-1.0.pre')).toThrow();
  });

  it('rejects an entry with an odd archive path or sha256', () => {
    const odd = {
      current_release: { stable: 'h9' },
      releases: [{ ...release('3.47.9', 'h9'), archive: '../evil.tar.xz' }],
    };
    expect(() => pickRelease(odd, 'stable')).toThrow();
    const short = {
      current_release: { stable: 'h9' },
      releases: [{ ...release('3.47.9', 'h9'), sha256: 'abc' }],
    };
    expect(() => pickRelease(short, 'stable')).toThrow();
  });
});
