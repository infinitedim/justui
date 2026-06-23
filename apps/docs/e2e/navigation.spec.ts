import { test, expect } from '@playwright/test';

test.describe('Navigation Flow', () => {
  test('homepage loads and displays core elements', async ({ page }) => {
    // Navigate to homepage
    await page.goto('/');

    // Verify heading contains JustUI
    const heading = page.locator('h1');
    await expect(heading).toContainText('JustUI');

    // Verify main copy-paste CLI commands are visible
    const cliCommand1 = page.locator('code').first();
    await expect(cliCommand1).toContainText(
      'dart pub global activate just_ui_cli'
    );

    // Verify Action button points to /docs/introduction
    const docsButton = page.locator("a:has-text('Baca Dokumentasi')");
    await expect(docsButton).toHaveAttribute('href', '/docs/introduction');
  });

  test('can navigate from homepage to docs page', async ({ page }) => {
    await page.goto('/');

    // Click on "Baca Dokumentasi"
    const docsButton = page.locator("a:has-text('Baca Dokumentasi')");
    await docsButton.click();

    // Verify navigation to introduction docs page
    await expect(page).toHaveURL(/\/docs\/introduction/);
  });
});
