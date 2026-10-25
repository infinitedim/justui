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
    await page.goto('/en/docs/components');
    await page.getByRole('button', { name: 'Copy justui add switch' }).click();
    const copied = await page.evaluate(() => navigator.clipboard.readText());
    expect(copied).toBe('justui add switch');
  });

  test('the Components link opens the components page', async ({ page }) => {
    await page.setViewportSize({ width: 1280, height: 800 });
    await page.goto('/en');
    await page
      .getByRole('navigation', { name: 'Main navigation' })
      .getByRole('link', { name: 'Components' })
      .click();
    await expect(page).toHaveURL(/\/en\/docs\/components$/);
    await expect(
      page.getByRole('heading', { level: 1, name: 'Every part on the runner' })
    ).toBeVisible();
    await page.getByRole('link', { name: 'Open button docs' }).click();
    await expect(page).toHaveURL(/\/en\/docs\/components\/button$/);
  });

  test('has no horizontal scroll at 360px', async ({ page }) => {
    await page.setViewportSize({ width: 360, height: 780 });
    for (const path of ['/en', '/id', '/en/docs/components', '/en/buton']) {
      await page.goto(path);
      const overflow = await page.evaluate(
        () =>
          document.documentElement.scrollWidth -
          document.documentElement.clientWidth
      );
      expect(overflow, path).toBe(0);
    }
  });

  test('Shift+Tab never leaves focus under the sticky nav', async ({
    page,
  }) => {
    await page.setViewportSize({ width: 1280, height: 900 });
    await page.goto('/en');
    // The band's first OS tab: the previous focusable control sits far
    // above it, in the two runners section.
    const first = page
      .getByRole('region', { name: 'Three steps, in order.' })
      .getByRole('tab', { name: 'macOS / Linux' });
    await first.focus();
    await first.evaluate((el) => {
      window.scrollBy(0, el.getBoundingClientRect().top - 120);
    });
    await page.keyboard.press('Shift+Tab');
    const gap = await page.evaluate(() => {
      const active = document.activeElement;
      const header = document.querySelector('header');
      if (!active || !header) return Number.NaN;
      return (
        active.getBoundingClientRect().top -
        header.getBoundingClientRect().bottom
      );
    });
    expect(gap).toBeGreaterThanOrEqual(0);
  });

  test('closing search from the mobile menu returns focus', async ({
    page,
  }) => {
    await page.setViewportSize({ width: 360, height: 780 });
    await page.goto('/en');
    await page.getByRole('button', { name: 'Menu' }).click();
    const search = page
      .getByRole('navigation', { name: 'Main navigation' })
      .getByRole('button', { name: 'Search docs' });
    await search.focus();
    await page.keyboard.press('Enter');
    await expect(page.getByRole('dialog')).toBeVisible();
    await page.keyboard.press('Escape');
    await expect(page.getByRole('dialog')).toBeHidden();
    await expect(search).toBeFocused();
  });

  test('the components page shows every part name in full', async ({
    page,
  }) => {
    for (const width of [360, 768, 1280]) {
      await page.setViewportSize({ width, height: 900 });
      await page.goto('/en/docs/components');
      const clipped = await page
        .getByRole('main')
        .locator('li code')
        .evaluateAll((codes) =>
          codes
            .filter((code) => code.scrollWidth > code.clientWidth)
            .map((code) => code.textContent)
        );
      expect(clipped, `${width}px`).toEqual([]);
    }
  });
});
