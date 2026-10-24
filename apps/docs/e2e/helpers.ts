import { existsSync } from 'node:fs';
import path from 'node:path';
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

/** True when `bun run flutter:build` has produced the bridge bundle. */
export function hasFlutterBundle(): boolean {
  return existsSync(
    path.resolve(import.meta.dirname, '../public/flutter/flutter_bootstrap.js')
  );
}

/**
 * Waits until every live Flutter part on the page shows its live view
 * (Dart has painted the current preset, theme and locale). Without the
 * bundle the parts keep their React fallback and this returns at once.
 */
export async function flutterSettled(page: Page): Promise<void> {
  if (!hasFlutterBundle()) return;
  await page.waitForFunction(
    () =>
      Array.from(document.querySelectorAll('[data-live-part]')).every(
        (part) => part.getAttribute('data-state') === 'live'
      ),
    null,
    { timeout: 30_000 }
  );
}

/** Keeps Flutter off the page, so live parts stay on their React fallback. */
export async function blockFlutter(page: Page): Promise<void> {
  await page.route('**/flutter/**', (route) => route.abort());
}
