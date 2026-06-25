import { test, expect } from '@playwright/test';

test.describe('Navigation Flow', () => {
  test('homepage loads and displays core elements', async ({ page }) => {
    await page.goto('/');

    await expect(
      page.getByRole('heading', { name: /Copy\. Paste\. Ship\./i })
    ).toBeVisible();
    await expect(page.getByText('flutter pub add just_ui_core')).toBeVisible();

    const docsButton = page.getByRole('link', { name: /Get started/i });
    await expect(docsButton).toHaveAttribute('href', '/docs/introduction');
  });

  test('can navigate from homepage to docs page', async ({ page }) => {
    await page.goto('/');

    await page.getByRole('link', { name: /Get started/i }).click();

    await expect(page).toHaveURL(/\/docs\/introduction/);
  });
});
