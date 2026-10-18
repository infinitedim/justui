import { test, expect } from '@playwright/test';

test.describe('Landing interactions', () => {
  test('arrow keys pick a runner and the choice survives a reload', async ({
    page,
  }) => {
    await page.goto('/en');
    const shelf = page.getByRole('radiogroup', { name: 'Preset' });
    const neo = shelf.getByRole('radio', { name: /Neobrutalism/ });
    await shelf.getByRole('radio', { name: /Default/ }).focus();
    await page.keyboard.press('ArrowDown');
    await expect(neo).toHaveAttribute('aria-checked', 'true');
    await expect(neo).toBeFocused();
    await expect(page.locator('[data-pbox]').first()).toHaveClass(
      /theme-neobrutalism/
    );
    await expect(page.locator('header')).not.toHaveClass(/theme-neobrutalism/);
    await page.reload();
    await expect(neo).toHaveAttribute('aria-checked', 'true');
  });

  test('the hero and the install band share the OS choice', async ({
    page,
  }) => {
    await page.goto('/en');
    const hero = page.locator('section').first();
    await hero.getByRole('tab', { name: 'Windows' }).click();
    await expect(hero.getByRole('tabpanel')).toContainText(
      'irm https://justui.vercel.app/install.ps1 | iex'
    );
    const band = page.getByRole('region', { name: 'Three steps, in order.' });
    await expect(band.getByRole('tabpanel')).toContainText('install.ps1');
  });

  test('copies the add command of a part', async ({ page, context }) => {
    await context.grantPermissions(['clipboard-read', 'clipboard-write']);
    await page.goto('/en');
    await page
      .locator('#parts')
      .getByRole('button', { name: 'Copy justui add switch' })
      .click();
    const copied = await page.evaluate(() => navigator.clipboard.readText());
    expect(copied).toBe('justui add switch');
  });

  test('the Components link lands on the parts index', async ({ page }) => {
    await page.setViewportSize({ width: 1280, height: 800 });
    await page.goto('/en');
    await page
      .getByRole('navigation', { name: 'Main navigation' })
      .getByRole('link', { name: 'Components' })
      .click();
    await expect(page).toHaveURL(/\/en#parts$/);
    await expect(page.locator('#parts')).toBeInViewport();
  });

  test('has no horizontal scroll at 360px', async ({ page }) => {
    await page.setViewportSize({ width: 360, height: 780 });
    for (const path of ['/en', '/id', '/en/buton']) {
      await page.goto(path);
      const overflow = await page.evaluate(
        () =>
          document.documentElement.scrollWidth -
          document.documentElement.clientWidth
      );
      expect(overflow, path).toBe(0);
    }
  });
});
