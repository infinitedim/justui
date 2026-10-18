import { test, expect } from '@playwright/test';

test.describe('Navigation Flow', () => {
  test('homepage loads and displays core elements', async ({ page }) => {
    await page.goto('/');

    await expect(
      page.getByRole('heading', { name: /One command\. One file\. Yours\./i })
    ).toBeVisible();
    const hero = page.locator('section').first();
    await expect(
      hero.getByRole('tablist', { name: 'Operating system' })
    ).toBeVisible();
    await expect(hero.getByText(/install\.sh/)).toBeVisible();
    await expect(
      page
        .getByRole('navigation', { name: 'Main navigation' })
        .getByRole('link', { name: 'Docs' })
    ).toHaveAttribute('href', '/en/docs/introduction');
  });

  test('can navigate from homepage to docs page', async ({ page }) => {
    await page.goto('/');
    await page
      .getByRole('navigation', { name: 'Main navigation' })
      .getByRole('link', { name: 'Docs' })
      .click();
    await expect(page).toHaveURL(/\/en\/docs\/introduction$/);
  });

  test('the menu carries the links below 960px', async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 });
    await page.goto('/en');
    await page.getByRole('button', { name: 'Menu' }).click();
    await page
      .locator('#site-nav-menu')
      .getByRole('link', { name: 'Docs' })
      .click();
    await expect(page).toHaveURL(/\/en\/docs\/introduction$/);
  });
});
