import { test, expect } from '@playwright/test';

test.describe('Footer links', () => {
  test('landing footer links resolve', async ({ page }) => {
    await page.goto('/en');
    const footer = page.getByRole('contentinfo');
    await expect(footer.getByRole('link', { name: 'Docs' })).toHaveAttribute(
      'href',
      '/en/docs/introduction'
    );
    await expect(
      footer.getByRole('link', { name: 'Components' })
    ).toHaveAttribute('href', '/en#parts');
    await expect(footer.getByRole('link', { name: 'GitHub' })).toHaveAttribute(
      'href',
      'https://github.com/infinitedim/justui'
    );

    const response = await page.request.get('/en/docs/introduction');
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
