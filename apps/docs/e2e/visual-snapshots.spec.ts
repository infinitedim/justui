import { test, expect } from '@playwright/test';

test.describe('Visual Regression Snapshots', () => {
  const routes = [
    { name: 'landing', path: '/en' },
    { name: 'catalog', path: '/en/components' },
    { name: 'docs', path: '/en/docs/introduction' },
    { name: 'studio', path: '/en/studio' },
  ];

  const presets = ['default', 'neobrutalism'] as const;
  const themes = ['light', 'dark'] as const;

  for (const { name, path } of routes) {
    for (const preset of presets) {
      for (const theme of themes) {
        test(`${name} visual snapshot (${preset}-${theme})`, async ({
          page,
        }) => {
          await page.emulateMedia({
            colorScheme: theme,
            reducedMotion: 'reduce',
          });
          await page.goto(`${path}?preset=${preset}`);
          await page.waitForLoadState('domcontentloaded');

          await expect(page).toHaveScreenshot(
            `${name}-${preset}-${theme}.png`,
            {
              fullPage: false,
              animations: 'disabled',
              maxDiffPixelRatio: 0.01,
            }
          );
        });
      }
    }
  }
});
