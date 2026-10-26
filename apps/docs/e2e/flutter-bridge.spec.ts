import { expect, test, type Page } from '@playwright/test';
import {
  blockFlutter,
  flutterSettled,
  hasFlutterBundle,
  visitAs,
} from './helpers';

/**
 * The Flutter bridge on the 404 (`/en/buton`): the button part is the real
 * JustButton from apps/showcase, mounted over its React fallback.
 */

const PATH = '/en/buton';

/** Console errors, minus the expected 404s of the 404 page and favicon. */
function collectErrors(page: Page): Array<string> {
  const errors: Array<string> = [];
  page.on('pageerror', (error) => errors.push(String(error)));
  page.on('console', (message) => {
    if (message.type() !== 'error') return;
    const url = message.location().url;
    const expected404 =
      message.text().includes('status of 404') &&
      /\/buton$|\/favicon\.ico$/.test(url);
    if (!expected404) errors.push(message.text());
  });
  return errors;
}

/** The live part, its state and the button Flutter exposes to AT. */
function livePart(page: Page) {
  const part = page.locator('[data-live-part="button"]');
  return {
    part,
    button: part
      .locator('[data-live-host]')
      .getByRole('button', { name: 'Save changes', exact: true }),
  };
}

test.describe('Flutter bridge on the 404', () => {
  test.skip(
    !hasFlutterBundle(),
    'no Flutter bundle: run bun run flutter:build'
  );

  test('mounts the real button with no errors, globals or third parties', async ({
    page,
    baseURL,
  }) => {
    const errors = collectErrors(page);
    const foreign: Array<string> = [];
    page.on('request', (request) => {
      const url = request.url();
      if (!/^(data|blob):/.test(url) && !url.startsWith(baseURL ?? '')) {
        foreign.push(url);
      }
    });
    await visitAs(page, 'default', 'light');
    await page.goto(PATH);
    await flutterSettled(page);
    const { part, button } = livePart(page);
    await expect(part).toHaveAttribute('data-state', 'live');
    await expect(button).toBeVisible();
    await expect(page).toHaveTitle('Part not found | JustUI');
    const globals = await page.evaluate(() =>
      Object.keys(window).filter((key) => key.toLowerCase().includes('flutter'))
    );
    expect(globals.sort()).toEqual(['_flutter', '_flutter_skwasmInstance']);
    expect(foreign).toEqual([]);
    expect(errors).toEqual([]);
  });

  test('keeps the React part when Flutter cannot load', async ({ page }) => {
    await blockFlutter(page);
    await visitAs(page, 'default', 'light');
    await page.goto(PATH);
    const { part } = livePart(page);
    await expect(
      part.getByRole('button', { name: 'Save changes', exact: true })
    ).toBeVisible();
    await page.waitForTimeout(1500);
    await expect(part).toHaveAttribute('data-state', 'fallback');
  });

  test('Tab moves through the live part in page order, both ways', async ({
    page,
  }) => {
    await visitAs(page, 'default', 'light');
    await page.goto(PATH);
    await flutterSettled(page);
    const { button } = livePart(page);
    const github = page.getByRole('link', { name: 'GitHub' });
    const copy = page.getByRole('button', { name: 'Copy justui add button' });
    await github.focus();
    await page.keyboard.press('Tab');
    await expect(button).toBeFocused();
    await page.keyboard.press('Tab');
    await expect(copy).toBeFocused();
    // The next part (badge) has no control: its view is not a Tab stop.
    await page.keyboard.press('Tab');
    await expect(
      page.getByRole('button', { name: 'Copy justui add badge' })
    ).toBeFocused();
    await page.keyboard.press('Shift+Tab');
    await expect(copy).toBeFocused();
    await page.keyboard.press('Shift+Tab');
    await expect(button).toBeFocused();
    await page.keyboard.press('Shift+Tab');
    await expect(github).toBeFocused();
  });
});

test.describe('Flutter bridge on the 404: theme and layout', () => {
  test.skip(
    !hasFlutterBundle(),
    'no Flutter bundle: run bun run flutter:build'
  );

  test('follows the theme switch, the preset and the locale', async ({
    page,
  }) => {
    const errors = collectErrors(page);
    await visitAs(page, 'neobrutalism', 'light');
    await page.goto('/id/buton');
    await flutterSettled(page);
    const part = page.locator('[data-live-part="button"]');
    await expect(
      part
        .locator('[data-live-host]')
        .getByRole('button', { name: 'Simpan perubahan', exact: true })
    ).toBeVisible();
    await page.getByRole('button', { name: 'Ganti ke mode gelap' }).click();
    await expect(page.locator('html')).toHaveClass(/\bdark\b/);
    await expect(page.locator('html')).not.toHaveAttribute(
      'data-theme-switching'
    );
    await expect(part).toHaveAttribute('data-state', 'live');
    await expect(page.locator('body > canvas')).toHaveCount(0);
    expect(errors).toEqual([]);
  });

  test('the swap shifts no layout and respects reduced motion', async ({
    page,
  }) => {
    await page.emulateMedia({ reducedMotion: 'reduce' });
    await page.addInitScript(() => {
      // Count only shifts from the swap: the window opens once the fonts
      // are in and Flutter has attached a view. Earlier shifts (the font
      // swap, the 404 picking its parts from the path) are page load; they
      // move a part along with its row and are not the swap's doing.
      const shifts: Array<string> = [];
      Reflect.set(window, '__liveShifts', shifts);
      let opened = Number.POSITIVE_INFINITY;
      const views = new MutationObserver(() => {
        if (!document.querySelector('[data-live-host] flutter-view')) return;
        views.disconnect();
        void (async () => {
          await document.fonts.ready;
          opened = performance.now();
          Reflect.set(window, '__liveWindowOpened', true);
        })();
      });
      views.observe(document, { childList: true, subtree: true });
      new PerformanceObserver((list) => {
        for (const entry of list.getEntries()) {
          if (entry.startTime < opened) continue;
          const sources: Array<{ node?: Node | null }> =
            Reflect.get(entry, 'sources') ?? [];
          for (const source of sources) {
            const node = source.node;
            if (node instanceof Element && node.closest('[data-live-part]')) {
              shifts.push(node.tagName);
            }
          }
        }
      }).observe({ type: 'layout-shift', buffered: true });
    });
    await visitAs(page, 'default', 'light');
    await page.goto(PATH);
    await flutterSettled(page);
    // The window must have opened, or the check below proves nothing.
    expect(
      await page.evaluate(() => Reflect.get(window, '__liveWindowOpened'))
    ).toBe(true);
    expect(
      await page.evaluate(() => Reflect.get(window, '__liveShifts'))
    ).toEqual([]);
    const duration = await livePart(page)
      .part.locator('[data-live-host]')
      .evaluate((host) => getComputedStyle(host).transitionDuration);
    // The global reduced-motion rule sets 0.01ms: effectively instant.
    expect(parseFloat(duration)).toBeLessThan(0.001);
  });
});

test.describe('Flutter bridge on touch screens', () => {
  test.skip(
    !hasFlutterBundle(),
    'no Flutter bundle: run bun run flutter:build'
  );
  test.use({
    viewport: { width: 390, height: 600 },
    hasTouch: true,
    isMobile: true,
  });

  test('a vertical swipe over the live part scrolls the page', async ({
    page,
    context,
  }) => {
    await visitAs(page, 'default', 'light');
    await page.goto(PATH);
    const { part } = livePart(page);
    await part.scrollIntoViewIfNeeded();
    // Parts far below the fold never load on this viewport, so wait for
    // this one instead of every part (flutterSettled).
    await expect(part).toHaveAttribute('data-state', 'live', {
      timeout: 30_000,
    });
    const box = await part.locator('[data-live-host]').boundingBox();
    expect(box).not.toBeNull();
    if (!box) return;
    const before = await page.evaluate(() => window.scrollY);
    const cdp = await context.newCDPSession(page);
    const x = box.x + box.width / 2;
    const y = box.y + box.height * 0.8;
    await cdp.send('Input.dispatchTouchEvent', {
      type: 'touchStart',
      touchPoints: [{ x, y }],
    });
    for (let step = 1; step <= 10; step++) {
      await cdp.send('Input.dispatchTouchEvent', {
        type: 'touchMove',
        touchPoints: [{ x, y: y - step * 15 }],
      });
    }
    await cdp.send('Input.dispatchTouchEvent', {
      type: 'touchEnd',
      touchPoints: [],
    });
    await expect
      .poll(() => page.evaluate(() => window.scrollY))
      .toBeGreaterThan(before + 50);
  });
});

test.describe('Flutter bridge on the components page', () => {
  test.skip(
    !hasFlutterBundle(),
    'no Flutter bundle: run bun run flutter:build'
  );

  test('mounts parts near the viewport and removes them after they leave', async ({
    page,
  }) => {
    const errors = collectErrors(page);
    await visitAs(page, 'default', 'light');
    await page.setViewportSize({ width: 1280, height: 900 });
    await page.goto('/en/docs/components');
    const first = page.locator('[data-live-part="button"]');
    const last = page.locator('[data-live-part="separator"]');
    await expect(first).toHaveAttribute('data-state', 'live', {
      timeout: 30_000,
    });
    await expect(last).toHaveAttribute('data-state', 'fallback');
    await last.scrollIntoViewIfNeeded();
    await expect(last).toHaveAttribute('data-state', 'live', {
      timeout: 30_000,
    });
    // Views that left the viewport go away after a short grace period.
    await expect(first.locator('flutter-view')).toHaveCount(0, {
      timeout: 10_000,
    });
    expect(errors).toEqual([]);
  });

  test('every view has the same size and its scene is not cut off', async ({
    page,
  }) => {
    await visitAs(page, 'neobrutalism', 'dark');
    await page.setViewportSize({ width: 1280, height: 900 });
    await page.goto('/en/docs/components');
    const calendar = page.locator('[data-live-part="date-picker"]');
    await calendar.evaluate((part) => part.scrollIntoView({ block: 'center' }));
    await expect(calendar).toHaveAttribute('data-state', 'live', {
      timeout: 30_000,
    });
    const sizes = await page.locator('flutter-view').evaluateAll((views) =>
      views.map((view) => {
        const box = view.getBoundingClientRect();
        return `${Math.round(box.width)}x${Math.round(box.height)}`;
      })
    );
    expect(new Set(sizes)).toEqual(new Set(['320x344']));
    // The last day of the month sits at the bottom of the calendar: it is
    // exposed (so drawn) inside the visible part box.
    const box = await calendar.boundingBox();
    const day = await calendar
      .getByRole('button', { name: /^October 31, 2025/ })
      .boundingBox();
    expect(box && day && day.y + day.height <= box.y + box.height).toBe(true);
  });
});
