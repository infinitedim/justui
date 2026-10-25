import { expect, test, type Page } from '@playwright/test';
import { AxeBuilder } from '@axe-core/playwright';
import {
  PRESETS,
  THEMES,
  flutterSettled,
  fontsReady,
  hasFlutterBundle,
  visitAs,
} from './helpers';

const WCAG = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa'];

/**
 * The components page is long and loads its live parts near the viewport,
 * so not every part is live at once. Each runner is brought to the middle
 * of the screen, its parts go live, and axe scans it with the Flutter DOM.
 */
async function runnerViolations(page: Page): Promise<Array<unknown>> {
  const violations: Array<unknown> = [];
  const runners = page.getByRole('region');
  const count = await runners.count();
  for (let index = 0; index < count; index++) {
    const runner = runners.nth(index);
    await runner.evaluate((node) => node.scrollIntoView({ block: 'center' }));
    const parts = runner.locator('[data-live-part]');
    for (const part of await parts.all()) {
      await expect(part).toHaveAttribute('data-state', 'live', {
        timeout: 30_000,
      });
    }
    const id = await runner.getAttribute('aria-labelledby');
    const results = await new AxeBuilder({ page })
      .withTags(WCAG)
      .include(`section[aria-labelledby="${id ?? ''}"]`)
      .analyze();
    violations.push(...results.violations);
  }
  return violations;
}

test.describe('Accessibility (WCAG AA Compliance)', () => {
  const routes = [
    { path: '/en', status: 200, knownFailure: false },
    { path: '/id', status: 200, knownFailure: false },
    { path: '/en/docs/components', status: 200, knownFailure: false },
    { path: '/id/docs/components', status: 200, knownFailure: false },
    // Known and pre-existing, not from the landing work: the Fumadocs token
    // mapping in globals.css is commented out (PRD P0.T4), so docs sidebar
    // and search text fall back to Fumadocs' #737373 (4.19:1 on #f1f1f1),
    // and Fumadocs' GitHub icon is an svg role="img" without a title.
    // Remove `knownFailure` when P0.T4 lands: the test then has to pass.
    { path: '/en/docs/introduction', status: 200, knownFailure: true },
    { path: '/en/buton', status: 404, knownFailure: false },
  ];

  for (const { path, status, knownFailure } of routes) {
    for (const preset of PRESETS) {
      for (const theme of THEMES) {
        test(`meets WCAG AA on ${path} (${preset}, ${theme})`, async ({
          page,
        }) => {
          test.fail(knownFailure, 'PRD P0.T4: docs token mapping');
          await visitAs(page, preset, theme);
          const response = await page.goto(path);
          expect(response?.status()).toBe(status);
          await fontsReady(page);
          // Live Flutter parts are scanned too: axe sees their semantics DOM.
          if (path.endsWith('/docs/components') && hasFlutterBundle()) {
            expect(await runnerViolations(page)).toEqual([]);
          } else {
            await flutterSettled(page);
          }
          const results = await new AxeBuilder({ page })
            .withTags(WCAG)
            .analyze();
          expect(results.violations).toEqual([]);
        });
      }
    }
  }

  test('keyboard navigation and focus management on search dialog', async ({
    page,
  }) => {
    await page.goto('/en');
    await page.keyboard.press('Control+k');
    const searchDialog = page.getByRole('dialog');
    await expect(searchDialog).toBeVisible();

    await page.keyboard.press('Escape');
    await expect(searchDialog).not.toBeVisible();
  });
});
