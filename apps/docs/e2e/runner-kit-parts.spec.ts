import { expect, test, type Locator } from '@playwright/test';
import { presetScopeClass } from '@/lib/presets';
import { PRESETS, blockFlutter, visitAs } from './helpers';

/**
 * The React runner-kit parts draw their states with Tailwind classes, and a
 * missing class leaves a part blank in a way the full-page snapshots can
 * miss (a lost check mark is far under their 1% pixel threshold). These read
 * the computed style of each state instead. Flutter is blocked, so the
 * React parts are what the page shows.
 */

const TRANSPARENT = 'rgba(0, 0, 0, 0)';

/** The decorative box a native control draws right after its input. */
function controlBox(control: Locator): Locator {
  return control.locator(
    'xpath=following-sibling::span[@aria-hidden="true"][1]'
  );
}

/** Height in px, retried: preset classes land after hydration. */
async function expectHeight(locator: Locator): Promise<void> {
  await expect
    .poll(async () => (await locator.boundingBox())?.height ?? 0)
    .toBeGreaterThan(0);
}

for (const preset of PRESETS) {
  test.describe(`runner-kit part states (${preset})`, () => {
    test.beforeEach(async ({ page }) => {
      await blockFlutter(page);
      await visitAs(page, preset, 'light');
      await page.goto('/en/docs/components');
      await expect(
        page.locator(`.${presetScopeClass(preset)}`).first()
      ).toBeAttached();
    });

    test('a checked checkbox shows its check mark', async ({ page }) => {
      const checkbox = page.getByRole('checkbox', {
        name: 'Remember this device',
      });
      await expect(checkbox).toBeChecked();
      const check = controlBox(checkbox).locator('svg');
      await expect(check).toHaveCSS('visibility', 'visible');
    });

    test('a checked radio shows its dot', async ({ page }) => {
      const radio = page
        .getByRole('radiogroup', { name: 'Frequency' })
        .first()
        .getByRole('radio', { checked: true });
      const dot = controlBox(radio).locator('span');
      await expect(dot).not.toHaveCSS('transform', 'matrix(0, 0, 0, 0, 0, 0)');
      await expectHeight(dot);
    });

    test('an unchecked switch keeps a visible track', async ({ page }) => {
      const wifi = page.getByRole('switch', { name: 'Wi-Fi' });
      await wifi.uncheck({ force: true });
      await expect(wifi).not.toBeChecked();
      const track = controlBox(wifi);
      await expect(track).not.toHaveCSS('background-color', TRANSPARENT);
    });

    test('the active tab is underlined', async ({ page }) => {
      const tab = page
        .getByRole('tablist', { name: 'Settings sections' })
        .getByRole('tab', { selected: true });
      await expect(tab).not.toHaveCSS('box-shadow', 'none');
    });

    test('the current bottom-nav item has its indicator', async ({ page }) => {
      const indicator = page
        .getByRole('group', { name: 'App navigation' })
        .locator('[aria-current="page"] span[aria-hidden="true"]');
      await expectHeight(indicator);
    });

    test('the progress bar has a track', async ({ page }) => {
      const progress = page.getByRole('progressbar', { name: 'Uploading' });
      await expectHeight(progress);
    });
  });
}
