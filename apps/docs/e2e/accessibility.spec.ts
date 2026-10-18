import { expect, test } from '@playwright/test';
import { AxeBuilder } from '@axe-core/playwright';
import { PRESETS, THEMES, fontsReady, visitAs } from './helpers';

test.describe('Accessibility (WCAG AA Compliance)', () => {
  const routes = [
    { path: '/en', status: 200, knownFailure: false },
    { path: '/id', status: 200, knownFailure: false },
    // Known and pre-existing, not from the landing work: the Fumadocs token
    // mapping in globals.css is commented out (PRD P0.T4), so docs sidebar
    // and search text fall back to Fumadocs' #737373 (4.19:1 on #f1f1f1),
    // and Fumadocs' GitHub icon is an svg role="img" without a title.
    // Remove `knownFailure` when P0.T4 lands: the test then has to pass.
    { path: '/en/docs/introduction', status: 200, knownFailure: true },
    { path: '/en/buton', status: 404, knownFailure: false },
  ];

  for (const { path, status, knownFailure } of routes) {
    for (const preset of PRESETS) {
      for (const theme of THEMES) {
        test(`meets WCAG AA on ${path} (${preset}, ${theme})`, async ({
          page,
        }) => {
          test.fail(knownFailure, 'PRD P0.T4: docs token mapping');
          await visitAs(page, preset, theme);
          const response = await page.goto(path);
          expect(response?.status()).toBe(status);
          await fontsReady(page);
          const results = await new AxeBuilder({ page })
            .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa'])
            .analyze();
          expect(results.violations).toEqual([]);
        });
      }
    }
  }

  test('keyboard navigation and focus management on search dialog', async ({
    page,
  }) => {
    await page.goto('/en');
    await page.keyboard.press('Control+k');
    const searchDialog = page.getByRole('dialog');
    await expect(searchDialog).toBeVisible();

    await page.keyboard.press('Escape');
    await expect(searchDialog).not.toBeVisible();
  });
});
