import { test, expect, type Page } from '@playwright/test';
import {
  PRESETS,
  THEMES,
  blockFlutter,
  flutterSettled,
  fontsReady,
  hasFlutterBundle,
  visitAs,
} from './helpers';

/**
 * Landing, components page and 404 in every preset and theme at three
 * widths, plus the docs shell. Reduced motion puts every scroll sequence in its finished layout,
 * so full-page captures are stable.
 */
test.describe('Visual Regression Snapshots', () => {
  /** Content that only exists once the page has hydrated. */
  const hydrated = {
    // Reduced motion: the cut sequence offers its before/after switch.
    landing: (page: Page) => page.getByRole('button', { name: 'After' }),
    // The lookup reads the requested path in the browser.
    'not-found': (page: Page) =>
      page.getByText('No part named buton. Did you mean button?'),
    docs: (page: Page) => page.getByRole('heading', { level: 1 }).first(),
    components: (page: Page) =>
      page.getByRole('heading', { level: 1, name: 'Every part on the runner' }),
  };

  const pages = [
    { name: 'landing', path: '/en', widths: [360, 768, 1280] },
    { name: 'not-found', path: '/en/buton', widths: [360, 768, 1280] },
    {
      name: 'components',
      path: '/en/docs/components',
      widths: [360, 768, 1280],
    },
    { name: 'docs', path: '/en/docs/introduction', widths: [1280] },
  ] as const;

  for (const { name, path, widths } of pages) {
    for (const width of widths) {
      for (const preset of PRESETS) {
        for (const theme of THEMES) {
          test(`${name} ${width}px (${preset}-${theme})`, async ({ page }) => {
            // These baselines lock the React parts, which is what every
            // browser without Blink + WasmGC shows; the live Flutter parts
            // are locked by the showcase goldens and the masked run below.
            await blockFlutter(page);
            await visitAs(page, preset, theme);
            await page.emulateMedia({
              colorScheme: theme,
              reducedMotion: 'reduce',
            });
            await page.setViewportSize({ width, height: 900 });
            await page.goto(path);
            await expect(hydrated[name](page)).toBeVisible();
            await fontsReady(page);
            await expect(page).toHaveScreenshot(
              `${name}-${width}-${preset}-${theme}.png`,
              { fullPage: name !== 'docs', animations: 'disabled' }
            );
          });
        }
      }
    }
  }

  // The page with live Flutter parts: the Flutter canvas is masked (GPU
  // output differs between machines), so this locks the layout around it.
  for (const preset of PRESETS) {
    for (const theme of THEMES) {
      test(`not-found live 1280px (${preset}-${theme})`, async ({ page }) => {
        test.skip(!hasFlutterBundle(), 'no Flutter bundle: run flutter:build');
        await visitAs(page, preset, theme);
        await page.emulateMedia({
          colorScheme: theme,
          reducedMotion: 'reduce',
        });
        await page.setViewportSize({ width: 1280, height: 900 });
        await page.goto('/en/buton');
        await expect(hydrated['not-found'](page)).toBeVisible();
        await fontsReady(page);
        await flutterSettled(page);
        await expect(page).toHaveScreenshot(
          `not-found-live-1280-${preset}-${theme}.png`,
          {
            fullPage: true,
            animations: 'disabled',
            mask: [page.locator('[data-live-host]')],
          }
        );
      });
    }
  }
});
