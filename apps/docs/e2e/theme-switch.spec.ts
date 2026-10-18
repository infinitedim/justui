import { test, expect, type Page } from '@playwright/test';
import { visitAs } from './helpers';

/** Errors and CSP reports raised while the page runs. */
function collectErrors(page: Page): Array<string> {
  const errors: Array<string> = [];
  page.on('pageerror', (error) => errors.push(String(error)));
  page.on('console', (message) => {
    if (message.type() === 'error') errors.push(message.text());
  });
  return errors;
}

/** The theme has changed and the turn has fully cleaned up after itself. */
async function expectSettled(page: Page, dark: boolean) {
  const html = page.locator('html');
  if (dark) await expect(html).toHaveClass(/\bdark\b/);
  else await expect(html).not.toHaveClass(/\bdark\b/);
  await expect(page.locator('body > canvas')).toHaveCount(0);
  await expect(page.locator('body > div[aria-hidden="true"]')).toHaveCount(0);
  await expect(html).not.toHaveAttribute('data-theme-switching');
}

test.describe('Theme switch (page curl)', () => {
  test('turns the page to dark and back with nothing left behind', async ({
    page,
  }) => {
    const errors = collectErrors(page);
    await visitAs(page, 'default', 'light');
    await page.goto('/en');
    await page.getByRole('button', { name: 'Switch to dark mode' }).click();
    await expectSettled(page, true);
    await page.getByRole('button', { name: 'Switch to light mode' }).click();
    await expectSettled(page, false);
    expect(errors).toEqual([]);
  });

  test('a click during the curl still switches back', async ({ page }) => {
    await visitAs(page, 'default', 'light');
    await page.goto('/en');
    await page.getByRole('button', { name: 'Switch to dark mode' }).click();
    await expect(page.locator('body > canvas')).toHaveCount(1);
    await page.getByRole('button', { name: 'Switch to light mode' }).click();
    await expectSettled(page, false);
  });

  test('crossfades under reduced motion', async ({ page }) => {
    const errors = collectErrors(page);
    await visitAs(page, 'neobrutalism', 'light');
    await page.emulateMedia({ colorScheme: 'light', reducedMotion: 'reduce' });
    await page.goto('/en');
    await page.getByRole('button', { name: 'Switch to dark mode' }).click();
    await expectSettled(page, true);
    expect(errors).toEqual([]);
  });

  test('switches the 404 too', async ({ page }) => {
    await visitAs(page, 'default', 'light');
    const response = await page.goto('/id/buton');
    expect(response?.status()).toBe(404);
    await page.getByRole('button', { name: 'Ganti ke mode gelap' }).click();
    await expectSettled(page, true);
  });
});
