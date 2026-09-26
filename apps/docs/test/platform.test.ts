import { describe, expect, it } from 'vitest';
import { isApplePlatform } from '@/lib/platform';

describe('isApplePlatform', () => {
  it('uses userAgentData when available (Chromium)', () => {
    expect(isApplePlatform({ userAgentData: { platform: 'macOS' } })).toBe(
      true
    );
    expect(isApplePlatform({ userAgentData: { platform: 'Windows' } })).toBe(
      false
    );
  });

  it('falls back to navigator.platform for Safari and Firefox on Mac', () => {
    expect(isApplePlatform({ platform: 'MacIntel' })).toBe(true);
  });

  it('falls back to the user agent string on iOS', () => {
    expect(
      isApplePlatform({
        userAgent:
          'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15',
      })
    ).toBe(true);
  });

  it('returns false for other platforms and missing hints', () => {
    expect(isApplePlatform({ platform: 'Linux x86_64' })).toBe(false);
    expect(isApplePlatform({})).toBe(false);
    expect(isApplePlatform(undefined)).toBe(false);
  });
});
