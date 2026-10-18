import { test, expect, type Page } from '@playwright/test';
import { PRESETS, THEMES, fontsReady, visitAs } from './helpers';

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
});
