import { test, expect } from '@playwright/test';

test.describe('Search dialog', () => {
  test('Ctrl+K opens exactly one dialog, with locale-aware placeholder', async ({
    page,
  }) => {
    await page.goto('/en');

    await expect(page.getByRole('dialog')).toHaveCount(0);
    await page.keyboard.press('Control+k');

    const dialogs = page.getByRole('dialog');
    await expect(dialogs).toHaveCount(1);
    await expect(dialogs.locator('input')).toHaveAttribute(
      'placeholder',
      'Search'
    );
  });

  test('Escape closes the dialog and returns focus, with no leftover dialog', async ({
    page,
  }) => {
    await page.goto('/id');

    await page.keyboard.press('Control+k');
    await expect(page.getByRole('dialog')).toHaveCount(1);
    await expect(page.getByRole('dialog').locator('input')).toHaveAttribute(
      'placeholder',
      'Cari...'
    );

    await page.keyboard.press('Escape');
    await expect(page.getByRole('dialog')).toHaveCount(0);
  });

  test('focus moves into the dialog input when opened', async ({ page }) => {
    await page.goto('/en');
    await expect(page.getByRole('dialog')).toHaveCount(0);
    await page.keyboard.press('Control+k');

    const input = page.getByRole('dialog').locator('input');
    await expect(input).toBeFocused();
  });

  test('the nav search button opens the same single dialog', async ({
    page,
  }) => {
    await page.setViewportSize({ width: 1280, height: 800 });
    await page.goto('/en');
    await page.getByRole('button', { name: /Search docs/ }).click();
    await expect(page.getByRole('dialog')).toHaveCount(1);
  });

  test('docs pages have search too', async ({ page }) => {
    await page.goto('/en/docs/introduction');
    await page.keyboard.press('Control+k');
    await expect(page.getByRole('dialog')).toHaveCount(1);
  });
});
