import type { Page } from '@playwright/test';

export const PRESETS = ['default', 'neobrutalism'] as const;
export const THEMES = ['light', 'dark'] as const;

export type Preset = (typeof PRESETS)[number];
export type Theme = (typeof THEMES)[number];

/**
 * Stores the visitor's preset and theme before any page script runs, the
 * way a returning visitor would have them, and matches the OS scheme.
 */
export async function visitAs(
  page: Page,
  preset: Preset,
  theme: Theme
): Promise<void> {
  await page.addInitScript(
    ([storedPreset, storedTheme]) => {
      window.localStorage.setItem('justui-preset', storedPreset);
      window.localStorage.setItem('theme', storedTheme);
    },
    [preset, theme] as const
  );
  await page.emulateMedia({ colorScheme: theme });
}

/** Waits until every web font in use has loaded. */
export async function fontsReady(page: Page): Promise<void> {
  await page.evaluate(async () => {
    await document.fonts.ready;
  });
}
