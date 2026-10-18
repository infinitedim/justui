import { inlinedFontCss } from './fonts';
import { emptyBox, isOffscreen, nextPaint, wait } from './shared';

export interface Raster {
  canvas: HTMLCanvasElement;
  width: number;
  height: number;
  dpr: number;
}

/** How long fonts may take to inline before the turn falls back. */
const FONT_BUDGET_MS = 700;

/** Freezes a sticky element's clone where the original sits right now. */
function freezeSticky(source: HTMLElement, clone: HTMLElement, top: number) {
  const previous = source.style.position;
  source.style.position = 'static';
  const resting = source.getBoundingClientRect().top;
  source.style.position = previous;
  Object.assign(clone.style, {
    position: 'relative',
    top: `${top - resting}px`,
    bottom: 'auto',
  });
}

/** Copies live form state into attributes so the clone shows it. */
function bakeFormState(source: Element, clone: Element) {
  if (source instanceof HTMLInputElement) {
    clone.setAttribute('value', source.value);
    if (source.checked) clone.setAttribute('checked', '');
  } else if (source instanceof HTMLTextAreaElement) {
    clone.textContent = source.value;
  }
}

/**
 * Clone of the visible page: off-screen blocks emptied, sticky elements
 * (`data-raster-sticky`) frozen in place, form values baked in.
 */
function rasterClone(root: HTMLElement, height: number): HTMLElement | null {
  const copy = root.cloneNode(true);
  if (!(copy instanceof HTMLElement)) return null;
  const walk = (source: Element, target: Element) => {
    const targets = target.children;
    Array.from(source.children).forEach((el, index) => {
      const clone = targets[index];
      if (!clone) return;
      const rect = el.getBoundingClientRect();
      if (
        clone instanceof HTMLElement &&
        isOffscreen(rect, height) &&
        getComputedStyle(el).position !== 'fixed' &&
        !getComputedStyle(el).display.includes('inline')
      ) {
        emptyBox(clone, rect);
        return;
      }
      if (el instanceof HTMLElement && clone instanceof HTMLElement) {
        if (el.hasAttribute('data-raster-sticky')) {
          freezeSticky(el, clone, rect.top);
        }
      }
      bakeFormState(el, clone);
      if (el.children.length > 0) walk(el, clone);
    });
  };
  walk(root, copy);
  copy.removeAttribute('id');
  return copy;
}

/** The page's CSS, minus @import and the font faces inlined separately. */
function pageCss(): string {
  let css = '';
  for (const sheet of Array.from(document.styleSheets)) {
    try {
      for (const rule of Array.from(sheet.cssRules)) {
        if (rule instanceof CSSImportRule) continue;
        if (rule instanceof CSSFontFaceRule) continue;
        css += `${rule.cssText}\n`;
      }
    } catch {
      // Cross-origin sheet: skipped, the page does not load any.
    }
  }
  return css;
}

/** Serializes the clone into an SVG foreignObject image. */
function toSvgImage(clone: HTMLElement, css: string, paper: string) {
  const width = window.innerWidth;
  const height = window.innerHeight;
  const wrap = document.createElement('div');
  // The html and body classes carry `dark` and the font variables.
  wrap.className = `${document.documentElement.className} ${document.body.className}`;
  wrap.style.cssText = `position:relative;width:${width}px;height:${height}px;overflow:hidden;background:${paper};-webkit-font-smoothing:antialiased;text-rendering:optimizeLegibility`;
  const style = document.createElement('style');
  style.textContent = css;
  wrap.append(style, clone);
  const markup = new XMLSerializer().serializeToString(wrap);
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}"><foreignObject x="0" y="0" width="${width}" height="${height}">${markup}</foreignObject></svg>`;
  const image = new Image(width, height);
  image.src = `data:image/svg+xml;charset=utf-8,${encodeURIComponent(svg)}`;
  return image;
}

/**
 * Rasterizes the visible page onto a canvas. Rejects when fonts are not
 * ready in time or the browser taints the canvas (Safari), so the caller
 * can fall back to the strip turn.
 */
export async function rasterize(
  root: HTMLElement,
  paper: string
): Promise<Raster> {
  const fonts = await Promise.race([
    inlinedFontCss(),
    wait(FONT_BUDGET_MS).then(() => null),
  ]);
  if (fonts === null) throw new Error('fonts not ready');
  const width = window.innerWidth;
  const height = window.innerHeight;
  const dpr = Math.min(2, window.devicePixelRatio || 1);
  const rect = root.getBoundingClientRect();
  const clone = rasterClone(root, height);
  if (!clone) throw new Error('clone failed');
  Object.assign(clone.style, {
    position: 'absolute',
    margin: '0',
    top: `${rect.top}px`,
    left: `${rect.left}px`,
    width: `${rect.width}px`,
  });
  const image = toSvgImage(clone, `${fonts}\n${pageCss()}`, paper);
  await image.decode();
  // Faces used only by a little text can finish loading a frame later.
  await nextPaint();
  const canvas = document.createElement('canvas');
  canvas.width = Math.round(width * dpr);
  canvas.height = Math.round(height * dpr);
  const context = canvas.getContext('2d');
  if (!context) throw new Error('no 2d context');
  context.fillStyle = paper;
  context.fillRect(0, 0, canvas.width, canvas.height);
  context.drawImage(image, 0, 0, canvas.width, canvas.height);
  context.getImageData(0, 0, 1, 1); // Throws when the canvas is tainted.
  return { canvas, width, height, dpr } satisfies Raster;
}
