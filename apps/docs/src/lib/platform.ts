/**
 * Minimal view of `Navigator` used for platform detection, so the check can be
 * unit-tested without a real browser.
 */
export interface PlatformHints {
  userAgentData?: { platform?: string };
  platform?: string;
  userAgent?: string;
}

const APPLE_PLATFORM_PATTERN = /mac|iphone|ipad|ipod/i;

/**
 * Returns true on macOS and iOS devices.
 *
 * `navigator.userAgentData` only exists in Chromium browsers, so Safari and
 * Firefox fall back to the legacy `navigator.platform` and finally the
 * user-agent string.
 */
export function isApplePlatform(hints: PlatformHints | undefined): boolean {
  if (!hints) return false;
  const platform =
    hints.userAgentData?.platform || hints.platform || hints.userAgent || '';
  return APPLE_PLATFORM_PATTERN.test(platform);
}
