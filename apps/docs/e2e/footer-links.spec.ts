import { test, expect } from '@playwright/test';

test.describe('Footer links', () => {
  test('CLI guide link resolves to cli-setup, not a 404', async ({
    page,
  }) => {
    await page.goto('/en');
    const cliLink = page.getByRole('link', { name: /cli guide/i });
    await expect(cliLink).toHaveAttribute('href', '/en/docs/cli-setup');

    const response = await page.request.get('/en/docs/cli-setup');
    expect(response.status()).toBe(200);
  });

  test('Indonesian installation link from the introduction page stays in id locale', async ({
    page,
  }) => {
    await page.goto('/id/docs/introduction');
    // Scoped to the article body: the sidebar nav and "related pages" card
    // also render an "Instalasi" link, but this in-prose one is the fix
    // under test (it used to be an absolute, locale-less /docs/installation
    // link that redirected Indonesian readers to the English page).
    const installLink = page
      .locator('#nd-page')
      .getByRole('link', { name: 'Instalasi', exact: true });
    await installLink.click();
    await expect(page).toHaveURL('/id/docs/installation');
  });
});
