import { inlinedFontCss } from './fonts';
import { glTurn } from './gl-turn';
import { rasterize } from './raster';
import {
  SWITCHING,
  TOP_LAYER,
  nextPaint,
  turnState,
  type TurnOptions,
} from './shared';
import { stripTurn } from './strip-turn';

export type { TurnOptions } from './shared';

/**
 * The theme switch as a turned page (owner decision, final). To dark the
 * old page curls away from the right edge; to light the same curl plays
 * in reverse with the new page un-rolling over a still of the old one.
 * Without WebGL, with a tainted canvas or when fonts are not ready it
 * falls back to the strip turn; reduced motion gets a short crossfade.
 */

let pending: Promise<void> | null = null;

/** Dark to light: the forward curl played backwards over the old page. */
async function reverseTurn(options: TurnOptions): Promise<void> {
  const html = document.documentElement;
  let cover: HTMLCanvasElement | null = null;
  let committed = false;
  try {
    const before = await rasterize(options.root, options.paper);
    cover = before.canvas;
    cover.setAttribute('aria-hidden', 'true');
    cover.style.cssText = `position:fixed;left:0;top:0;width:${before.width}px;height:${before.height}px;z-index:${Number(TOP_LAYER) + 1};pointer-events:none`;
    document.body.append(cover);
    html.setAttribute(SWITCHING, '');
    committed = true;
    await options.commit();
    await nextPaint();
    const after = await rasterize(options.root, options.paperNext);
    const still = cover;
    await glTurn(
      {
        paper: options.paperNext,
        dark: !options.dark,
        underDark: options.dark,
        dir: 1,
        duration: options.duration,
        onShown: () => still.remove(),
      },
      after,
      () => {},
      before
    );
  } catch {
    cover?.remove();
    html.removeAttribute(SWITCHING);
    if (!committed) await stripTurn(options);
  }
}

async function forwardTurn(options: TurnOptions): Promise<void> {
  try {
    const sheet = await rasterize(options.root, options.paper);
    await glTurn(
      {
        paper: options.paper,
        dark: options.dark,
        underDark: !options.dark,
        dir: options.dir,
        duration: options.duration,
      },
      sheet,
      () => void options.commit()
    );
  } catch {
    await stripTurn(options);
  }
}

/** Switches the theme with the page turn. Resolves when the turn ends. */
export function pageTurn(options: TurnOptions): Promise<void> {
  if (pending) return pending;
  turnState.finish?.();
  if (!document.body) return options.commit();
  if (options.reduced) return stripTurn(options);
  pending = (
    options.reverse ? reverseTurn(options) : forwardTurn(options)
  ).finally(() => {
    pending = null;
  });
  return pending;
}

/** Inlines the fonts ahead of the first switch so the raster is quick. */
export function warmPageTurn(): void {
  inlinedFontCss().catch(() => {
    // Retried on the next switch; the strip turn covers a miss.
  });
}
