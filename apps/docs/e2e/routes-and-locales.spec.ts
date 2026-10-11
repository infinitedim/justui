import { test, expect } from '@playwright/test';

test.describe('Routes and Locales', () => {
  test('invalid locale /fr returns 404 and renders NotFoundView', async ({
    page,
  }) => {
    const response = await page.goto('/fr');
    expect(response?.status()).toBe(404);

    await expect(page.getByText('404')).toBeVisible();
    await expect(page.getByRole('heading', { level: 1 })).toHaveText(
      /Page not found|Halaman tidak ditemukan/i
    );
  });

  test('homepages render correct <html lang> and <title>', async ({ page }) => {
    // English homepage
    await page.goto('/en');
    await expect(page.locator('html')).toHaveAttribute('lang', 'en');
    await expect(page).toHaveTitle('One command. One file. Yours. | JustUI');

    // Indonesian homepage
    await page.goto('/id');
    await expect(page.locator('html')).toHaveAttribute('lang', 'id');
    await expect(page).toHaveTitle(
      'Satu perintah. Satu file. Milikmu. | JustUI'
    );
  });

  test('docs pages render correct <html lang> and localized <title>', async ({
    page,
  }) => {
    // English docs introduction
    await page.goto('/en/docs/introduction');
    await expect(page.locator('html')).toHaveAttribute('lang', 'en');
    await expect(page).toHaveTitle('Introduction | JustUI');

    // Indonesian docs introduction
    await page.goto('/id/docs/introduction');
    await expect(page.locator('html')).toHaveAttribute('lang', 'id');
    await expect(page).toHaveTitle('Pendahuluan | JustUI');
  });
});
