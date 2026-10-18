import { test, expect } from '@playwright/test';

test.describe('Routes and Locales', () => {
  test('an invalid locale is a 404 with the runner page', async ({ page }) => {
    const response = await page.goto('/fr');
    expect(response?.status()).toBe(404);
    await expect(page.getByRole('heading', { level: 1 })).toHaveText(
      "Part 404 isn't on this runner."
    );
    await expect(page).toHaveTitle('Part not found | JustUI');
  });

  test('an unknown part under /id is a 404 in Indonesian', async ({ page }) => {
    const response = await page.goto('/id/buton');
    expect(response?.status()).toBe(404);
    await expect(page.locator('html')).toHaveAttribute('lang', 'id');
    await expect(page.getByRole('heading', { level: 1 })).toHaveText(
      'Part 404 tidak ada di runner ini.'
    );
    await expect(page.getByRole('textbox', { name: 'Cari part' })).toHaveValue(
      'buton'
    );
    await expect(page.getByRole('status')).toHaveText(
      'Tidak ada part bernama buton. Maksudnya button?'
    );
  });

  test('an unknown docs page is a 404 too', async ({ page }) => {
    const response = await page.goto('/en/docs/nope');
    expect(response?.status()).toBe(404);
    await expect(page.getByRole('heading', { level: 1 })).toHaveText(
      "Part 404 isn't on this runner."
    );
  });

  test('removed pages redirect to the landing', async ({ page }) => {
    await page.goto('/en/components/button');
    await expect(page).toHaveURL(/\/en#parts$/);
    await page.goto('/studio');
    await expect(page).toHaveURL(/\/en$/);
  });

  test('homepages render correct <html lang> and <title>', async ({ page }) => {
    await page.goto('/en');
    await expect(page.locator('html')).toHaveAttribute('lang', 'en');
    await expect(page).toHaveTitle('One command. One file. Yours. | JustUI');

    await page.goto('/id');
    await expect(page.locator('html')).toHaveAttribute('lang', 'id');
    await expect(page).toHaveTitle(
      'Satu perintah. Satu file. Milikmu. | JustUI'
    );
  });

  test('docs pages render correct <html lang> and localized <title>', async ({
    page,
  }) => {
    await page.goto('/en/docs/introduction');
    await expect(page.locator('html')).toHaveAttribute('lang', 'en');
    await expect(page).toHaveTitle('Introduction | JustUI');

    await page.goto('/id/docs/introduction');
    await expect(page.locator('html')).toHaveAttribute('lang', 'id');
    await expect(page).toHaveTitle('Pendahuluan | JustUI');
  });
});
