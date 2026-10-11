import { expect, test } from '@playwright/test';
import { AxeBuilder } from '@axe-core/playwright';

test.describe('Accessibility (WCAG AA Compliance)', () => {
  const routes = [
    '/en',
    '/en/components',
    '/en/docs/introduction',
    '/en/studio',
  ];

  for (const route of routes) {
    test(`meets WCAG AA audit on ${route}`, async ({ page }) => {
      await page.goto(route);
      const accessibilityScanResults = await new AxeBuilder({ page })
        .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa'])
        .analyze();

      expect(accessibilityScanResults.violations).toEqual([]);
    });
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
